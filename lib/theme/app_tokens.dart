import 'package:flutter/material.dart';

/// Hệ thống Design Tokens của FoodLoop App
/// Được trích xuất chuẩn xác từ Figma Design

class AppTokens {
  // --- COLORS (Màu sắc) ---
  static const Color brand = Color(0xFF2E7D32);          // Primary Green: #2E7D32
  static const Color brandLight = Color(0xFFE8F5E9);     // Light Green Tint: #E8F5E9
  static const Color accent = Color(0xFFF4B942);         // Accent Yellow: #F4B942
  static const Color cream = Color(0xFFFCF9F2);          // App Background Cream: #FCF9F2
  static const Color surface = Color(0xFFFFFFFF);        // White Card Surface: #FFFFFF
  
  static const Color title = Color(0xFF1F2937);          // Text Primary Dark: #1F2937
  static const Color body = Color(0xFF374151);           // Text Body: #374151
  static const Color textSecondary = Color(0xFF6B7280);  // Text Subtitle / Gray: #6B7280
  static const Color border = Color(0xFFE5E7EB);         // Border Gray: #E5E7EB
  static const Color divider = Color(0xFFF3F4F6);        // Subtle Divider
  
  // Alert & Danger Colors (Khối thông báo đỏ)
  static const Color danger = Color(0xFFDC2626);         // Red Icon / Text: #DC2626
  static const Color dangerBg = Color(0xFFFEF2F2);       // Light Pink/Red Background: #FEF2F2
  static const Color dangerBorder = Color(0xFFFEE2E2);   // Soft Red Border: #FEE2E2

  // Info Colors (Khối thông báo xanh dương)
  static const Color info = Color(0xFF2563EB);           // Blue Icon / Text: #2563EB
  static const Color infoBg = Color(0xFFEFF6FF);         // Light Blue Background: #EFF6FF
  static const Color infoBorder = Color(0xFFDBEAFE);     // Soft Blue Border: #DBEAFE

  // Warning Colors (Khối cảnh báo vàng / cam)
  static const Color warning = Color(0xFFD97706);        // Amber Icon / Text: #D97706
  static const Color warningBg = Color(0xFFFEF9C3);      // Light Amber/Yellow Background: #FEF9C3
  static const Color warningBorder = Color(0xFFFDE68A);  // Soft Amber Border: #FDE68A
  static const Color warningText = Color(0xFF92400E);    // Dark Amber Text: #92400E

  // Navigation Bar Colors
  static const Color navBlue = Color(0xFF26427C);        // Highlight Tab Circle Blue
  static const Color navBlueShadow = Color(0x4D26427C);  // Soft Shadow for Active Nav Item
  static const Color navUnselected = Color(0xFF6B7280);  // Unselected Icon Color

  // --- SPACING (Khoảng cách) ---
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // --- BORDER RADIUS (Độ bo góc) ---
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(20.0));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999.0));

  // --- TYPOGRAPHY (Kiểu chữ) ---
  static const TextStyle headingLarge = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: title,
    letterSpacing: -0.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    color: title,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: body,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: body,
    height: 1.4,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: brand,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: surface,
    letterSpacing: 0.1,
  );

  // --- SHADOWS ---
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 10.0,
      offset: Offset(0, 2),
    ),
  ];
}
