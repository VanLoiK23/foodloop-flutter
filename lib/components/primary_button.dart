import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component PrimaryButton chuẩn nút hành động chính của ứng dụng
/// Hỗ trợ cả nút nền đặc (Filled), nút viền (Outlined), và các biến thể màu (Brand, Danger)
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double height;
  final BorderRadius? borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.height = 52.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Color effectiveBg;
    Color effectiveText;
    BorderSide effectiveSide = BorderSide.none;

    if (isOutlined) {
      effectiveBg = backgroundColor ?? AppTokens.surface;
      effectiveText = textColor ?? AppTokens.brand;
      effectiveSide = BorderSide(
        color: borderColor ?? AppTokens.brand,
        width: 1.2,
      );
    } else {
      effectiveBg = isEnabled
          ? (backgroundColor ?? AppTokens.brand)
          : (backgroundColor ?? AppTokens.brand).withValues(alpha: 0.5);
      effectiveText = textColor ?? AppTokens.surface;
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          foregroundColor: effectiveText,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: effectiveSide,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? AppTokens.radiusLg,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOutlined ? AppTokens.brand : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: effectiveText),
                    const SizedBox(width: AppTokens.space8),
                  ],
                  Text(
                    text,
                    style: AppTokens.buttonText.copyWith(
                      color: effectiveText,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
