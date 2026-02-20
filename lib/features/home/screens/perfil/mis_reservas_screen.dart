import 'package:flutter/material.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen>
    with SingleTickerProviderStateMixin {
  static const _primaryColor = Color(0xFF3CA2A2);

  late final TabController _tabController;

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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mis Rentas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildMonthlyChart(),
            const SizedBox(height: 24),
            _buildTabSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.calendar_month,
              value: '12',
              label: 'Total reservas',
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.attach_money,
              value: '\$18,500',
              label: 'Gastado',
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.star_rounded,
              value: '4.8',
              label: 'Calificación',
              color: Colors.amber.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
    final values = [2, 1, 3, 2, 4, 3];
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reservas por mes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '2024',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (index) {
                final heightPercent = values[index] / maxValue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${values[index]}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          height: 80 * heightPercent,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _primaryColor,
                                _primaryColor.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Próximas'),
              Tab(text: 'Activas'),
              Tab(text: 'Pasadas'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildReservasList(_proximasReservas),
              _buildReservasList(_activasReservas),
              _buildReservasList(_pasadasReservas),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReservasList(List<_ReservaMock> reservas) {
    if (reservas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay reservas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: reservas.length,
      itemBuilder: (context, index) => _ReservaCard(reserva: reservas[index]),
    );
  }

  // Mock data
  List<_ReservaMock> get _proximasReservas => [
        _ReservaMock(
          nombre: 'Villa Paradise',
          fecha: '25 - 27 Feb',
          precio: '\$4,500',
          imagen: 'https://picsum.photos/200/150?random=10',
          estado: _EstadoReserva.confirmada,
        ),
        _ReservaMock(
          nombre: 'Casa del Lago',
          fecha: '10 - 12 Mar',
          precio: '\$3,200',
          imagen: 'https://picsum.photos/200/150?random=11',
          estado: _EstadoReserva.pendiente,
        ),
      ];

  List<_ReservaMock> get _activasReservas => [
        _ReservaMock(
          nombre: 'Terraza Sunset',
          fecha: '18 - 20 Ene',
          precio: '\$2,800',
          imagen: 'https://picsum.photos/200/150?random=12',
          estado: _EstadoReserva.enCurso,
        ),
      ];

  List<_ReservaMock> get _pasadasReservas => [
        _ReservaMock(
          nombre: 'Alberca Tropical',
          fecha: '5 - 7 Dic',
          precio: '\$3,500',
          imagen: 'https://picsum.photos/200/150?random=13',
          estado: _EstadoReserva.completada,
        ),
        _ReservaMock(
          nombre: 'Jardín Secreto',
          fecha: '20 - 22 Nov',
          precio: '\$2,100',
          imagen: 'https://picsum.photos/200/150?random=14',
          estado: _EstadoReserva.completada,
        ),
        _ReservaMock(
          nombre: 'Cabaña del Bosque',
          fecha: '1 - 3 Oct',
          precio: '\$5,000',
          imagen: 'https://picsum.photos/200/150?random=15',
          estado: _EstadoReserva.cancelada,
        ),
      ];
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _EstadoReserva { pendiente, confirmada, enCurso, completada, cancelada }

class _ReservaMock {
  final String nombre;
  final String fecha;
  final String precio;
  final String imagen;
  final _EstadoReserva estado;

  _ReservaMock({
    required this.nombre,
    required this.fecha,
    required this.precio,
    required this.imagen,
    required this.estado,
  });
}

class _ReservaCard extends StatelessWidget {
  final _ReservaMock reserva;

  const _ReservaCard({required this.reserva});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              reserva.imagen,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reserva.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildEstadoChip(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reserva.fecha,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reserva.precio,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3CA2A2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip() {
    final config = _getEstadoConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: config.color,
        ),
      ),
    );
  }

  ({String label, Color color}) _getEstadoConfig() {
    switch (reserva.estado) {
      case _EstadoReserva.pendiente:
        return (label: 'Pendiente', color: Colors.orange);
      case _EstadoReserva.confirmada:
        return (label: 'Confirmada', color: Colors.green);
      case _EstadoReserva.enCurso:
        return (label: 'En curso', color: const Color(0xFF3CA2A2));
      case _EstadoReserva.completada:
        return (label: 'Completada', color: Colors.grey);
      case _EstadoReserva.cancelada:
        return (label: 'Cancelada', color: Colors.red);
    }
  }
}
