import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'widgets/radar_map_widget.dart';
import 'services/food_service.dart';

/// Màn 55 - Xin quyền vị trí (Figma Frame 1)
class Screen55PermissionRequest extends StatelessWidget {
  const Screen55PermissionRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Nền bản đồ mờ phía sau
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: RadarMapWidget(
                posts: FoodService.defaultPosts,
                onPostSelected: (_) {},
              ),
            ),
          ),

          // Lớp phủ tối nhẹ (dim overlay)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),

          // Thẻ Dialog xin cấp quyền vị trí ở trung tâm
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: AppColors.brand, size: 30),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Cho phép truy cập vị trí',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'FoodLoop dùng vị trí để hiển thị thực phẩm đang được chia sẻ quanh bạn. Địa chỉ chính xác của bạn không bao giờ hiển thị công khai.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Chuyển sang Màn 55 - Bị từ chối quyền
                              Navigator.pushReplacementNamed(context, '/permission-denied');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.gray,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Từ chối'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Cấp quyền -> Chuyển vào Màn 55 - Bản đồ radar
                              Navigator.pushReplacementNamed(context, '/map');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brand,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Tiếp tục'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 2),
    );
  }
}
