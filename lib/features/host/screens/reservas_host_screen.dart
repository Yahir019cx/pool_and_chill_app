import 'package:flutter/material.dart';

class ReservasHostScreen extends StatefulWidget {
  const ReservasHostScreen({super.key});

  @override
  State<ReservasHostScreen> createState() => _ReservasHostScreenState();
}

class _ReservasHostScreenState extends State<ReservasHostScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primary = Color(0xFF2D9D91);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Reservas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: primary,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Próximas'),
                Tab(text: 'Pasadas'),
                Tab(text: 'Canceladas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReservationsList(upcoming: true),
                  _buildReservationsList(upcoming: false),
                  _buildCancelledList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList({required bool upcoming}) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _ReservationDetailCard(
          guestName: 'Carlos Mendoza',
          spaceName: 'Alberca Principal',
          date: upcoming ? '25 Ene 2025' : '15 Ene 2025',
          time: '2:00 PM - 6:00 PM',
          guests: 8,
          total: 1200,
          status: upcoming ? 'Confirmada' : 'Completada',
        ),
        const SizedBox(height: 16),
        _ReservationDetailCard(
          guestName: 'María García',
          spaceName: 'Alberca con Jardín',
          date: upcoming ? '28 Ene 2025' : '10 Ene 2025',
          time: '10:00 AM - 2:00 PM',
          guests: 5,
          total: 1500,
          status: upcoming ? 'Pendiente' : 'Completada',
        ),
      ],
    );
  }

  Widget _buildCancelledList() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        _ReservationDetailCard(
          guestName: 'Juan Pérez',
          spaceName: 'Terraza con Alberca',
          date: '5 Ene 2025',
          time: '4:00 PM - 8:00 PM',
          guests: 10,
          total: 2000,
          status: 'Cancelada',
        ),
      ],
    );
  }
}

class _ReservationDetailCard extends StatelessWidget {
  final String guestName;
  final String spaceName;
  final String date;
  final String time;
  final int guests;
  final double total;
  final String status;

  const _ReservationDetailCard({
    required this.guestName,
    required this.spaceName,
    required this.date,
    required this.time,
    required this.guests,
    required this.total,
    required this.status,
  });

  static const Color primary = Color(0xFF2D9D91);

  Color get statusColor {
    switch (status) {
      case 'Confirmada':
        return primary;
      case 'Pendiente':
        return Colors.orange;
      case 'Completada':
        return Colors.grey;
      case 'Cancelada':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_outline, color: primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guestName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spaceName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: date,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.schedule_outlined,
                    label: time,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.group_outlined,
                    label: '$guests personas',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${total.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              const Spacer(),
              if (status == 'Confirmada' || status == 'Pendiente')
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver detalles',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
