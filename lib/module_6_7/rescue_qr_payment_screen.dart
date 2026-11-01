import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../theme/app_tokens.dart';

/// Màn hình 68: "Thanh toán QR" (Module 6 & 7)
class RescueQRPaymentScreen extends StatelessWidget {
  final int amount;

  const RescueQRPaymentScreen({
    super.key,
    this.amount = 45000,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 3, // Tab Túi hàng / Chợ active theo thiết kế Màn 68
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình
            ScreenHeader(
              title: 'Thanh toán QR',
              subtitle: 'Quét mã để thanh toán giỏ giải cứu.',
            ),

            // 2. Nội dung cuộn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                child: Column(
                  children: [
                    // Card 1: Khối mã QR & Số tiền
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTokens.space20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Tổng thanh toán',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: AppTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '45.000 đ',
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.brand,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Khung mã QR giả lập chuẩn thiết kế
                          Container(
                            width: 220,
                            height: 220,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTokens.border.withValues(alpha: 0.8),
                                width: 1.0,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(196, 196),
                                  painter: _QrPatternPainter(),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTokens.brand,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Text(
                                    'MẪU',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppTokens.brand,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'MÃ QR',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Card 2: Hướng dẫn cách thanh toán
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.crop_free_rounded,
                                color: AppTokens.brand,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Cách thanh toán',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppTokens.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '1. Mở ứng dụng ngân hàng, chọn quét QR.\n2. Quét mã hoặc chọn ảnh đã lưu.\n3. Kiểm tra số tiền trước khi xác nhận.',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppTokens.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Ghi chú bảo mật
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: AppTokens.textSecondary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mã này không chứa tài khoản nhận tiền. Đây là giao diện minh họa, chưa kết nối thanh toán.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTokens.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTokens.space24),

                    // Nút chính: "Lưu mã QR minh họa"
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã lưu mã QR minh họa vào bộ sưu tập ảnh!'),
                              backgroundColor: AppTokens.brand,
                            ),
                          );
                        },
                        child: const Text(
                          'Lưu mã QR minh họa',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space12),

                    // Nút phụ: "Chọn phương thức khác"
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Chọn phương thức khác',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.brand,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter vẽ hoa văn QR mô phỏng chuẩn xác
class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final cell = size.width / 13;

    // 3 góc lớn định vị QR
    void drawCorner(double x, double y) {
      // Viền ngoài
      canvas.drawRect(Rect.fromLTWH(x, y, cell * 3.5, cell * 3.5), paintDark);
      // Ruột trắng
      canvas.drawRect(
        Rect.fromLTWH(x + cell * 0.7, y + cell * 0.7, cell * 2.1, cell * 2.1),
        Paint()..color = Colors.white,
      );
      // Điểm tâm đen
      canvas.drawRect(
        Rect.fromLTWH(x + cell * 1.2, y + cell * 1.2, cell * 1.1, cell * 1.1),
        paintDark,
      );
    }

    drawCorner(0, 0); // Góc trên trái
    drawCorner(size.width - cell * 3.5, 0); // Góc trên phải
    drawCorner(0, size.height - cell * 3.5); // Góc dưới trái

    // Các điểm dữ liệu ngẫu nhiên mô phỏng QR
    final List<List<int>> matrix = [
      [5, 1], [6, 1], [7, 1],
      [5, 2], [7, 2],
      [4, 4], [5, 4], [8, 4], [9, 4],
      [4, 5], [6, 5], [8, 5], [10, 5],
      [1, 5], [2, 5], [11, 5], [12, 5],
      [4, 7], [8, 7], [9, 7],
      [5, 8], [7, 8], [11, 8],
      [4, 9], [6, 9], [8, 9], [10, 9],
      [5, 10], [7, 10], [9, 10],
      [5, 11], [6, 11], [8, 11],
      [9, 11], [10, 11], [11, 11],
    ];

    for (final p in matrix) {
      final x = p[0] * cell;
      final y = p[1] * cell;
      canvas.drawRect(Rect.fromLTWH(x, y, cell * 0.9, cell * 0.9), paintDark);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

