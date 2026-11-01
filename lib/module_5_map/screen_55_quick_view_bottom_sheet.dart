import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'models/food_post_model.dart';

/// Màn 55 - Xem nhanh bài đăng (Figma Frame 5)
class Screen55QuickViewBottomSheet extends StatelessWidget {
  final FoodPost post;
  final VoidCallback onViewDetail;

  const Screen55QuickViewBottomSheet({
    super.key,
    required this.post,
    required this.onViewDetail,
  });

  static void show(BuildContext context, FoodPost post, VoidCallback onViewDetail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Screen55QuickViewBottomSheet(
        post: post,
        onViewDetail: onViewDetail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGiving = post.type == 'Cho';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh gạt (Drag Handle)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header món ăn & Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8DFB8)),
                ),
                child: Center(
                  child: Icon(
                    _getIcon(post.iconType),
                    color: AppColors.brand,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.quantityTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Chip trạng thái Cho / Xin
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isGiving ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.type,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isGiving ? AppColors.brand : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Chip hạn sử dụng
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 12, color: Color(0xFFF57F17)),
                              const SizedBox(width: 4),
                              Text(
                                post.badge,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF57F17),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Thông tin khoảng cách & khung giờ nhận
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.gray),
              const SizedBox(width: 4),
              Text(
                post.distanceText,
                style: const TextStyle(fontSize: 13, color: AppColors.gray),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined, size: 16, color: AppColors.gray),
              const SizedBox(width: 4),
              Text(
                post.pickupTime,
                style: const TextStyle(fontSize: 13, color: AppColors.gray),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),

          // Thông tin người cho
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.brand,
                child: Text(
                  post.giverAvatar,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.giverName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.title,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '${post.giverRating} · ${post.giverShares} lượt chia sẻ',
                        style: const TextStyle(fontSize: 12, color: AppColors.gray),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Nút bấm chính: Xem chi tiết
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onViewDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Xem chi tiết',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
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
