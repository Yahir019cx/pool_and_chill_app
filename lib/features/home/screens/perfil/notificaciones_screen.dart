import 'package:flutter/material.dart';

// ─── Modelo local ──────────────────────────────────────────────────────────────

enum _NotifType { booking, payment, cancellation, review, reminder, system }

class _Notif {
  final String id;
  final _NotifType type;
  final String title;
  final String body;
  final DateTime date;
  bool read;

  _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
  });
}

// ─── Screen ────────────────────────────────────────────────────────────────────

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  static const _kPrimary = Color(0xFF2D9D91);
  static const _kDark = Color(0xFF1A1A2E);

  // Mock data — reemplazar con llamada al backend cuando esté disponible.
  late List<_Notif> _notifs;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _notifs = [
      _Notif(
        id: '1',
        type: _NotifType.booking,
        title: 'Nueva reserva confirmada',
        body: 'Carlos Mendoza reservó tu alberca para el 25 de feb.',
        date: now.subtract(const Duration(hours: 1)),
      ),
      _Notif(
        id: '2',
        type: _NotifType.payment,
        title: 'Pago recibido',
        body: 'Recibiste \$1,800 por la reserva del 20 de feb.',
        date: now.subtract(const Duration(hours: 3)),
        read: true,
      ),
      _Notif(
        id: '3',
        type: _NotifType.reminder,
        title: 'Check-in mañana',
        body: 'María García llega mañana a las 10:00 AM.',
        date: now.subtract(const Duration(hours: 5)),
      ),
      _Notif(
        id: '4',
        type: _NotifType.review,
        title: 'Nueva valoración',
        body: 'Recibiste una reseña de ⭐ 5/5 de tu última renta.',
        date: now.subtract(const Duration(days: 1, hours: 2)),
        read: true,
      ),
      _Notif(
        id: '5',
        type: _NotifType.cancellation,
        title: 'Reserva cancelada',
        body: 'Juan Pérez canceló su reserva del 18 de feb.',
        date: now.subtract(const Duration(days: 1, hours: 8)),
        read: true,
      ),
      _Notif(
        id: '6',
        type: _NotifType.booking,
        title: 'Nueva reserva confirmada',
        body: 'Ana Torres reservó tu cabaña del 15 al 17 de mar.',
        date: now.subtract(const Duration(days: 3)),
        read: true,
      ),
      _Notif(
        id: '7',
        type: _NotifType.system,
        title: 'Perfil verificado',
        body: 'Tu identidad fue verificada. Ya puedes publicar propiedades.',
        date: now.subtract(const Duration(days: 5)),
        read: true,
      ),
      _Notif(
        id: '8',
        type: _NotifType.payment,
        title: 'Pago procesado',
        body: 'Se transfirieron \$3,200 a tu cuenta bancaria.',
        date: now.subtract(const Duration(days: 6)),
        read: true,
      ),
    ];
  }

  int get _unreadCount => _notifs.where((n) => !n.read).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n.read = true;
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      _notifs.firstWhere((n) => n.id == id).read = true;
    });
  }

  // ─── Agrupación ─────────────────────────────────────────────────────────────

  Map<String, List<_Notif>> get _grouped {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<_Notif>>{};

    for (final n in _notifs) {
      final d = DateTime(n.date.year, n.date.month, n.date.day);
      final String group;
      if (d == today) {
        group = 'Hoy';
      } else if (d == yesterday) {
        group = 'Ayer';
      } else if (d.isAfter(weekAgo)) {
        group = 'Esta semana';
      } else {
        group = 'Anteriores';
      }
      groups.putIfAbsent(group, () => []).add(n);
    }
    return groups;
  }

  // ─── Visual helpers ─────────────────────────────────────────────────────────

  static const _typeConfig = {
    _NotifType.booking: (
      icon: Icons.calendar_today_rounded,
      color: Color(0xFF2D9D91),
      bg: Color(0xFFE8F6F5),
    ),
    _NotifType.payment: (
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF5B8C5A),
      bg: Color(0xFFEBF3EB),
    ),
    _NotifType.cancellation: (
      icon: Icons.cancel_outlined,
      color: Color(0xFFD9534F),
      bg: Color(0xFFFDECEC),
    ),
    _NotifType.review: (
      icon: Icons.star_rounded,
      color: Color(0xFFE5A84B),
      bg: Color(0xFFFDF4E3),
    ),
    _NotifType.reminder: (
      icon: Icons.access_time_rounded,
      color: Color(0xFF5B7FD9),
      bg: Color(0xFFECF0FD),
    ),
    _NotifType.system: (
      icon: Icons.info_outline_rounded,
      color: Color(0xFF8C6BB1),
      bg: Color(0xFFF2EDF8),
    ),
  };

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final groupOrder = ['Hoy', 'Ayer', 'Esta semana', 'Anteriores'];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kDark,
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Leer todas',
                style: TextStyle(
                  color: _kPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifs.isEmpty
          ? _buildEmpty()
          : ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                for (final group in groupOrder)
                  if (grouped.containsKey(group)) ...[
                    _buildGroupHeader(group, grouped[group]!.length),
                    ...grouped[group]!.map(_buildItem),
                  ],
              ],
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aquí aparecerán tus reservas,\npagos y avisos importantes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String label, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(_Notif notif) {
    final cfg = _typeConfig[notif.type]!;

    return GestureDetector(
      onTap: () => _markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        decoration: BoxDecoration(
          color: notif.read ? Colors.white : _kPrimary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.read
                ? Colors.grey.shade100
                : _kPrimary.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cfg.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cfg.icon, size: 20, color: cfg.color),
              ),
              const SizedBox(width: 12),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.read
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: _kDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Indicador no leído
                        if (!notif.read) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _kPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _relativeTime(notif.date),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
