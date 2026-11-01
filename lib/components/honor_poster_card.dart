import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component HonorPosterCard hiển thị tấm thẻ vinh danh tác động xanh
/// Hỗ trợ thay đổi màu nền động theo kiểu thẻ người dùng chọn (Xanh mint, Trắng, Kem)
class HonorPosterCard extends StatelessWidget {
  final String userName;
  final String monthYear;
  final String preventedWaste;
  final String reducedCo2;
  final String savedMoney;
  final Color backgroundColor;
  final Widget? avatar;

  const HonorPosterCard({
    super.key,
    required this.userName,
    required this.monthYear,
    required this.preventedWaste,
    required this.reducedCo2,
    required this.savedMoney,
    this.backgroundColor = const Color(0xFFE8F5E9), // Mặc định xanh mint dịu mát
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppTokens.border.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: AppTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tiêu đề thương hiệu và thời gian
          Text(
            'FoodLoop',
            style: AppTokens.headingMedium.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: AppTokens.title,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            monthYear,
            style: AppTokens.caption.copyWith(
              color: AppTokens.textSecondary,
              fontSize: 12.0,
            ),
          ),

          const SizedBox(height: AppTokens.space20),

          // 2. Avatar biểu trưng FoodLoop ở trung tâm
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                width: 76,
                height: 76,
                color: const Color(0xFF283E1E), // Xanh lá thẫm thương hiệu FoodLoop
                child: avatar ??
                    const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
              ),
            ),
          ),

          const SizedBox(height: AppTokens.space16),

          // 3. Tiêu đề tôn vinh đóng góp
          Center(
            child: Text(
              '$userName đã góp phần\ngiảm lãng phí thực phẩm',
              textAlign: TextAlign.center,
              style: AppTokens.headingLarge.copyWith(
                fontSize: 19.0,
                fontWeight: FontWeight.w700,
                color: AppTokens.title,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: AppTokens.space20),

          // 4. Khối 3 thẻ số liệu tác động màu trắng
          _buildMetricCard(
            label: 'Rác thải ngăn chặn',
            value: preventedWaste,
            unit: 'kg',
          ),
          const SizedBox(height: AppTokens.space12),

          _buildMetricCard(
            label: 'CO₂e giảm',
            value: reducedCo2,
            unit: 'kg',
          ),
          const SizedBox(height: AppTokens.space12),

          _buildMetricCard(
            label: 'Tiết kiệm',
            value: savedMoney,
            unit: 'đ',
          ),

          const SizedBox(height: AppTokens.space16),

          // 5. Dòng ghi chú phương pháp ước tính
          Center(
            child: Text(
              'Số liệu ước tính theo phương pháp của FoodLoop.',
              style: AppTokens.caption.copyWith(
                color: AppTokens.textSecondary,
                fontSize: 11.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space14,
      ),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: AppTokens.radiusLg,
        border: Border.all(
          color: AppTokens.border.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTokens.bodyRegular.copyWith(
              color: AppTokens.body,
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: AppTokens.space6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.brand,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: AppTokens.space4),
              Text(
                unit,
                style: AppTokens.subtitle.copyWith(
                  fontSize: 14.0,
                  color: AppTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

