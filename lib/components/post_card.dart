import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component PostCard hiển thị thông tin tóm tắt sản phẩm / bài đăng cần xử lý
class PostCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? image;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
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
          padding: const EdgeInsets.all(AppTokens.space12),
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
              // Ảnh thumbnail bài đăng
              ClipRRect(
                borderRadius: AppTokens.radiusMd,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: image ?? _defaultPlaceholder(),
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              // Thông tin bài đăng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTokens.headingMedium.copyWith(
                        fontSize: 15.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      subtitle,
                      style: AppTokens.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppTokens.space8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: AppTokens.brandLight,
      child: const Center(
        child: Icon(
          Icons.eco_rounded,
          color: AppTokens.brand,
          size: 26,
        ),
      ),
    );
  }
}

