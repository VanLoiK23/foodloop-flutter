import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/rescue_market_card.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 61: "Chợ giải cứu" (Module 6 & 7)
class RescueMarketScreen extends StatefulWidget {
  const RescueMarketScreen({super.key});

  @override
  State<RescueMarketScreen> createState() => _RescueMarketScreenState();
}

class _RescueMarketScreenState extends State<RescueMarketScreen> {
  String _selectedCategory = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Danh mục sản phẩm theo thiết kế Figma
  final List<String> _categories = const [
    'Tất cả',
    'Đồ chay',
    'Rau củ',
    'Bánh ngọt',
    'Đồ nấu sẵn',
  ];

  // Dữ liệu mẫu chuẩn thiết kế khi Firebase chưa có dữ liệu
  static const List<Map<String, dynamic>> _defaultBaskets = [
    {
      'title': 'Giỏ rau củ cuối ngày',
      'store': 'Rau Sạch Xanh',
      'distance': '350 m',
      'originalPrice': '80.000 đ',
      'discountedPrice': '45.000 đ',
      'savings': 'Tiết kiệm 35.000 đ',
      'remainingTime': 'Còn 3 giờ',
      'pickupTime': '18:00–19:30',
      'category': 'Rau củ',
      'icon': 'crop_free',
    },
    {
      'title': 'Giỏ bánh ngọt',
      'store': 'Nắng Mai',
      'distance': '600 m',
      'originalPrice': '90.000 đ',
      'discountedPrice': '60.000 đ',
      'savings': 'Tiết kiệm 30.000 đ',
      'remainingTime': 'Còn 2 giờ',
      'pickupTime': '20:00–21:00',
      'category': 'Bánh ngọt',
      'icon': 'crop_free',
    },
    {
      'title': 'Giỏ đồ chay',
      'store': 'An Lạc',
      'distance': '900 m',
      'originalPrice': '70.000 đ',
      'discountedPrice': '44.000 đ',
      'savings': 'Tiết kiệm 26.000 đ',
      'remainingTime': 'Còn 1 giờ',
      'pickupTime': '19:00–20:30',
      'category': 'Đồ chay',
      'icon': 'crop_free',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 3, // Tab Túi hàng / Chợ được active theo thiết kế Màn 61
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tiêu đề "Danh mục chợ >"
            Padding(
              padding: const EdgeInsets.only(
                left: AppTokens.space16,
                right: AppTokens.space16,
                top: AppTokens.space16,
                bottom: AppTokens.space12,
              ),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang mở toàn bộ danh mục chợ...'),
                      backgroundColor: AppTokens.brand,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Danh mục chợ',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: AppTokens.textPrimary,
                    ),
                  ],
                ),
              ),
            ),

            // 2. Thanh tìm kiếm và nút "Lọc"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space16,
              ),
              child: Row(
                children: [
                  // Ô nhập tìm kiếm
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() => _searchQuery = val.trim().toLowerCase());
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTokens.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm giỏ quà, cửa hàng...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppTokens.textSecondary,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTokens.brand,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 13,
                                  color: AppTokens.brand,
                                ),
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppTokens.space12),

                  // Nút "Lọc"
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/market-filter'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTokens.brand,
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Lọc',
                          style: TextStyle(
                            color: AppTokens.brand,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTokens.space16),

            // 3. Tiêu đề "Danh mục" và các chips lọc
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danh mục',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _categories.map((cat) {
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE8F5E9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTokens.brand
                                  : AppTokens.border.withValues(alpha: 0.8),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppTokens.brand,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: isSelected
                                      ? AppTokens.brand
                                      : AppTokens.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTokens.space20),

            // 4. Danh sách "Sắp hết giờ nhận"
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sắp hết giờ nhận',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),

                    // Lắng nghe dữ liệu thời gian thực từ Firestore
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FoodLoopFirestoreService.streamRescueBaskets(
                        category: _selectedCategory,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppTokens.space24),
                              child: CircularProgressIndicator(
                                color: AppTokens.brand,
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        // Nếu Firestore chưa có dữ liệu, hiển thị danh sách mẫu chuẩn
                        final List<Map<String, dynamic>> allItems =
                            docs.isNotEmpty
                                ? docs.map((d) => d.data()).toList()
                                : _defaultBaskets;

                        // Lọc theo danh mục và từ khóa tìm kiếm
                        final filteredItems = allItems.where((item) {
                          final title = (item['title'] ?? '').toString().toLowerCase();
                          final store = (item['store'] ?? '').toString().toLowerCase();
                          final cat = (item['category'] ?? '').toString();

                          final matchesCat = _selectedCategory == 'Tất cả' ||
                              cat == _selectedCategory;
                          final matchesQuery = _searchQuery.isEmpty ||
                              title.contains(_searchQuery) ||
                              store.contains(_searchQuery);

                          return matchesCat && matchesQuery;
                        }).toList();

                        if (filteredItems.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppTokens.space24),
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppTokens.radiusLg,
                              border: Border.all(
                                color: AppTokens.border,
                                width: 1.0,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Không tìm thấy giỏ hàng nào phù hợp.',
                                style: AppTokens.subtitle,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: filteredItems.map((item) {
                            return RescueMarketCard(
                              title: item['title'] ?? '',
                              store: item['store'] ?? '',
                              distance: item['distance'] ?? '',
                              originalPrice: item['originalPrice'] ?? '',
                              discountedPrice: item['discountedPrice'] ?? '',
                              savings: item['savings'],
                              remainingTime: item['remainingTime'],
                              pickupTime: item['pickupTime'],
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/rescue-detail',
                                  arguments: {
                                    'title': item['title'] ?? 'Giỏ rau củ cuối ngày',
                                    'store': item['store'] ?? 'Rau Sạch Xanh',
                                    'distance': item['distance'] ?? '350m',
                                    'discountedPrice': 45000,
                                    'originalPrice': 80000,
                                    'expiryHint': 'Dùng trong 2 ngày',
                                    'description':
                                        'Giỏ rau củ cuối ngày từ Rau Sạch Xanh với giá ưu đãi. Ưu tiên dùng sớm để tránh lãng phí.',
                                    'pickupWindow': item['pickupTime'] ?? '18:00–19:30',
                                  },
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: AppTokens.space12),

                    // 5. Nút điều hướng "Xem tất cả đồ cận date giảm giá"
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang tải tất cả sản phẩm cận date giảm giá...'),
                            backgroundColor: AppTokens.brand,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: AppTokens.brand,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Xem tất cả đồ cận date giảm giá',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.brand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space24),
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

