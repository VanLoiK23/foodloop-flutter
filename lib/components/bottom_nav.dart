import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class BottomNavItem {
  final IconData icon;
  final String? label;
  final String? route;

  const BottomNavItem({
    required this.icon,
    this.label,
    this.route,
  });
}

/// Component BottomNav chuẩn theo thanh điều hướng FoodLoop
/// Hiển thị nút tròn nổi (floating circle) tại đúng vị trí tab ĐƯỢC CHỌN (currentIndex)
/// theo phong cách thiết kế của màn Kho gia đình (độ nổi Offset(0, -12), đổ bóng mềm, icon trắng):
/// - Khi ở Màn 100 (Cài đặt) và các màn thuộc tab Cá nhân (module_8_9): currentIndex = 4 -> Nút tròn xanh nổi ở icon Cá nhân
/// - Khi ở Màn 81 (Kiểm tra an toàn thực phẩm): currentIndex = 1 -> Nút tròn xanh nổi ở icon Tủ lạnh
class FoodLoopBottomNavComponent extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<BottomNavItem>? items;

  const FoodLoopBottomNavComponent({
    super.key,
    this.currentIndex = 4,
    this.onTap,
    this.items,
  });

  static const List<BottomNavItem> defaultItems = [
    BottomNavItem(icon: Icons.home_outlined, route: '/virtual-fridge'),
    BottomNavItem(icon: Icons.kitchen_outlined, route: '/virtual-fridge'),
    BottomNavItem(icon: Icons.map_outlined, route: '/virtual-fridge'),
    BottomNavItem(icon: Icons.shopping_bag_outlined, route: '/rescue-market'),
    BottomNavItem(icon: Icons.person_outline, route: '/settings'),
  ];

  void _handleTap(BuildContext context, int index, List<BottomNavItem> navItems) {
    onTap?.call(index);
    final targetRoute = navItems[index].route;
    if (targetRoute != null) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == targetRoute) return;
      Navigator.pushNamed(context, targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = items ?? defaultItems;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTokens.border,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 8.0,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(navItems.length, (index) {
            // Nút tròn nổi chỉ hiển thị tại tab ĐANG ĐƯỢC CHỌN (currentIndex)
            final isSelected = index == currentIndex;
            final item = navItems[index];

            if (isSelected) {
              const double circleSize = 52.0;
              final Widget activeItem = GestureDetector(
                onTap: () => _handleTap(context, index, navItems),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: AppTokens.navBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTokens.navBlue.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              );

              return Transform.translate(
                offset: const Offset(0, -12),
                child: activeItem,
              );
            }

            // Các tab khác không được chọn hiển thị icon bình thường màu xám
            return IconButton(
              onPressed: () => _handleTap(context, index, navItems),
              icon: Icon(
                item.icon,
                color: AppTokens.navUnselected,
                size: 24,
              ),
            );
          }),
        ),
      ),
    );
  }
}
