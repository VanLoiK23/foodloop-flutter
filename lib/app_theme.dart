import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

bool get firebaseReady => Firebase.apps.isNotEmpty;

class AppColors {
  // --- MÀU CHUẨN THEO MOOD BOARD ---
  static const brand = Color(0xFF2E7D32);      // Primary: #2E7D32
  static const accent = Color(0xFFF4B942);     // Accent: #F4B942
  static const cream = Color(0xFFFFF8E7);      // Background: #FFF8E7
  static const surface = Color(0xFFFFFFFF);    // Surface: #FFFFFF (Đã sửa lại)
  static const title = Color(0xFF2B3A35);      // Text Primary: #2B3A35
  static const gray = Color(0xFF6B7280);       // Text Secondary: #6B7280
  static const danger = Color(0xFFD64545);     // Danger: #D64545
  static const greenSoft = Color(0xFF3E9B6A);  // Success: #3E9B6A

  // --- CÁC MÀU PHỤ TRỢ (Không có trong mood board nhưng đang được dùng trong code) ---
  static const dangerStrong = Color(0xFFDC2626);
  static const border = Color(0xFFE2E8F0);
  static const greenBg = Color(0xFFE8F5E9);
  static const muted = Color(0xFF9CA3AF);
  static const dangerBg = Color(0xFFFFF1F1);
  static const dangerBorder = Color(0xFFFECACA);
  static const shadow = Color(0x0C000000);
  static const navBlue = Color(0xFF3B4A6B);    // Màu vòng tròn Bottom Nav
}

class AppTheme {
  static ThemeData get data => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand),
        scaffoldBackgroundColor: Colors.white,
      );

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.cream, Colors.white],
  );
}

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    this.size = 48,
    this.radius = 12,
    this.seed = 1,
  });

  final double size;
  final double radius;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        'https://picsum.photos/seed/$seed/200',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: AppColors.greenBg,
          child: const Icon(Icons.image_outlined, color: AppColors.brand),
        ),
      ),
    );
  }
}

class FoodLoopBottomNav extends StatelessWidget {
  const FoodLoopBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 1. Trang chủ
            _item(
              context,
              0,
              Icons.home_outlined,
              '/home',
            ),

            // 2. Tủ lạnh
            _item(
              context,
              1,
              Icons.kitchen_outlined,
              '/virtual-fridge',
            ),

            // 3. Bản đồ
            _item(
              context,
              2,
              Icons.map_outlined,
              '/map',
            ),

            // 4. Mua sắm
            _item(
              context,
              3,
              Icons.shopping_bag_outlined,
              '/shopping',
            ),

            // 5. Hồ sơ
            _item(
              context,
              4,
              Icons.person_outline,
              '/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    IconData icon,
    String route,
  ) {
    // Xác định icon đang được chọn
    final selected = index == currentIndex;

    const double circleSize = 52.0;

    // Icon bình thường hoặc icon đang được chọn
    Widget iconWidget = Icon(
      icon,
      size: 24,
      color: selected
          ? Colors.white
          : AppColors.gray,
    );

    // Nếu icon đang được chọn
    if (selected) {
      Widget activeItem = GestureDetector(
        onTap: () {
          _go(context, route);
        },
        child: Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: AppColors.navBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.navBlue.withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: iconWidget,
          ),
        ),
      );

      return Transform.translate(
        offset: const Offset(0, -12),
        child: activeItem,
      );
    }

    // Icon chưa được chọn
    return IconButton(
      onPressed: () {
        _go(context, route);
      },
      icon: iconWidget,
    );
  }
}

void showAppSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => child,
  );
}