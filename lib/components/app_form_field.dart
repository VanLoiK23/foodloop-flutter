import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component FormField dùng chung cho các ô nhập liệu hoặc ô chọn Dropdown
class AppFormField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final bool isDropdown;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final ValueChanged<String?>? onDropdownChanged;
  final ValueChanged<String>? onTextChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int minLines;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppFormField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.isDropdown = false,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
    this.onTextChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTokens.headingMedium.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTokens.space8),
        ],
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: AppTokens.radiusMd,
            border: Border.all(
              color: AppTokens.border,
              width: 1.0,
            ),
          ),
          child: isDropdown ? _buildDropdown(context) : _buildTextField(),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppTokens.space6),
          Text(
            helperText!,
            style: AppTokens.caption,
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton<String>(
          value: dropdownValue,
          isExpanded: true,
          icon: suffixIcon ??
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTokens.textSecondary,
                size: 24,
              ),
          style: AppTokens.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
          borderRadius: AppTokens.radiusMd,
          items: dropdownItems?.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList() ??
              [],
          onChanged: onDropdownChanged,
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onTextChanged,
      style: AppTokens.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTokens.subtitle.copyWith(
          color: AppTokens.textSecondary.withValues(alpha: 0.8),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
      ),
    );
  }
}

