import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component ConfirmationCheckbox cho hàng chọn xác nhận kèm nhãn văn bản
/// Hỗ trợ cả hiển thị dạng phẳng (inline) và dạng thẻ đóng khung (card style)
class ConfirmationCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  final TextStyle? textStyle;
  final bool isCardStyle;
  final EdgeInsetsGeometry? padding;

  const ConfirmationCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
    this.textStyle,
    this.isCardStyle = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              activeColor: AppTokens.brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              side: const BorderSide(
                color: AppTokens.textSecondary,
                width: 1.5,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: AppTokens.space12),
        Expanded(
          child: Text(
            text,
            style: textStyle ??
                AppTokens.bodyRegular.copyWith(
                  color: AppTokens.title,
                  fontSize: 14.5,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );

    if (isCardStyle) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: AppTokens.radiusLg,
          child: Container(
            width: double.infinity,
            padding: padding ?? const EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: AppTokens.surface,
              borderRadius: AppTokens.radiusLg,
              border: Border.all(
                color: value ? AppTokens.brand.withValues(alpha: 0.3) : AppTokens.border,
                width: 1.0,
              ),
              boxShadow: AppTokens.cardShadow,
            ),
            child: content,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
