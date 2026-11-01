import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component StatusBadge hiển thị huy hiệu / chip trạng thái nhỏ gọn
class StatusBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const StatusBadge({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppTokens.warningBg;
    final effectiveText = textColor ?? AppTokens.warningText;

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppTokens.space10,
            vertical: AppTokens.space4,
          ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: borderRadius ?? AppTokens.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: iconColor ?? effectiveText,
            ),
            const SizedBox(width: AppTokens.space4),
          ],
          Text(
            text,
            style: AppTokens.caption.copyWith(
              color: effectiveText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

