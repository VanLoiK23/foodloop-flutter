import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component TrustScoreCard hiển thị điểm tin cậy của thành viên theo chuẩn Figma FoodLoop
class TrustScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final int maxScore;
  final VoidCallback? onTap;

  const TrustScoreCard({
    super.key,
    this.title = 'Điểm tin cậy',
    required this.score,
    this.maxScore = 100,
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
          padding: const EdgeInsets.all(AppTokens.space20),
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
              Text(
                title,
                style: AppTokens.headingMedium.copyWith(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: AppTokens.space8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.brand,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    ' / $maxScore',
                    style: AppTokens.subtitle.copyWith(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

