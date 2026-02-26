import 'package:flutter/material.dart';

class NavBottom extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  const NavBottom({
    super.key,
    required this.selectedIndex,
    required this.onNavTap,
  });

  static const _kNavBarHeight = 60.0;
  static const _kNotchGap = 56.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return BottomAppBar(
      height: _kNavBarHeight + bottomPadding,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 8,
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildItem(context, Icons.home_outlined, Icons.home, "Inicio", 0),
            _buildItem(context, Icons.calendar_today_outlined, Icons.calendar_today, "Rentas", 1),
            const SizedBox(width: _kNotchGap),
            _buildItem(context, Icons.favorite_outline, Icons.favorite, "Favoritos", 2),
            _buildItem(context, Icons.person_outline, Icons.person, "Perfil", 3),
          ],
        ),
      ),
    );
  }

  static const Color _primaryColor = Color(0xFF3CA2A2);

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isActive = selectedIndex == index;

    const activeColor = _primaryColor;
    final inactiveColor = Colors.grey;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNavTap(index),
          splashColor: activeColor.withValues(alpha: 0.1),
          highlightColor: activeColor.withValues(alpha: 0.05),
          child: SizedBox(
            height: _kNavBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
