import 'package:flutter/material.dart';

class BottomNavAnfitrion extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemTapped;

  const BottomNavAnfitrion({
    super.key,
    required this.selectedIndex,
    this.onItemTapped,
  });

  static const Color primary = Color(0xFF2D9D91);

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return;

    if (onItemTapped != null) {
      onItemTapped!(index);
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/welcome-anfitrion-dash');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/mis-espacios-anfitrion');
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _handleNavigation(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey.shade500,
      selectedFontSize: 11,
      unselectedFontSize: 10,
      showUnselectedLabels: true,
      items: [
        _item(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Inicio',
          index: 0,
        ),
        _item(
          icon: Icons.business_center_outlined,
          activeIcon: Icons.business_center,
          label: 'Mis espacios',
          index: 1,
        ),
        _item(
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_today,
          label: 'Reservas',
          index: 2,
        ),
        _item(
          icon: Icons.attach_money_outlined,
          activeIcon: Icons.attach_money,
          label: 'Ganancias',
          index: 3,
        ),
        _item(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Cuenta',
          index: 4,
        ),
      ],
    );
  }

  BottomNavigationBarItem _item({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {

    return BottomNavigationBarItem(
      icon: Icon(icon, size: 22),
      activeIcon: Icon(activeIcon, size: 24),
      label: label,
    );
  }
}
