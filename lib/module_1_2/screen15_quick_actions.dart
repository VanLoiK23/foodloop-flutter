 
import 'package:flutter/material.dart';

import '../app_theme.dart';

class Screen15 extends StatelessWidget {
  const Screen15({super.key});

  // =========================
  // MÀU SẮC
  // =========================

  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color textColor = Color(0xFF2B3A35);
  static const Color hintColor = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFFFF8E7);
  static const Color fabColor = Color(0xFFF4B942);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =========================
      // NỘI DUNG MÀN HÌNH
      // =========================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // =========================
              // 1. HEADER
              // =========================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Nút quay lại
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: textColor,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Tiêu đề
                    const Text(
                      'Thao tác nhanh',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // 2. NỘI DUNG CÓ THỂ CUỘN
              // =========================

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                  ),
                  child: Column(
                    children: [
                      // =========================
                      // 3. LỜI GỢI Ý
                      // =========================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Bạn muốn làm gì?',
                            style: TextStyle(
                              color: Color(0xFFD64545),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // =========================
                      // 4. CARD QUÉT HÓA ĐƠN / MÃ VẠCH
                      // =========================

                      _buildActionCard(
                        icon: Icons.qr_code_scanner,
                        title: 'Quét hóa đơn / mã vạch',
                        description: 'Thêm thực phẩm nhanh',
                        buttonText: 'Quét ngay',
                        onPressed: () {
                          Navigator.pushNamed(context, '/import-product');
                        },
                      ),

                      const SizedBox(height: 13),

                      // =========================
                      // 5. CARD THÊM THỰC PHẨM
                      // =========================

                      _buildActionCard(
                        icon: Icons.add_box_outlined,
                        title: 'Thêm thực phẩm thủ công',
                        description: 'Nhập thông tin món đồ',
                        buttonText: 'Thêm ngay',
                        onPressed: () {
                          Navigator.pushNamed(context, '/add-product');
                        },
                      ),

                      const SizedBox(height: 13),

                      // =========================
                      // 6. CARD CÔNG THỨC
                      // =========================

                      _buildActionCard(
                        icon: Icons.menu_book_outlined,
                        title: 'Công thức Vét tủ lạnh',
                        description: 'Nấu từ thực phẩm có sẵn',
                        buttonText: 'Vào ngay',
                        onPressed: () {
                          Navigator.pushNamed(context, '/virtual-fridge');
                        },
                      ),

                      const SizedBox(height: 13),

                      // =========================
                      // 7. CARD CHIA SẺ THỰC PHẨM
                      // =========================

                      _buildActionCard(
                        icon: Icons.ios_share_outlined,
                        title: 'Chia sẻ thực phẩm',
                        description: 'Cho đi món sắp hết hạn',
                        buttonText: 'Chia sẻ ngay',
                        onPressed: () {
                          Navigator.pushNamed(context, '/rescue-market');
                        },
                      ),

                      // Khoảng trống phía dưới để không bị FAB che
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // =========================
      // 8. NÚT THÊM NỔI
      // =========================

      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: fabColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add-product');
          },
          icon: const Icon(
            Icons.add,
            color: textColor,
            size: 28,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      // =========================
      // 9. NAVBAR CHUẨN FOODLOOP
      // =========================

      bottomNavigationBar: const FoodLoopBottomNav(
        currentIndex: 0,
      ),
    );
  }

  // =========================
  // CARD THAO TÁC
  // =========================

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        12,
        12,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFD9D9D9),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // =========================
          // ICON + THÔNG TIN
          // =========================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 10),

              // Tiêu đề + mô tả
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: hintColor,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // =========================
          // NÚT HÀNH ĐỘNG
          // =========================

          SizedBox(
            width: double.infinity,
            height: 26,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 