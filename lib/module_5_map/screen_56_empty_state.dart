import 'package:flutter/material.dart';
import '../../app_theme.dart';

/// Màn 56 - Không có kết quả phù hợp (Figma Frame 8 & 9)
class Screen56EmptyState extends StatefulWidget {
  const Screen56EmptyState({super.key});

  @override
  State<Screen56EmptyState> createState() => _Screen56EmptyStateState();
}

class _Screen56EmptyStateState extends State<Screen56EmptyState> {
  bool _filterCleared = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quanh bạn',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_outlined, color: AppColors.title),
                    onPressed: () {
                      Navigator.pushNamed(context, '/food-list');
                    },
                  ),
                ],
              ),
            ),

            // Toggle Bản đồ / Danh sách
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pushReplacementNamed(context, '/map'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 16, color: AppColors.gray),
                              SizedBox(width: 6),
                              Text(
                                'Bản đồ',
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Danh sách',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Các tags lọc đang kích hoạt (500m, Thịt cá, Cho)
            if (!_filterCleared)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildActiveChip('500 m'),
                    const SizedBox(width: 8),
                    _buildActiveChip('Thịt cá'),
                    const SizedBox(width: 8),
                    _buildActiveChip('Cho'),
                  ],
                ),
              ),

            // Nội dung Empty State
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF8E7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search, size: 36, color: AppColors.accent),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Chưa có bài đăng phù hợp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.title,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Thử mở rộng khoảng cách hoặc bỏ bớt bộ lọc để xem thêm.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nút 1: Xóa bộ lọc
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _filterCleared = true);
                            Navigator.pushReplacementNamed(context, '/food-list');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brand,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Xóa bộ lọc', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Nút 2: Mở rộng lên 2 km
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/food-list');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Mở rộng lên 2 km',
                            style: TextStyle(color: AppColors.title, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Nút Floating (+)
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.title,
        elevation: 3,
        shape: const CircleBorder(),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng thực phẩm mới lên cộng đồng')),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 2),
    );
  }

  Widget _buildActiveChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 14, color: AppColors.brand),
        ],
      ),
    );
  }
}
