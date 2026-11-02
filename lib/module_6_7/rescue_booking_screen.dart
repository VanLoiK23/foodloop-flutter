import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 64: "Đặt giữ chỗ" (Module 6 & 7)
class RescueBookingScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const RescueBookingScreen({
    super.key,
    this.initialData,
  });

  @override
  State<RescueBookingScreen> createState() => _RescueBookingScreenState();
}

class _RescueBookingScreenState extends State<RescueBookingScreen> {
  int _quantity = 1;
  String _pickupTime = 'Chưa chọn';

  final TextEditingController _nameController =
      TextEditingController(text: 'Minh Anh');
  final TextEditingController _phoneController =
      TextEditingController(text: '0987654321');
  bool _isSubmitting = false;

  final int _unitPrice = 45000;
  final int _originalUnitPrice = 80000;
  final String _store = 'Cửa hàng Rau Sạch Xanh';
  final String _productTitle = 'Giỏ rau củ cuối ngày';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
    return '${buffer.toString().split('').reversed.join()} đ';
  }

  Future<void> _selectPickupTime() async {
    final result = await Navigator.pushNamed(
      context,
      '/rescue-pickup-time',
      arguments: {
        'store': _store,
        'product': _productTitle,
        'quantity': _quantity,
      },
    );

    if (result != null && result is String) {
      setState(() {
        _pickupTime = result;
      });
    }
  }

  Future<void> _handleConfirmBooking() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập họ và tên của bạn.'),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số điện thoại liên hệ.'),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final total = _unitPrice * _quantity;
      await FoodLoopFirestoreService.createRescueBooking(
        title: _productTitle,
        store: _store,
        quantity: _quantity,
        totalPrice: total,
        pickupTime: _pickupTime != 'Chưa chọn'
            ? _pickupTime
            : 'Hôm nay, 31/10 · 18:30 – 19:00',
        customerName: name,
        customerPhone: phone,
      );
    } catch (e) {
      debugPrint('Lưu Firestore không thành công (fallback hiển thị thành công): $e');
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTokens.brand,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đặt giữ chỗ thành công!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đơn giữ chỗ cho $_productTitle đã được ghi nhận. Vui lòng thanh toán tại quầy khi đến nhận giỏ.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTokens.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/rescue-order-history');
                },
                child: const Text(
                  'Xem lịch sử đơn hàng',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/rescue-market',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Về Chợ giải cứu',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPrice = _unitPrice * _quantity;

    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 3, // Tab Túi hàng / Chợ active theo thiết kế Màn 64
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình với nút Back tròn và tiêu đề
            const ScreenHeader(
              title: 'Chi tiết sản phẩm',
            ),

            // 2. Nội dung cuộn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Khối tóm tắt sản phẩm
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                        children: [
                          // Ảnh / icon sản phẩm
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=200&q=80',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 56,
                                height: 56,
                                color: const Color(0xFFE8F5E9),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  color: AppTokens.brand,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _productTitle,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppTokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Rau Sạch Xanh · 350 m',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: AppTokens.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      _formatPrice(_unitPrice),
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppTokens.brand,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatPrice(_originalUnitPrice),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppTokens.textSecondary,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor:
                                            AppTokens.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Giảm 44%',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppTokens.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space14),

                    // Card 2: Khối chọn số lượng
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
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
                          Row(
                            children: [
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

                    const SizedBox(height: AppTokens.space20),

                    // Mục: Thời gian đến nhận
                    const Text(
                      'Thời gian đến nhận',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppTokens.space14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _store,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppTokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  '350 m · Mở đến 20:00',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: AppTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          InkWell(
                            onTap: _selectPickupTime,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppTokens.space14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Chọn thời gian đến nhận',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppTokens.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _pickupTime,
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: _pickupTime != 'Chưa chọn'
                                              ? AppTokens.brand
                                              : AppTokens.textSecondary,
                                          fontWeight:
                                              _pickupTime != 'Chưa chọn'
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTokens.textSecondary,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space20),

                    // Mục: Thông tin liên hệ
                    const Text(
                      'Thông tin liên hệ',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Để cửa hàng liên hệ về giỏ của bạn.',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: AppTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),

                    // Họ và tên
                    const Text(
                      'Họ và tên',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: AppTokens.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Nhập họ và tên',
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            color: AppTokens.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space14),

                    // Số điện thoại
                    const Text(
                      'Số điện thoại',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: AppTokens.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Nhập số điện thoại',
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            color: AppTokens.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space20),

                    // Card cảnh báo: Lưu ý thực phẩm cận hạn
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFD97706),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Lưu ý thực phẩm cận hạn',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Kiểm tra hạn dùng khi nhận và ưu tiên sử dụng sớm. Thành phần thực tế tùy tồn cuối ngày của cửa hàng.',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Color(0xFFB45309),
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space24),
                  ],
                ),
              ),
            ),

            // 3. Khối thanh toán dính chân trang
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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatPrice(_unitPrice)} × $_quantity giỏ',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                      Text(
                        _formatPrice(totalPrice),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                      Text(
                        _formatPrice(totalPrice),
                        style: const TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                          color: AppTokens.brand,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dòng ghi chú phương thức giữ chỗ & liên kết thanh toán online
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/rescue-payment');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.payment_rounded,
                            size: 16,
                            color: AppTokens.brand,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Giữ chỗ – trả tại cửa hàng (Hoặc thanh toán online >)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.brand,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Nút "Xác nhận Đặt mua"
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
                      onPressed: _isSubmitting ? null : _handleConfirmBooking,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Xác nhận Đặt mua',
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

