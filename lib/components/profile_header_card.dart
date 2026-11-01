import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Component ProfileHeaderCard hiển thị avatar biểu trưng, tên và thâm niên thành viên
class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String caption;
  final Widget? avatar;
  final VoidCallback? onTap;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.caption,
    this.avatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar hình vuông bo góc mang biểu trưng FoodLoop
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xFF283E1E), // Xanh lá đậm thương hiệu FoodLoop
              child: avatar ??
                  const Center(
                    child: Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: AppTokens.space16),
          // Thông tin tên và thâm niên
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTokens.headingLarge.copyWith(
                    fontSize: 18.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  caption,
                  style: AppTokens.subtitle.copyWith(
                    fontSize: 13.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

