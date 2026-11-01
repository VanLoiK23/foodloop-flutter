import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

enum StepStateStatus { completed, inProgress, pending }

class TimelineStepData {
  final String title;
  final String subtitle;
  final StepStateStatus status;

  const TimelineStepData({
    required this.title,
    required this.subtitle,
    required this.status,
  });
}

/// Component ProcessTimelineCard hiển thị tiến trình từng bước theo thiết kế Figma
class ProcessTimelineCard extends StatelessWidget {
  final List<TimelineStepData> steps;

  const ProcessTimelineCard({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cột icon chỉ thị trạng thái và đường nối dọc
                Column(
                  children: [
                    _buildStepIcon(step.status),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 2.0),
                          color: step.status == StepStateStatus.completed
                              ? AppTokens.brandLight
                              : AppTokens.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppTokens.space12),

                // Nội dung tiêu đề và trạng thái của bước
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0.0 : AppTokens.space20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Text(
                          step.subtitle,
                          style: AppTokens.caption.copyWith(
                            color: _getStatusTextColor(step.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepIcon(StepStateStatus status) {
    switch (status) {
      case StepStateStatus.completed:
        return const Icon(
          Icons.check_circle_outline_rounded,
          color: AppTokens.brand,
          size: 22,
        );
      case StepStateStatus.inProgress:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTokens.info,
              width: 2.0,
            ),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTokens.info,
              ),
            ),
          ),
        );
      case StepStateStatus.pending:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTokens.border,
              width: 1.8,
            ),
          ),
        );
    }
  }

  Color _getStatusTextColor(StepStateStatus status) {
    switch (status) {
      case StepStateStatus.completed:
        return AppTokens.brand;
      case StepStateStatus.inProgress:
        return AppTokens.info;
      case StepStateStatus.pending:
        return AppTokens.textSecondary;
    }
  }
}

