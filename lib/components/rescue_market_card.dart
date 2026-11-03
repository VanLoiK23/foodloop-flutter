import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Thẻ hiển thị giỏ quà / thực phẩm cứu trợ trong "Chợ giải cứu" (Màn 61)
class RescueMarketCard extends StatelessWidget {
  final String title;
  final String store;
  final String distance;
  final String originalPrice;
  final String discountedPrice;
  final String? savings;
  final String? remainingTime;
  final String? pickupTime;
  final String? imageUrl;
  final Widget? leading;
  final VoidCallback? onTap;

  const RescueMarketCard({
    super.key,
    required this.title,
    required this.store,
    required this.distance,
    required this.originalPrice,
    required this.discountedPrice,
    this.savings,
    this.remainingTime,
    this.pickupTime,
    this.imageUrl,
    this.leading,
    this.onTap,
  });

  Widget _buildDefaultImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(
          Icons.shopping_basket_rounded,
          color: AppTokens.brand,
          size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTokens.space12),
        padding: const EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          color: AppTokens.surface,
          borderRadius: AppTokens.radiusLg,
          border: Border.all(
            color: AppTokens.border.withValues(alpha: 0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Icon / Ảnh đại diện bên trái
            leading ??
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: (imageUrl != null && imageUrl!.trim().isNotEmpty)
                      ? Image.network(
                          imageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultImage(),
                        )
                      : _buildDefaultImage(),
                ),

            const SizedBox(width: AppTokens.space14),

            // 2. Nội dung chi tiết
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên giỏ hàng
                  Text(
                    title,
                    style: AppTokens.headingLarge.copyWith(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Cửa hàng & Khoảng cách
                  Text(
                    '$store · $distance',
                    style: AppTokens.subtitle.copyWith(
                      fontSize: 13.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Giá gốc -> Giá giảm
                  Row(
                    children: [
                      Text(
                        originalPrice,
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: AppTokens.textSecondary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppTokens.textSecondary,
                        ),
                      ),
                      const Text(
                        ' → ',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                      Text(
                        discountedPrice,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Tiết kiệm
                  if (savings != null && savings!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      savings!,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Thời gian còn lại & Khung giờ nhận
                  if ((remainingTime != null && remainingTime!.isNotEmpty) ||
                      (pickupTime != null && pickupTime!.isNotEmpty)) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTokens.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          [
                            if (remainingTime != null && remainingTime!.isNotEmpty)
                              remainingTime!,
                            if (pickupTime != null && pickupTime!.isNotEmpty)
                              'Nhận $pickupTime',
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: AppTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

