import 'package:flutter/material.dart';
import '../components/app_switch.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../theme/app_tokens.dart';

/// Màn hình 62: "Danh mục bộ lọc" / "Bộ lọc" (Module 6 & 7)
class MarketFilterScreen extends StatefulWidget {
  const MarketFilterScreen({super.key});

  @override
  State<MarketFilterScreen> createState() => _MarketFilterScreenState();
}

class _MarketFilterScreenState extends State<MarketFilterScreen> {
  // State danh mục đã chọn (mặc định theo thiết kế là 'Rau củ')
  String _selectedCategory = 'Rau củ';

  // State các bộ lọc
  String _selectedDistance = 'Trong 2 km';
  String _selectedPriceRange = '30.000 đ – 60.000 đ';
  String _selectedPickupTime = '18:00–20:00';
  bool _onlyAvailable = true;

  // Danh mục sản phẩm theo thiết kế Figma Màn 62
  final List<String> _categories = const [
    'Tất cả',
    'Đồ chay',
    'Rau củ',
    'Bánh ngọt',
    'Đồ chế biến',
    'Ăn liền',
  ];

  // Danh sách khoảng cách
  final List<String> _distances = const [
    'Trong 1 km',
    'Trong 2 km',
    'Trong 5 km',
    'Trong 10 km',
    'Tất cả khoảng cách',
  ];

  // Danh sách mức giá
  final List<String> _priceRanges = const [
    'Dưới 30.000 đ',
    '30.000 đ – 60.000 đ',
    '60.000 đ – 100.000 đ',
    'Trên 100.000 đ',
    'Tất cả mức giá',
  ];

  // Danh sách khung giờ
  final List<String> _pickupTimes = const [
    'Trước 18:00',
    '18:00–20:00',
    'Sau 20:00',
  ];

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'Tất cả';
      _selectedDistance = 'Trong 2 km';
      _selectedPriceRange = 'Tất cả mức giá';
      _selectedPickupTime = '18:00–20:00';
      _onlyAvailable = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đặt lại tất cả bộ lọc về mặc định.'),
        backgroundColor: AppTokens.brand,
      ),
    );
  }

  void _showDistancePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppTokens.space16),
              child: Text(
                'Chọn khoảng cách',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ..._distances.map((dist) => ListTile(
                  title: Text(
                    dist,
                    style: TextStyle(
                      fontWeight: dist == _selectedDistance
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: dist == _selectedDistance
                          ? AppTokens.brand
                          : AppTokens.textPrimary,
                    ),
                  ),
                  trailing: dist == _selectedDistance
                      ? const Icon(Icons.check, color: AppTokens.brand)
                      : null,
                  onTap: () {
                    setState(() => _selectedDistance = dist);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showPricePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppTokens.space16),
              child: Text(
                'Chọn mức giá',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ..._priceRanges.map((price) => ListTile(
                  title: Text(
                    price,
                    style: TextStyle(
                      fontWeight: price == _selectedPriceRange
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: price == _selectedPriceRange
                          ? AppTokens.brand
                          : AppTokens.textPrimary,
                    ),
                  ),
                  trailing: price == _selectedPriceRange
                      ? const Icon(Icons.check, color: AppTokens.brand)
                      : null,
                  onTap: () {
                    setState(() => _selectedPriceRange = price);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 3, // Tab Túi hàng / Chợ active theo thiết kế Màn 62
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình với nút Back tròn và tiêu đề "Bộ lọc"
            const ScreenHeader(
              title: 'Bộ lọc',
            ),

            // 2. Nội dung cuộn các tiêu chí lọc
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mục 1: Danh mục
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

                    const SizedBox(height: AppTokens.space24),

                    // Mục 2: Bộ lọc chi tiết
                    const Text(
                      'Bộ lọc',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space14),

                    // Khoảng cách
                    const Text(
                      'Khoảng cách',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _showDistancePicker,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.space14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTokens.border.withValues(alpha: 0.8),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDistance,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTokens.textSecondary,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Mức giá
                    const Text(
                      'Mức giá',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _showPricePicker,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.space14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTokens.border.withValues(alpha: 0.8),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedPriceRange,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTokens.textSecondary,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Khung giờ lấy hàng
                    const Text(
                      'Khung giờ lấy hàng',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _pickupTimes.map((time) {
                        final isSelected = time == _selectedPickupTime;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPickupTime = time);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 6.0,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 15,
                                      color: AppTokens.brand,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Flexible(
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: isSelected
                                            ? AppTokens.brand
                                            : AppTokens.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppTokens.space20),

                    // Khối chuyển đổi "Chỉ hiện giỏ còn hàng"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.7),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chỉ hiện giỏ còn hàng',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.textPrimary,
                            ),
                          ),
                          AppSwitch(
                            value: _onlyAvailable,
                            onChanged: (val) {
                              setState(() => _onlyAvailable = val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space24),
                  ],
                ),
              ),
            ),

            // 3. Khối 2 nút bấm thao tác ở chân màn hình
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
              child: Row(
                children: [
                  // Nút "Đặt lại" (Outlined)
                  Expanded(
                    flex: 4,
                    child: SizedBox(
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
                        onPressed: _resetFilters,
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.brand,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppTokens.space12),

                  // Nút "Xem 8 kết quả" (Filled)
                  Expanded(
                    flex: 6,
                    child: SizedBox(
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/market-filter-results');
                        },
                        child: const Text(
                          'Xem 8 kết quả',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

