import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component AchievementBadgeCard hiển thị thẻ huy hiệu thành tựu
/// Hỗ trợ cả hai trạng thái: Đã mở khóa (Unlocked - cúp xanh) và Đang thực hiện (In Progress - ổ khóa)
class AchievementBadgeCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isUnlocked;
  final double progress; // Giá trị từ 0.0 đến 1.0
  final String progressText;
  final IconData? unlockedIcon;
  final VoidCallback? onTap;

  const AchievementBadgeCard({
    super.key,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.progress,
    required this.progressText,
    this.unlockedIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.radiusLg,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: AppTokens.radiusLg,
            border: Border.all(
              color: AppTokens.border,
              width: 1.0,
            ),
            boxShadow: AppTokens.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hàng tiêu đề gồm Icon tròn + Tên huy hiệu
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? const Color(0xFFDCFCE7) // Xanh lục pastel dịu mắt
                          : const Color(0xFFF1F5F9), // Xám nhạt pastel khi khóa
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isUnlocked
                            ? (unlockedIcon ?? Icons.emoji_events_outlined)
                            : Icons.lock_outline_rounded,
                        color: isUnlocked
                            ? AppTokens.brand
                            : AppTokens.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTokens.headingMedium.copyWith(
                        fontSize: 15.5,
                        color: AppTokens.title,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTokens.space12),

              // 2. Mô tả nhiệm vụ / điều kiện đạt huy hiệu
              Text(
                description,
                style: AppTokens.bodyRegular.copyWith(
                  color: AppTokens.body,
                  fontSize: 13.0,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: AppTokens.space10),

              // 3. Nhãn trạng thái (Đã mở khóa / Chưa mở khóa)
              Text(
                isUnlocked ? 'Đã mở khóa' : 'Chưa mở khóa',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked
                      ? AppTokens.brand
                      : AppTokens.textSecondary,
                ),
              ),

              const SizedBox(height: AppTokens.space8),

              // 4. Thanh tiến độ tiến trình (Linear progress bar)
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: clampedProgress,
                  minHeight: 5.0,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUnlocked
                        ? AppTokens.brand
                        : AppTokens.brand.withValues(alpha: 0.9),
                  ),
                ),
              ),

              const SizedBox(height: AppTokens.space8),

              // 5. Chỉ số tiến độ (Ví dụ: 1/1 lần, 10/10 kg, 3/5 lần,...)
              Text(
                progressText,
                style: AppTokens.caption.copyWith(
                  color: AppTokens.textSecondary,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

