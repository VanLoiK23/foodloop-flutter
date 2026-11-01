import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component ScreenHeader chuẩn gồm nút Back tròn, tiêu đề lớn và dòng phụ
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Widget? trailing;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showBackButton = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBackButton) ...[
                GestureDetector(
                  onTap: onBack ?? () => Navigator.maybePop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTokens.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTokens.border,
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: AppTokens.title,
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTokens.headingLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTokens.space6),
            Padding(
              padding: EdgeInsets.only(
                left: showBackButton ? 52.0 : 0.0,
              ),
              child: Text(
                subtitle!,
                style: AppTokens.subtitle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

