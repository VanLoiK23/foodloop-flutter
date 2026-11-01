import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'models/food_post_model.dart';
import 'services/food_service.dart';

class Screen57FoodDetail extends StatelessWidget {
  final FoodPost? initialPost;

  const Screen57FoodDetail({super.key, this.initialPost});

  @override
  Widget build(BuildContext context) {
    // Lấy argument truyền qua Navigator hoặc dùng fallback
    final post = initialPost ??
        (ModalRoute.of(context)?.settings.arguments as FoodPost?) ??
        FoodService.defaultPosts.first;

    final isGiving = post.type == 'Cho';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.title),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.title,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.title),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tùy chọn bài đăng')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ Ảnh thực tế & Banner minh họa
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF6E7B0),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Tag "Ảnh thực tế" góc trên bên trái
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Ảnh thực tế',
                            style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Chỉ số ảnh "1/2" góc dưới bên phải
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '1/2',
                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // Icon minh họa chính ở giữa
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          _getIcon(post.iconType),
                          size: 50,
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Thẻ thông tin bài đăng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.quantityTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGiving ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isGiving ? 'Cho · Miễn phí' : 'Cần xin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isGiving ? AppColors.brand : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          post.badge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF57F17),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _buildDetailRow(Icons.near_me_outlined, post.distanceText),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.access_time_outlined, 'Nhận hôm nay · ${post.pickupTime}'),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.task_alt_outlined, post.condition),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Thẻ thông tin người đăng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.brand,
                    child: Text(
                      post.giverAvatar,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.giverName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.title,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${post.giverRating} · ${post.giverShares} lượt chia sẻ',
                              style: const TextStyle(fontSize: 12, color: AppColors.gray),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: AppColors.brand),
                        SizedBox(width: 4),
                        Text(
                          'Đã xác minh',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 4. Thẻ Vị trí nhận hàng (Bảo mật ẩn danh)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.pin_drop, color: AppColors.brand, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock_outline, size: 14, color: AppColors.gray),
                            SizedBox(width: 4),
                            Text(
                              'Địa chỉ nhận',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.title,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Địa chỉ chính xác hiện sau khi được duyệt',
                          style: TextStyle(fontSize: 12, color: AppColors.gray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Nút CTA: "Xin nhận thực phẩm"
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/food-request',
                    arguments: post,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Xin nhận thực phẩm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.brand),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.title,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'bread':
        return Icons.bakery_dining_outlined;
      case 'milk':
        return Icons.local_drink_outlined;
      case 'egg':
        return Icons.egg_outlined;
      case 'vegetable':
        return Icons.eco_outlined;
      case 'meat':
        return Icons.restaurant_outlined;
      default:
        return Icons.storefront_outlined;
    }
  }
}
