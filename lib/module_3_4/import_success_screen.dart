import 'package:flutter/material.dart';
// Import file chứa FigmaColors và ProductItem
import 'add_product_manual.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImportSuccessScreen extends StatelessWidget {
  final List<ProductItem> addedProducts;

  const ImportSuccessScreen({super.key, required this.addedProducts});

  int _calculateDaysLeft(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.difference(today).inDays;
  }

  FaIconData _getLocationIcon(String location) {
    if (location.toLowerCase().contains('đông') || location.toLowerCase().contains('mát')) {
      return FontAwesomeIcons.snowflake; 
    } else if (location.toLowerCase().contains('bếp')) {
      return FontAwesomeIcons.kitchenSet;
    }
    return FontAwesomeIcons.boxOpen; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: FigmaColors.brand,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 40),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Icon(Icons.shopping_basket, color: FigmaColors.brand, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nhập kho thành công!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: FigmaColors.textMain),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thực phẩm đã được cập nhật vào kho\nFoodLoop.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: FigmaColors.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: FigmaColors.border.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TÓM TẮT NHẬP KHO',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FigmaColors.textMuted, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildIconBadge(FontAwesomeIcons.basketShopping),
                            const SizedBox(width: 12),
                            Text('${addedProducts.length} mặt hàng đã thêm', style: TextStyle(fontSize: 14, color: FigmaColors.textMain, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildIconBadge(FontAwesomeIcons.locationDot),
                            const SizedBox(width: 12),
                            Text('Vị trí lưu trữ: Đã cập nhật', style: TextStyle(fontSize: 14, color: FigmaColors.textMain, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Thực phẩm vừa thêm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: FigmaColors.textMain),
                  ),
                  const SizedBox(height: 16),
                  
                  ...addedProducts.map((product) => _buildProductResultCard(product)),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: FigmaColors.brandLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notifications, color: FigmaColors.brand, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'FoodLoop sẽ nhắc bạn về hạn sử dụng theo cài đặt thông báo.',
                            style: TextStyle(fontSize: 13, color: FigmaColors.brand, height: 1.4, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FigmaColors.background, 
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaColors.brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Về trang chủ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge(FaIconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: FigmaColors.brandLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FaIcon(icon, size: 16, color: FigmaColors.brand), // <-- Dùng FaIcon
    );
  }

  Widget _buildProductResultCard(ProductItem product) {
    int daysLeft = _calculateDaysLeft(product.expiryDate!);
    bool isExpiringSoon = daysLeft <= 3;
    Color statusColor = isExpiringSoon ? const Color(0xFFF59E0B) : FigmaColors.brand; 

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FigmaColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.nameController.text,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: FigmaColors.textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${product.quantity} ${product.unit.toLowerCase()}',
                style: TextStyle(fontSize: 13, color: FigmaColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FaIcon(_getLocationIcon(product.location), size: 14, color: FigmaColors.textMuted),
              const SizedBox(width: 6),
              Text(product.location, style: TextStyle(fontSize: 12, color: FigmaColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: statusColor),
              const SizedBox(width: 6),
              Text(
                'Còn $daysLeft ngày',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}