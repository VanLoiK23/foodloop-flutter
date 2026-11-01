import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'models/food_post_model.dart';
import 'services/food_service.dart';

class Screen58RequestFood extends StatefulWidget {
  final FoodPost? post;

  const Screen58RequestFood({super.key, this.post});

  @override
  State<Screen58RequestFood> createState() => _Screen58RequestFoodState();
}

class _Screen58RequestFoodState extends State<Screen58RequestFood> {
  late FoodPost _post;
  int _quantity = 1;
  String? _selectedTimeSlot;
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _post = widget.post ??
        (ModalRoute.of(context)?.settings.arguments as FoodPost?) ??
        FoodService.defaultPosts.first;

    if (_messageController.text.isEmpty) {
      _messageController.text =
          'Chào bạn, mình xin $_quantity ${_post.unit} ${_post.title} cho bữa ăn. Cảm ơn bạn rất nhiều!';
    }
    if (_selectedTimeSlot == null && _post.timeSlots.isNotEmpty) {
      _selectedTimeSlot = _post.timeSlots.first;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _updateQuantity(int delta) {
    final next = _quantity + delta;
    if (next >= 1 && next <= _post.remainingQuantity) {
      setState(() {
        _quantity = next;
        _messageController.text =
            'Chào bạn, mình xin $_quantity ${_post.unit} ${_post.title} cho bữa ăn. Cảm ơn bạn!';
      });
    }
  }

  Future<void> _submitRequest() async {
    // 1. Validation
    if (_selectedTimeSlot == null) {
      _showError('Vui lòng chọn khung giờ bạn sẽ đến lấy thực phẩm');
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showError('Vui lòng để lại lời nhắn cho ${_post.giverName}');
      return;
    }

    if (_quantity > _post.remainingQuantity) {
      _showError('Số lượng còn lại chỉ còn ${_post.remainingQuantity} ${_post.unit}');
      return;
    }

    // 2. Loading dialog
    setState(() => _isSubmitting = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      ),
    );

    try {
      // 3. Ghi Firestore qua FoodService
      final createdReq = await FoodService.instance.createFoodRequest(
        post: _post,
        quantity: _quantity,
        timeSlot: _selectedTimeSlot!,
        message: _messageController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Tắt loading dialog
        // Chuyển sang Màn 58b: Đã gửi yêu cầu thành công
        Navigator.pushReplacementNamed(
          context,
          '/request-success',
          arguments: createdReq,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tắt loading
        _showError('Có lỗi xảy ra: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Xin nhận thực phẩm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.title,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ tóm tắt món ăn
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
                      color: const Color(0xFFFBF8E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getIcon(_post.iconType),
                        color: AppColors.brand,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _post.quantityTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.title,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_post.giverName} · ${_post.distanceText}',
                          style: const TextStyle(fontSize: 12, color: AppColors.gray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 1. Số lượng bạn cần
            const Text(
              'Số lượng bạn cần',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildStepperBtn(
                        Icons.remove,
                        () => _updateQuantity(-1),
                        enabled: _quantity > 1,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 44),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.title,
                              ),
                            ),
                            Text(
                              _post.unit,
                              style: const TextStyle(fontSize: 11, color: AppColors.gray),
                            ),
                          ],
                        ),
                      ),
                      _buildStepperBtn(
                        Icons.add,
                        () => _updateQuantity(1),
                        enabled: _quantity < _post.remainingQuantity,
                      ),
                    ],
                  ),
                  Text(
                    'Tối đa ${_post.remainingQuantity} ${_post.unit}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Chọn khung giờ đến lấy - Hôm nay
            const Text(
              'Chọn khung giờ đến lấy · Hôm nay',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: _post.timeSlots.length,
              itemBuilder: (context, index) {
                final slot = _post.timeSlots[index];
                final isSelected = _selectedTimeSlot == slot;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTimeSlot = slot);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.brand : AppColors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check, size: 16, color: AppColors.brand),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          slot,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.brand : AppColors.title,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 3. Lời nhắn cho người cho
            Text(
              'Lời nhắn cho ${_post.giverName}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập lời nhắn ngắn gọn, lịch sự...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.title, height: 1.4),
              ),
            ),

            const SizedBox(height: 14),

            // Ghi chú quyền riêng tư
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 14, color: AppColors.gray),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Bạn sẽ thấy địa chỉ chính xác sau khi ${_post.giverName} đồng ý.',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Nút "Gửi yêu cầu"
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Gửi yêu cầu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap, {required bool enabled}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.brand : Colors.grey.shade400,
        ),
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
