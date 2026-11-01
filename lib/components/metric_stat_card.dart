import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component MetricStatCard hiển thị thẻ thống kê chỉ số tác động
/// Gồm tiêu đề, giá trị nổi bật màu thương hiệu, đơn vị và phụ đề chu kỳ
class MetricStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final VoidCallback? onTap;

  const MetricStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTokens.bodyRegular.copyWith(
                  color: AppTokens.body,
                  fontSize: 13.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTokens.space8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26.0,
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space6),
              Text(
                subtitle,
                style: AppTokens.caption.copyWith(
                  color: AppTokens.textSecondary,
                  fontSize: 12.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

