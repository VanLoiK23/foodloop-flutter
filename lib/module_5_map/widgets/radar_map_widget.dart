import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../models/food_post_model.dart';

class RadarMapWidget extends StatelessWidget {
  final List<FoodPost> posts;
  final FoodPost? selectedPost;
  final Function(FoodPost) onPostSelected;

  const RadarMapWidget({
    super.key,
    required this.posts,
    this.selectedPost,
    required this.onPostSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            // 1. Nền bản đồ giả lập các khối phố & đường xá
            Positioned.fill(
              child: CustomPaint(
                painter: _MapGridPainter(),
              ),
            ),

            // 2. Vòng tròn Radar quét bán kính
            Positioned.fill(
              child: CustomPaint(
                painter: _RadarCirclesPainter(),
              ),
            ),

            // 3. Vị trí trung tâm (Người dùng)
            Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.brand.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // 4. Các điểm ghim bài đăng thực phẩm
            ...posts.map((post) {
              final isSelected = selectedPost?.id == post.id;
              final posX = width * post.xPercent - 20;
              final posY = height * post.yPercent - 20;

              return Positioned(
                left: posX.clamp(16.0, width - 56.0),
                top: posY.clamp(16.0, height - 56.0),
                child: GestureDetector(
                  onTap: () => onPostSelected(post),
                  child: _buildPin(post, isSelected),
                ),
              );
            }),

            // 5. Chú thích phân loại (Legend) ở góc dưới bên trái
            Positioned(
              left: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.brand,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Đang cho',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.title,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Cần xin',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.title,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 6. Nút dấu cộng Floating action (+) ở góc dưới bên phải
            Positioned(
              right: 16,
              bottom: 24,
              child: GestureDetector(
                onTap: () {
                  // Chuyển sang thêm bài chia sẻ hoặc thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đăng tin chia sẻ thực phẩm mới'),
                      backgroundColor: AppColors.brand,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: AppColors.title, size: 28),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPin(FoodPost post, bool isSelected) {
    final isGiving = post.type == 'Cho';
    final primaryColor = isGiving ? AppColors.brand : AppColors.accent;

    IconData icon;
    switch (post.iconType) {
      case 'bread':
        icon = Icons.bakery_dining_outlined;
        break;
      case 'milk':
        icon = Icons.local_drink_outlined;
        break;
      case 'egg':
        icon = Icons.egg_outlined;
        break;
      case 'vegetable':
        icon = Icons.eco_outlined;
        break;
      case 'meat':
        icon = Icons.restaurant_outlined;
        break;
      default:
        icon = Icons.storefront_outlined;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? 48 : 40,
      height: isSelected ? 48 : 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryColor,
          width: isSelected ? 3.0 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isSelected ? 0.45 : 0.25),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: isSelected ? 24 : 20,
          color: primaryColor,
        ),
      ),
    );
  }
}

/// Vẽ bản đồ khối phố giả lập nhẹ nhàng
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Màu nền bản đồ xanh lục nhạt
    final bgPaint = Paint()..color = const Color(0xFFEFF5ED);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Màu đường xá màu trắng
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Đường chính ngang và chéo
    canvas.drawLine(
      Offset(-20, size.height * 0.35),
      Offset(size.width + 20, size.height * 0.28),
      roadPaint,
    );

    canvas.drawLine(
      Offset(-20, size.height * 0.72),
      Offset(size.width + 20, size.height * 0.68),
      roadPaint,
    );

    // Đường dọc
    canvas.drawLine(
      Offset(size.width * 0.28, -20),
      Offset(size.width * 0.32, size.height + 20),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.75, -20),
      Offset(size.width * 0.68, size.height + 20),
      roadPaint,
    );

    // Đường ngách mỏng
    final minorRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.1),
      Offset(size.width * 0.85, size.height * 0.9),
      minorRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      minorRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vẽ các vòng tròn radar đồng tâm và đường nét đứt
class _RadarCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.42;

    final circlePaint = Paint()
      ..color = AppColors.brand.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // 3 vòng tròn đồng tâm
    canvas.drawCircle(center, maxRadius * 0.38, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.70, circlePaint);
    canvas.drawCircle(center, maxRadius, circlePaint);

    // Đường bán kính dạng nét đứt hoặc mờ
    final linePaint = Paint()
      ..color = AppColors.brand.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
