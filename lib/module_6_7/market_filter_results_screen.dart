import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 62.1: "Kết quả lọc danh mục" (Module 6 & 7)
class MarketFilterResultsScreen extends StatefulWidget {
  const MarketFilterResultsScreen({super.key});

  @override
  State<MarketFilterResultsScreen> createState() =>
      _MarketFilterResultsScreenState();
}

class _MarketFilterResultsScreenState extends State<MarketFilterResultsScreen> {
  // 8 giỏ rau củ phù hợp chuẩn theo thiết kế Figma Màn 62.1
  static const List<Map<String, dynamic>> _defaultResults = [
    {
      'title': 'Giỏ rau củ cuối ngày',
      'store': 'Vườn Xanh',
      'distance': '0,4 km',
      'pickupTime': 'Hôm nay, 18:00–19:00',
      'remaining': 'Còn 4 giỏ',
      'discountedPrice': '35.000 đ',
      'originalPrice': '70.000 đ',
      'image':
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Giỏ rau xanh theo mùa',
      'store': 'Nhà Lá',
      'distance': '0,6 km',
      'pickupTime': 'Hôm nay, 18:00–20:00',
      'remaining': 'Còn 3 giỏ',
      'discountedPrice': '30.000 đ',
      'originalPrice': '60.000 đ',
      'image':
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Giỏ củ quả Đà Lạt',
      'store': 'Nông sản Đà Lạt',
      'distance': '0,8 km',
      'pickupTime': 'Hôm nay, 18:30–19:30',
      'remaining': 'Còn 5 giỏ',
      'discountedPrice': '45.000 đ',
      'originalPrice': '90.000 đ',
      'image':
          'https://images.unsplash.com/photo-1597362925123-77861d3fbac7?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Giỏ rau nấu canh',
      'store': 'Tiệm rau Mộc',
      'distance': '1,0 km',
      'pickupTime': 'Hôm nay, 18:00–19:30',
      'remaining': 'Còn 2 giỏ',
      'discountedPrice': '32.000 đ',
      'originalPrice': '65.000 đ',
      'image':
          'https://images.unsplash.com/photo-1506802913710-40e2e66339c9?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Giỏ rau củ gia đình',
      'store': 'An Nhiên Farm',
      'distance': '1,2 km',
      'pickupTime': 'Hôm nay, 18:30–20:00',
      'remaining': 'Còn 3 giỏ',
      'discountedPrice': '60.000 đ',
      'originalPrice': '120.000 đ',
      'image':
          'https://images.unsplash.com/photo-1518843875459-f738682238a6?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Giỏ rau trộn tươi',
      'store': 'Góc Xanh',
      'distance': '1,4 km',
      'pickupTime': 'Hôm nay, 18:00–19:00',
      'remaining': 'Còn 4 giỏ',
      'discountedPrice': '40.000 đ',
      'originalPrice': '80.000 đ',
      'image':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Giỏ củ quả theo mùa',
      'store': 'Rau Sạch Mỗi Ngày',
      'distance': '1,7 km',
      'pickupTime': 'Hôm nay, 19:00–20:00',
      'remaining': 'Còn 2 giỏ',
      'discountedPrice': '50.000 đ',
      'originalPrice': '100.000 đ',
      'image':
          'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Giỏ rau vườn hôm nay',
      'store': 'Nhà Vườn',
      'distance': '1,9 km',
      'pickupTime': 'Hôm nay, 18:00–20:00',
      'remaining': 'Còn 6 giỏ',
      'discountedPrice': '38.000 đ',
      'originalPrice': '75.000 đ',
      'image':
          'https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?auto=format&fit=crop&w=300&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 3, // Tab Túi hàng / Chợ active theo thiết kế
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình
            const ScreenHeader(
              title: 'Kết quả lọc danh mục',
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
                    // Khối: "Bộ lọc đang áp dụng" & nút "Điều chỉnh"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bộ lọc đang áp dụng',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: AppTokens.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/market-filter');
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              'Điều chỉnh',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.brand,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTokens.space10),

                    // Hàng chips tiêu chí đang áp dụng
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        _buildFilterPill('Rau củ', hasCheck: true),
                        _buildFilterPill('Trong 2 km'),
                        _buildFilterPill('30.000 đ – 60.000 đ'),
                        _buildFilterPill('18:00–20:00'),
                      ],
                    ),

