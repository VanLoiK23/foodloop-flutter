import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component ReceivedStickerPill hiển thị viên thuốc nhãn dán lời cảm ơn đã nhận
/// Hình dạng con thoi (pill / stadium) bo tròn hai đầu viền xanh, icon trái tim trao gửi và dấu tích xanh
class ReceivedStickerPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const ReceivedStickerPill({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.radiusFull,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space16,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4), // Nền xanh bạc hà nhạt pastel
            borderRadius: AppTokens.radiusFull,
            border: Border.all(
              color: const Color(0xFF86EFAC), // Viền xanh lá mềm
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Icon biểu trưng trao gửi yêu thương
              Icon(
                icon ?? Icons.volunteer_activism_outlined,
                color: const Color(0xFF166534), // Xanh lá rừng đậm
                size: 20,
              ),
              const SizedBox(width: AppTokens.space10),

              // Nhãn nội dung cảm ơn
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                  ),
                ),
              ),

              // Dấu tích hoàn thành bên phải
              const Icon(
                Icons.check_rounded,
                color: Color(0xFF166534),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

