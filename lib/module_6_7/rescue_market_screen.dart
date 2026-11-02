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
      'imageUrl':
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=80',
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
      'imageUrl':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&q=80',
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
      'imageUrl':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Giỏ cơm trưa & đồ nấu sẵn',
      'store': 'Bếp Mẹ Nấu',
      'distance': '1.2 km',
      'originalPrice': '65.000 đ',
      'discountedPrice': '39.000 đ',
      'savings': 'Tiết kiệm 26.000 đ',
      'remainingTime': 'Còn 4 giờ',
      'pickupTime': '17:30–19:00',
      'category': 'Đồ nấu sẵn',
      'imageUrl':
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Giỏ củ quả Đà Lạt',
      'store': 'Nông sản Đà Lạt',
      'distance': '800 m',
      'originalPrice': '95.000 đ',
      'discountedPrice': '55.000 đ',
      'savings': 'Tiết kiệm 40.000 đ',
      'remainingTime': 'Còn 2.5 giờ',
      'pickupTime': '18:30–20:00',
      'category': 'Rau củ',
      'imageUrl':
          'https://images.unsplash.com/photo-1597362925123-77861d3fbac7?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Giỏ bánh mì & bánh nướng',
      'store': 'Tiệm Bánh Paris',
      'distance': '1.5 km',
      'originalPrice': '85.000 đ',
      'discountedPrice': '48.000 đ',
      'savings': 'Tiết kiệm 37.000 đ',
      'remainingTime': 'Còn 1.5 giờ',
      'pickupTime': '19:30–21:00',
      'category': 'Bánh ngọt',
      'imageUrl':
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=400&q=80',
    },
  ];

  String _formatPrice(dynamic rawPrice) {
    if (rawPrice == null) return '';
    if (rawPrice is num) {
      final str = rawPrice.toInt().toString();
      final buffer = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(str[i]);
      }
      return '${buffer.toString()} đ';
    }
    return rawPrice.toString();
  }

  int _parsePriceInt(dynamic rawPrice, int defaultVal) {
    if (rawPrice == null) return defaultVal;
    if (rawPrice is num) return rawPrice.toInt();
    final digitsOnly = rawPrice.toString().replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digitsOnly) ?? defaultVal;
  }

  String _resolveImageUrl(Map<String, dynamic> item) {
    final rawUrl = (item['imageUrl'] ?? item['image']) as String?;
    if (rawUrl != null && rawUrl.trim().isNotEmpty) {
      return rawUrl.trim();
    }
    final cat = (item['category'] ?? '').toString();
    switch (cat) {
      case 'Bánh ngọt':
        return 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&q=80';
      case 'Đồ chay':
        return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=400&q=80';
      case 'Rau củ':
        return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=80';
      case 'Đồ nấu sẵn':
        return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80';
      default:
        return 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80';
    }
  }

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
        child: SingleChildScrollView(
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
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (val) {
                            setState(() => _searchQuery = val.trim().toLowerCase());
                          },
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTokens.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Tìm giỏ quà, cửa hàng...',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: AppTokens.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppTokens.textSecondary,
                              size: 22,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: AppTokens.textSecondary,
                                    ),
                                  )
                                : null,
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 38,
                              minHeight: 38,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
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
              Padding(
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
                            final imgUrl = _resolveImageUrl(item);
                            final formattedOriginal = _formatPrice(item['originalPrice']);
                            final formattedDiscounted = _formatPrice(item['discountedPrice']);
                            final int discountedInt = _parsePriceInt(item['discountedPrice'], 45000);
                            final int originalInt = _parsePriceInt(item['originalPrice'], 80000);
                            final savingsText = item['savings']?.toString() ??
                                (originalInt > discountedInt
                                    ? 'Tiết kiệm ${_formatPrice(originalInt - discountedInt)}'
                                    : null);

                            return RescueMarketCard(
                              title: item['title']?.toString() ?? 'Giỏ giải cứu',
                              store: item['store']?.toString() ?? 'Cửa hàng',
                              distance: item['distance']?.toString() ?? 'Gần bạn',
                              originalPrice: formattedOriginal,
                              discountedPrice: formattedDiscounted,
                              savings: savingsText,
                              remainingTime: item['remainingTime']?.toString(),
                              pickupTime: item['pickupTime']?.toString(),
                              imageUrl: imgUrl,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/rescue-detail',
                                  arguments: {
                                    'title': item['title'] ?? 'Giỏ giải cứu',
                                    'store': item['store'] ?? 'Cửa hàng',
                                    'distance': item['distance'] ?? '350m',
                                    'discountedPrice': discountedInt,
                                    'originalPrice': originalInt,
                                    'expiryHint': item['expiryHint'] ?? 'Dùng trong 2 ngày',
                                    'description': item['description'] ??
                                        'Giỏ hàng giải cứu chất lượng từ ${item['store'] ?? 'cửa hàng'} với giá ưu đãi. Ưu tiên dùng sớm để tránh lãng phí.',
                                    'pickupWindow': item['pickupTime'] ?? '18:00–19:30',
                                    'imageUrl': imgUrl,
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
            ],
          ),
        ),
      ),
    );
  }
}

