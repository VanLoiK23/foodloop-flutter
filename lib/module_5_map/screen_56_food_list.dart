import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'models/food_post_model.dart';
import 'services/food_service.dart';

class Screen56FoodList extends StatefulWidget {
  const Screen56FoodList({super.key});

  @override
  State<Screen56FoodList> createState() => _Screen56FoodListState();
}

class _Screen56FoodListState extends State<Screen56FoodList> {
  String _typeFilter = 'Tất cả'; // 'Tất cả', 'Cho', 'Xin'
  String? _categoryFilter; // 'Thịt cá', 'Rau củ', etc.
  int _distanceFilter = 1000; // 500, 1000, 2000

  void _showPostActions(FoodPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Bài đăng của ${post.giverName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.title,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.remove_red_eye_outlined, color: AppColors.brand),
                title: const Text('Xem chi tiết bài đăng', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.gray),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/food-detail', arguments: post);
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: AppColors.danger),
                title: const Text('Báo cáo bài đăng', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.gray),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    '/report-appeal',
                    arguments: {
                      'id': post.id,
                      'name': post.title,
                      'subtitle': '${post.remainingQuantity} ${post.unit} · ${post.distanceMeters}m · ${post.giverName}',
                      'image': '',
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _typeFilter = 'Tất cả';
      _categoryFilter = null;
      _distanceFilter = 2000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quanh bạn',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_outlined, color: AppColors.title),
                    onPressed: () {
                      _showFilterModal();
                    },
                  ),
                ],
              ),
            ),

            // Toggle Bản đồ / Danh sách
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 16, color: AppColors.gray),
                              SizedBox(width: 6),
                              Text(
                                'Bản đồ',
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Danh sách',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Dải Chips bộ lọc nhanh
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildTypeChip('Tất cả'),
                  const SizedBox(width: 8),
                  _buildTypeChip('Cho'),
                  const SizedBox(width: 8),
                  _buildTypeChip('Xin'),
                  if (_distanceFilter <= 1000) ...[
                    const SizedBox(width: 8),
                    _buildActiveTag('${_distanceFilter}m', onRemove: () {
                      setState(() => _distanceFilter = 3000);
                    }),
                  ],
                  if (_categoryFilter != null) ...[
                    const SizedBox(width: 8),
                    _buildActiveTag(_categoryFilter!, onRemove: () {
                      setState(() => _categoryFilter = null);
                    }),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Stream danh sách bài đăng
            Expanded(
              child: StreamBuilder<List<FoodPost>>(
                stream: FoodService.instance.getFoodPostsStream(
                  typeFilter: _typeFilter,
                  categoryFilter: _categoryFilter,
                  maxDistanceMeters: _distanceFilter,
                ),
                builder: (context, snapshot) {
                  final posts = snapshot.data ?? [];

                  if (posts.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Stack(
                    children: [
                      ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                        itemCount: posts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _buildFoodCard(post);
                        },
                      ),

                      // Nút Floating (+)
                      Positioned(
                        right: 20,
                        bottom: 24,
                        child: FloatingActionButton(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.title,
                          elevation: 3,
                          shape: const CircleBorder(),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đăng thực phẩm mới lên cộng đồng'),
                                backgroundColor: AppColors.brand,
                              ),
                            );
                          },
                          child: const Icon(Icons.add, size: 28),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 2),
    );
  }

  Widget _buildTypeChip(String label) {
    final isSelected = _typeFilter == label && _categoryFilter == null;
    return GestureDetector(
      onTap: () {
        setState(() {
          _typeFilter = label;
          _categoryFilter = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brand : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.title,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTag(String label, {required VoidCallback onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.brand),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodPost post) {
    final isGiving = post.type == 'Cho';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/food-detail', arguments: post);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon hộp món ăn
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8DFB8)),
              ),
              child: Center(
                child: Icon(
                  _getIcon(post.iconType),
                  color: AppColors.brand,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Thông tin món
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.quantityTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        post.distanceText,
                        style: const TextStyle(fontSize: 12, color: AppColors.gray),
                      ),
                      const SizedBox(width: 6),
                      const Text('·', style: TextStyle(color: AppColors.gray)),
                      const SizedBox(width: 6),
                      Text(
                        '${post.giverName} ${post.giverRating}',
                        style: const TextStyle(fontSize: 12, color: AppColors.gray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isGiving ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post.type,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isGiving ? AppColors.brand : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post.badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF57F17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nút 3 chấm mở action sheet (Màn 56b)
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.gray),
              onPressed: () => _showPostActions(post),
            ),
          ],
        ),
      ),
    );
  }

  // Màn 56c / 56d: Trạng thái không có bài đăng phù hợp
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, size: 36, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có bài đăng phù hợp',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thử mở rộng khoảng cách hoặc bỏ bớt bộ lọc để xem thêm.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _resetFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Xóa bộ lọc', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _distanceFilter = 2000;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mở rộng lên 2 km',
                  style: TextStyle(color: AppColors.title, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lọc theo danh mục',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.title),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Thịt cá', 'Rau củ', 'Bánh mì', 'Sữa', 'Trứng'].map((cat) {
                final isSelected = _categoryFilter == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.brand,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.title),
                  onSelected: (val) {
                    Navigator.pop(ctx);
                    setState(() {
                      _categoryFilter = val ? cat : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Khoảng cách tối đa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.title),
            ),
            const SizedBox(height: 12),
            Row(
              children: [500, 1000, 2000].map((d) {
                final isSelected = _distanceFilter == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${d}m'),
                    selected: isSelected,
                    onSelected: (_) {
                      Navigator.pop(ctx);
                      setState(() {
                        _distanceFilter = d;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ],
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
