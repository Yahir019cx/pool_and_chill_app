import 'package:flutter/material.dart';

class BottomNavAnfitrion extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemTapped;

  const BottomNavAnfitrion({
    super.key,
    required this.selectedIndex,
    this.onItemTapped,
  });

  /// Mismo color primario que NavBottom (home) para consistencia.
  static const Color _primaryColor = Color(0xFF3CA2A2);

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return;
    if (onItemTapped != null) {
      onItemTapped!(index);
      return;
    }
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/welcome-anfitrion-dash');
      case 1:
        Navigator.pushReplacementNamed(context, '/mis-espacios-anfitrion');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _handleNavigation(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      elevation: 8,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home_rounded, size: 24),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.villa_outlined, size: 24),
          activeIcon: Icon(Icons.villa, size: 24),
          label: 'Mis espacios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note_outlined, size: 24),
          activeIcon: Icon(Icons.event_note, size: 24),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined, size: 24),
          activeIcon: Icon(Icons.account_circle, size: 24),
          label: 'Cuenta',
        ),
      ],
    );
  }
}
