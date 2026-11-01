import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component MediaUploadPreview hiển thị các ô xem trước ảnh minh chứng kèm nút mở thư viện
class MediaUploadPreview extends StatelessWidget {
  final List<Widget>? thumbnailWidgets;
  final int placeholderCount;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MediaUploadPreview({
    super.key,
    this.thumbnailWidgets,
    this.placeholderCount = 3,
    this.onTap,
    this.trailing,
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
              Expanded(
                child: Row(
                  children: List.generate(
                    thumbnailWidgets?.length ?? placeholderCount,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppTokens.space12),
                        child: thumbnailWidgets != null && index < thumbnailWidgets!.length
                            ? thumbnailWidgets![index]
                            : _buildPlaceholderBox(),
                      );
                    },
                  ),
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTokens.textSecondary,
                    size: 24,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderBox() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5DB).withValues(alpha: 0.6),
        borderRadius: AppTokens.radiusMd,
      ),
    );
  }
}

