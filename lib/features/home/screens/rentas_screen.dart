import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/rentas_provider.dart';
import 'package:pool_and_chill_app/features/home/widgets/booking_card.dart';
import 'booking_detail_screen.dart';
import 'guest_property_review_screen.dart';

class RentasScreen extends ConsumerStatefulWidget {
  const RentasScreen({super.key});

  @override
  ConsumerState<RentasScreen> createState() => _RentasScreenState();
}

class _RentasScreenState extends ConsumerState<RentasScreen> {
  static const _primary = Color(0xFF3CA2A2);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(rentasProvider);
    if (!state.hasMore || state.isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(rentasProvider.notifier).loadMore();
    }
  }

  void _load() {
    final auth = provider_pkg.Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      ref.read(rentasProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = provider_pkg.Provider.of<AuthProvider>(context);
    final state = ref.watch(rentasProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Text(
            'Mis Rentas',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        if (auth.isAuthenticated) ...[
          const SizedBox(height: 16),
          _FilterToggle(
            current: state.filter,
            onChanged: (f) => ref.read(rentasProvider.notifier).setFilter(f),
          ),
        ],
        const SizedBox(height: 4),
        Expanded(child: _buildContent(auth, state)),
      ],
    );
  }

  Widget _buildContent(AuthProvider auth, RentasState state) {
    if (!auth.isAuthenticated) {
      return const _EmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Inicia sesión para ver tus rentas',
      );
    }

    if (state.isLoading && state.bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3CA2A2),
          strokeWidth: 2.5,
        ),
      );
    }

    if (state.error != null && state.bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No se pudieron cargar tus rentas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Revisa tu conexión e intenta de nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3CA2A2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = state.filtered;
    if (filtered.isEmpty) {
      return _buildEmptyFilter(state.filter);
    }

    final showLoadMore = state.hasMore && state.isLoadingMore;
    final itemCount = filtered.length + (state.hasMore ? 1 : 0);

    return RefreshIndicator(
      color: _primary,
      onRefresh: () => ref.read(rentasProvider.notifier).load(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        itemCount: itemCount,
        itemBuilder: (_, i) {
          if (i < filtered.length) {
            final booking = filtered[i];
            return BookingCard(
              booking: booking,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingDetailScreen(booking: booking),
                ),
              ),
              onRateTap: booking.status.id == 4
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              GuestPropertyReviewScreen(booking: booking),
                        ),
                      )
                  : null,
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: showLoadMore
                  ? const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        color: Color(0xFF3CA2A2),
                        strokeWidth: 2.5,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyFilter(RentaFilter filter) {
    final (icon, title, subtitle) = switch (filter) {
      RentaFilter.proximas => (
          Icons.event_note_outlined,
          'Sin rentas próximas',
          'Explora espacios y reserva tu próxima experiencia.',
        ),
      RentaFilter.pasadas => (
          Icons.history_rounded,
          'Sin rentas pasadas',
          'Aquí aparecerán tus visitas anteriores.',
        ),
      RentaFilter.canceladas => (
          Icons.cancel_outlined,
          'Sin rentas canceladas',
          '¡Todo en orden! No tienes cancelaciones.',
        ),
    };

    return _EmptyState(icon: icon, title: title, subtitle: subtitle);
  }
}

// ─── Filter Toggle ──────────────────────────────────────────────────

class _FilterToggle extends StatelessWidget {
  final RentaFilter current;
  final ValueChanged<RentaFilter> onChanged;

  const _FilterToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _tab('Próximas', RentaFilter.proximas),
            _tab('Pasadas', RentaFilter.pasadas),
            _tab('Canceladas', RentaFilter.canceladas),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, RentaFilter filter) {
    final isActive = current == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3CA2A2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF3CA2A2).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _EmptyState({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
