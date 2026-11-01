import 'package:flutter/material.dart';
import '../../app_theme.dart';

/// Màn 55 - Bị từ chối quyền truy cập vị trí (Figma Frame 2)
class Screen55PermissionDenied extends StatelessWidget {
  const Screen55PermissionDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Quanh bạn',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.title,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Biểu tượng từ chối quyền vị trí
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  size: 40,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chưa có quyền truy cập vị trí',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.title,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bạn có thể bật lại trong Cài đặt, hoặc tự chọn khu vực để xem thực phẩm gần đó.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // Nút 1: Mở Cài đặt
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Giả lập mở cài đặt và cấp quyền -> vào map
                    Navigator.pushReplacementNamed(context, '/map');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mở Cài đặt',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nút 2: Chọn khu vực thủ công
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Chọn khu vực thủ công -> vào map
                    Navigator.pushReplacementNamed(context, '/map');
                  },
                  icon: const Icon(Icons.search, size: 18, color: AppColors.brand),
                  label: const Text(
                    'Chọn khu vực thủ công',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.brand),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 2),
    );
  }
}
