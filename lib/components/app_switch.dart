import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component AppSwitch hiển thị công tắc gạt theo chuẩn thiết kế Figma
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 48.0;
    const double height = 28.0;
    const double circleSize = 22.0;

    final effectiveActive = activeColor ?? AppTokens.brand;
    final effectiveInactive = inactiveColor ?? AppTokens.border;

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: value ? effectiveActive : effectiveInactive,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 3.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

