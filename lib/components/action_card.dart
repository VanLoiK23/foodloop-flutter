import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component ActionCard hiển thị các mục lựa chọn hành động hoặc liên kết hỗ trợ
class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final IconData? leadingIcon;
  final Color? leadingBgColor;
  final Color? leadingIconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingIcon,
    this.leadingBgColor,
    this.leadingIconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.radiusLg,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space16,
            vertical: AppTokens.space12,
          ),
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: AppTokens.radiusLg,
            border: Border.all(
              color: AppTokens.border,
              width: 1.0,
            ),
            boxShadow: AppTokens.cardShadow,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppTokens.space12),
              ] else if (leadingIcon != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: leadingBgColor ?? AppTokens.brandLight,
                    borderRadius: AppTokens.radiusMd,
                  ),
                  child: Center(
                    child: Icon(
                      leadingIcon,
                      color: leadingIconColor ?? AppTokens.brand,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTokens.headingMedium.copyWith(
                        fontSize: 15.0,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppTokens.space2),
                      Text(
                        subtitle!,
                        style: AppTokens.subtitle,
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTokens.textSecondary,
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

