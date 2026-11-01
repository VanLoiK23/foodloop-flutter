import 'package:flutter/material.dart';
import '../../app_theme.dart';

/// Màn 55 - Bản đồ radar (Cài đặt BottomSheet - Figma Frame 4)
class Screen55SettingsBottomSheet extends StatelessWidget {
  const Screen55SettingsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const Screen55SettingsBottomSheet(),
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
            const Text(
              'Cài đặt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 16),

            // Option 1: Xem yêu cầu của tôi
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: AppColors.brand),
              title: const Text('Xem yêu cầu của tôi', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.gray),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-requests');
              },
            ),

            const Divider(height: 1, color: AppColors.border),

            // Option 2: Xin lại quyền vị trí
            ListTile(
              leading: const Icon(Icons.my_location_outlined, color: AppColors.accent),
              title: const Text('Xin lại quyền vị trí', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.gray),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/permission-request');
              },
            ),
          ],
        ),
      ),
    );
  }
}
