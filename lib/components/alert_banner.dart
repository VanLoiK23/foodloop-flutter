import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component AlertBanner hiển thị cảnh báo, thông báo lý do xử lý kèm hành động
class AlertBanner extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  const AlertBanner({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.icon = Icons.error_outline_rounded,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTokens.dangerBg,
        borderRadius: AppTokens.radiusLg,
        border: Border.all(
          color: borderColor ?? AppTokens.dangerBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor ?? AppTokens.danger,
                size: 22,
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTokens.headingMedium.copyWith(
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      message,
                      style: AppTokens.bodyRegular.copyWith(
                        color: AppTokens.body,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionText != null) ...[
            const SizedBox(height: AppTokens.space12),
            Padding(
              padding: const EdgeInsets.only(left: 34.0),
              child: GestureDetector(
                onTap: onAction,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: AppTokens.link,
                    ),
                    const SizedBox(width: AppTokens.space4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppTokens.brand,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

