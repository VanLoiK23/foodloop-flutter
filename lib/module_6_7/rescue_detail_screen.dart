import 'package:flutter/material.dart';
import '../components/screen_header.dart';
import '../theme/app_tokens.dart';

/// Màn hình 63: "Chi tiết sản phẩm / Chi tiết giỏ rau củ" (Module 6 & 7)
class RescueDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const RescueDetailScreen({
    super.key,
    this.productData,
  });

  @override
  State<RescueDetailScreen> createState() => _RescueDetailScreenState();
}

class _RescueDetailScreenState extends State<RescueDetailScreen> {
  int _quantity = 1;
  late final Map<String, dynamic> _product;

  // Dữ liệu mẫu chuẩn Màn 63 theo thiết kế Figma
  static const Map<String, dynamic> _defaultProduct = {
    'title': 'Giỏ rau củ cuối ngày',
    'store': 'Rau Sạch Xanh',
    'distance': '350m',
    'discountedPrice': 45000,
    'originalPrice': 80000,
    'expiryHint': 'Dùng trong 2 ngày',
    'description':
        'Giỏ rau củ cuối ngày từ Rau Sạch Xanh với giá ưu đãi. Ưu tiên dùng sớm để tránh lãng phí.',
    'pickupWindow': '18:00–19:30',
  };

  @override
  void initState() {
    super.initState();
    _product = widget.productData ?? _defaultProduct;
  }

  void _increaseQuantity() {
    setState(() => _quantity++);
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  String _formatPrice(int amount) {
    // Format dạng 45.000đ
    final String s = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join()}đ';
  }

  void _handleOrder() {
    Navigator.pushNamed(
      context,
      '/rescue-booking',
      arguments: {
        'title': _product['title'] ?? 'Giỏ rau củ cuối ngày',
        'store': _product['store'] ?? 'Rau Sạch Xanh',
        'distance': _product['distance'] ?? '350m',
        'discountedPrice': _product['discountedPrice'] ?? 45000,
        'originalPrice': _product['originalPrice'] ?? 80000,
        'quantity': _quantity,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cho phép lấy dữ liệu truyền qua Navigator.pushNamed(arguments: ...)
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final product = routeArgs ?? _product;

    final String title = product['title'] ?? 'Giỏ rau củ cuối ngày';
    final String store = product['store'] ?? 'Rau Sạch Xanh';
    final String distance = product['distance'] ?? '350m';
    final int discountedPrice = product['discountedPrice'] as int? ?? 45000;
    final int originalPrice = product['originalPrice'] as int? ?? 80000;
    final String expiryHint = product['expiryHint'] ?? 'Dùng trong 2 ngày';
    final String description = product['description'] ??
        'Giỏ rau củ cuối ngày từ Rau Sạch Xanh với giá ưu đãi. Ưu tiên dùng sớm để tránh lãng phí.';

    final int totalPrice = discountedPrice * _quantity;

    return Scaffold(
      backgroundColor: AppTokens.cream,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình với nút Back tròn và tiêu đề
            const ScreenHeader(
              title: 'Chi tiết sản phẩm',
            ),

            // 2. Nội dung chi tiết có thể cuộn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Khối thông tin sản phẩm & Banner hạn dùng
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Khối hình ảnh / icon đồ họa scanner nổi bật
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.crop_free_rounded,
                                size: 54,
                                color: AppTokens.brand,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppTokens.space16),

                          // Tên sản phẩm
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Cửa hàng & Khoảng cách
                          Text(
                            '$store  ·  $distance',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: AppTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Giá giảm & Giá gốc gạch ngang
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _formatPrice(discountedPrice),
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppTokens.brand,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatPrice(originalPrice),
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: AppTokens.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppTokens.space12),

                          // Banner vàng/hổ phách: Dùng trong 2 ngày
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1B434),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: Color(0xFF452200),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  expiryHint,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF452200),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Card 2: Khối mô tả sản phẩm
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mô tả',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: AppTokens.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Card 3: Khối chọn số lượng
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Số lượng',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.textPrimary,
                            ),
                          ),

                          // Bộ đếm +/-
                          Row(
                            children: [
                              // Nút trừ
                              GestureDetector(
                                onTap: _decreaseQuantity,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 18,
                                      color: AppTokens.textPrimary,
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTokens.textPrimary,
                                  ),
                                ),
                              ),

                              // Nút cộng
                              GestureDetector(
                                onTap: _increaseQuantity,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                      color: AppTokens.brand,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space24),
                  ],
                ),
              ),
            ),

            // 3. Khối thanh toán dính chân trang (Sticky bottom bar)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space16,
                vertical: AppTokens.space12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppTokens.border,
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dòng hiển thị tổng tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng tiền · $_quantity giỏ',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: AppTokens.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatPrice(totalPrice),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: AppTokens.brand,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTokens.space10),

                  // Nút "Đặt mua"
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.brand,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleOrder,
                      child: const Text(
                        'Đặt mua',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

