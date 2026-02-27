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
      case 1:
        Navigator.pushReplacementNamed(context, '/mis-espacios-anfitrion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _handleNavigation(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.shade400,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 23),
            activeIcon: Icon(Icons.home_rounded, size: 25),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.villa_outlined, size: 23),
            activeIcon: Icon(Icons.villa, size: 25),
            label: 'Mis espacios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined, size: 23),
            activeIcon: Icon(Icons.event_note, size: 25),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, size: 23),
            activeIcon: Icon(Icons.account_circle, size: 25),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}