                    const SizedBox(height: AppTokens.space8),

                    // Tiêu chí phụ: Chỉ hiện giỏ còn hàng
                    Row(
                      children: const [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 15,
                          color: AppTokens.brand,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Chỉ hiện giỏ còn hàng',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTokens.space20),

                    // Tiêu đề số lượng kết quả: "8 giỏ phù hợp"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: const [
                        Text(
                          '8 giỏ phù hợp',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                        Text(
                          'Gần bạn nhất',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: AppTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chọn một giỏ để xem chi tiết và giữ chỗ.',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: AppTokens.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppTokens.space14),

                    // Danh sách 8 thẻ kết quả (Lắng nghe Firestore với fallback chuẩn thiết kế)
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FoodLoopFirestoreService.streamRescueBaskets(
                        category: 'Rau củ',
                      ),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final List<Map<String, dynamic>> items = docs.isNotEmpty
                            ? docs.map((d) => d.data()).toList()
                            : _defaultResults;

                        return Column(
                          children: items.map((item) {
                            return _buildResultCard(item);
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Dòng thông báo hết danh sách
                    const Center(
                      child: Text(
                        'Bạn đã xem hết 8 giỏ phù hợp.',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space12),

                    // Nút Outlined: "Điều chỉnh bộ lọc"
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: AppTokens.brand,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/market-filter');
                        },
                        child: const Text(
                          'Điều chỉnh bộ lọc',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.brand,
                          ),
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

  /// Chip hiển thị tiêu chí lọc đang áp dụng
  Widget _buildFilterPill(String label, {bool hasCheck = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTokens.brand,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasCheck) ...[
            const Icon(
              Icons.check_rounded,
              size: 15,
              color: AppTokens.brand,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: AppTokens.brand,
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ hiển thị giỏ hàng kết quả chuẩn Màn 62.1
  Widget _buildResultCard(Map<String, dynamic> item) {
    final String title = item['title'] ?? '';
    final String store = item['store'] ?? '';
    final String distance = item['distance'] ?? '';
    final String pickupTime = item['pickupTime'] ?? '';
    final String remaining = item['remaining'] ?? 'Còn hàng';
    final String discountedPrice = item['discountedPrice'] ?? '';
    final String originalPrice = item['originalPrice'] ?? '';
    final String imageUrl = item['image'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/rescue-detail',
          arguments: {
            'title': title,
            'store': store,
            'distance': distance,
            'discountedPrice': 35000,
            'originalPrice': 70000,
            'expiryHint': 'Dùng trong 2 ngày',
            'description':
                'Giỏ rau củ tươi ngon cuối ngày từ $store với mức giá ưu đãi đặc biệt. Ưu tiên sử dụng sớm để bảo vệ môi trường và chống lãng phí.',
            'pickupWindow': pickupTime,
          },
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTokens.space12),
        padding: const EdgeInsets.all(AppTokens.space14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTokens.border.withValues(alpha: 0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Hàng 1: Ảnh + Tên giỏ & Cửa hàng
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultImage(),
                        )
                      : _buildDefaultImage(),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$store · $distance',
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Hàng 2: Thời gian nhận & Số lượng còn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppTokens.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pickupTime,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  remaining,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.brand,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Hàng 3: Giá bán & Nút xem "Chi tiết >"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      discountedPrice,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.brand,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      originalPrice,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: AppTokens.textSecondary,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Text(
                      'Chi tiết',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: AppTokens.textSecondary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppTokens.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.eco_rounded,
          color: AppTokens.brand,
          size: 26,
        ),
      ),
    );
  }
}

