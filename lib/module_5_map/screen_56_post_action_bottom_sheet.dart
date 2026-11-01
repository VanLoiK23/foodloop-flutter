import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'models/food_post_model.dart';

/// Màn 56 - Menu hành động bài đăng (Figma Frame 7)
class Screen56PostActionBottomSheet extends StatelessWidget {
  final FoodPost post;

  const Screen56PostActionBottomSheet({super.key, required this.post});

  static void show(BuildContext context, FoodPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Screen56PostActionBottomSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Bài đăng của ${post.giverName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 16),

            // Option 1: Xem chi tiết bài đăng
            ListTile(
              leading: const Icon(Icons.remove_red_eye_outlined, color: AppColors.brand),
              title: const Text('Xem chi tiết bài đăng', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.gray),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/food-detail', arguments: post);
              },
            ),

            const Divider(height: 1, color: AppColors.border),

            // Option 2: Báo cáo bài đăng
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: AppColors.danger),
              title: const Text(
                'Báo cáo bài đăng',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.gray),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi báo cáo bài đăng tới ban quản trị'),
                    backgroundColor: AppColors.brand,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
