import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/host_reservas_provider.dart';
import 'package:pool_and_chill_app/features/host/widgets/host_booking_card.dart';
import 'package:pool_and_chill_app/features/properties/Screens/Publish.dart';
import 'package:pool_and_chill_app/features/host/screens/date_blocks/select_property_for_block_screen.dart';
import 'package:pool_and_chill_app/features/host/screens/special_rates/select_property_screen.dart';

class InicioHostScreen extends ConsumerStatefulWidget {
  const InicioHostScreen({super.key});

  @override
  ConsumerState<InicioHostScreen> createState() => _InicioHostScreenState();
}

class _InicioHostScreenState extends ConsumerState<InicioHostScreen> {
  static const _primary = Color(0xFF2D9D91);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hostReservasProvider.notifier).load();
    });
  }

  Future<void> _refresh() => ref.read(hostReservasProvider.notifier).load();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    final displayName = profile?.displayName ?? 'Anfitrión';
    final hostState = ref.watch(hostReservasProvider);

    final totalReservas = hostState.isLoading && hostState.bookings.isEmpty
        ? '–'
        : (hostState.summary?.totalBookings ?? hostState.bookings.length)
            .toString();

    final ganancias = hostState.isLoading && hostState.bookings.isEmpty
        ? '–'
        : NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0)
            .format(hostState.totalGanancias);

    final rating = hostState.isLoading && hostState.bookings.isEmpty
        ? '–'
        : (hostState.hostRating == null || hostState.hostRating!.totalReviews == 0)
            ? 'Nueva'
            : hostState.hostRating!.average.toStringAsFixed(1);

    final proximas = hostState.proximas;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: _primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 22),

                    // ── Header ──────────────────────────────────
                    _buildHeader(profile, displayName),
                    const SizedBox(height: 24),

                    // ── Stats (single card) ──────────────────────
                    _StatsCard(
                      totalReservas: totalReservas,
                      ganancias: ganancias,
                      rating: rating,
                    ),
                    const SizedBox(height: 28),

                    // ── Acciones rápidas ─────────────────────────
                    _label('Acciones rápidas'),
                    const SizedBox(height: 12),
                    _buildActions(context),
                    const SizedBox(height: 28),

                    // ── Próximas reservas ────────────────────────
                    Row(
                      children: [
                        _label('Próximas reservas'),
                        const Spacer(),
                        if (hostState.summary != null)
                          _Pill(count: hostState.summary!.totalProximas),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (hostState.isLoading && hostState.bookings.isEmpty)
                      ..._skeletons()
                    else if (hostState.error != null && hostState.bookings.isEmpty)
                      _ErrorBanner(error: hostState.error!)
                    else if (proximas.isEmpty)
                      const _EmptyState()
                    else
                      ...proximas.map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: HostBookingCard(booking: b),
                          )),

                    const SizedBox(height: 110),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      );

  Widget _buildHeader(dynamic profile, String displayName) {
    return Row(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF2D9D91).withValues(alpha: 0.1),
              backgroundImage: profile?.profileImageUrl != null &&
                      profile!.profileImageUrl!.isNotEmpty
                  ? NetworkImage(profile.profileImageUrl!)
                  : null,
              child: profile?.profileImageUrl == null ||
                      profile!.profileImageUrl!.isEmpty
                  ? (profile?.initials?.isNotEmpty == true
                      ? Text(
                          profile!.initials,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D9D91),
                          ),
                        )
                      : const Icon(Icons.person_rounded,
                          color: Color(0xFF2D9D91), size: 28))
                  : null,
            ),
            if (profile?.isIdentityVerified == true)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: Color(0xFF2D9D91), size: 14),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $displayName',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Panel de anfitrión',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = [
      (Icons.add_business_rounded, 'Agregar espacio',
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PublishScreen()))),
      (Icons.event_busy_rounded, 'Bloquear fechas',
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SelectPropertyForBlockScreen()))),
      (Icons.sell_rounded, 'Tarifas especiales',
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SelectPropertyForRateScreen()))),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final i = entry.key;
          final (icon, label, onTap) = entry.value;
          final isLast = i == actions.length - 1;
          return Column(
            children: [
              _ActionRow(icon: icon, label: label, onTap: onTap),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 58,
                  endIndent: 0,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _skeletons() => List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SkeletonCard(),
        ),
      );
}

// ─── Stats Card ───────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final String totalReservas;
  final String ganancias;
  final String rating;

  const _StatsCard({
    required this.totalReservas,
    required this.ganancias,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.calendar_today_rounded,
              iconColor: const Color(0xFF2D9D91),
              value: totalReservas,
              label: 'Reservas',
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF5B8C5A),
              value: ganancias,
              label: 'Ganancias',
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFE5A84B),
              value: rating,
              label: 'Rating',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.grey.shade100,
    );
  }
}

// ─── Action Row ───────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

// ─── Pill badge ───────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final int count;
  const _Pill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2D9D91).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D9D91),
        ),
      ),
    );
  }
}

// ─── Empty / Error / Skeleton ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2D9D91).withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_outlined,
                color: Color(0xFF2D9D91), size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin próximas reservas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Las reservas confirmadas aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  const _ErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error,
                style: TextStyle(fontSize: 13, color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 12,
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
