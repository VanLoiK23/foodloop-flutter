import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component SelectionGroupCard hiển thị nhóm lựa chọn Radio trong một thẻ trắng bo góc
class SelectionGroupCard extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onChanged;
  final String? helperText;

  const SelectionGroupCard({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.helperText,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề nhóm
          Text(
            title,
            style: AppTokens.headingMedium.copyWith(
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: AppTokens.space12),

          // Danh sách các lựa chọn radio
          ...options.map((option) {
            final isSelected = option == selectedValue;
            return InkWell(
              onTap: () => onChanged(option),
              borderRadius: AppTokens.radiusMd,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTokens.space10),
                child: Row(
                  children: [
                    // Radio Icon tùy biến theo design Figma
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppTokens.brand : AppTokens.textSecondary,
                          width: isSelected ? 2.2 : 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTokens.brand,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      child: Text(
                        option,
                        style: AppTokens.bodyMedium.copyWith(
                          color: AppTokens.title,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          if (helperText != null) ...[
            const SizedBox(height: AppTokens.space6),
            Text(
              helperText!,
              style: AppTokens.caption,
            ),
          ],
        ],
      ),
    );
  }
}

