import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';
import 'product_selected_bottom_sheet.dart';
import 'virtual_refrigerator_bottom_sheet.dart';

class VirtualRefrigeratorOverview extends StatelessWidget {
  const VirtualRefrigeratorOverview({super.key});

  static const List<Map<String, dynamic>> _defaultSpaces = [
    {
      'id': 'space_fridge',
      'name': 'Ngăn mát',
      'itemCount': 12,
      'status': 'Có món sắp hết hạn',
      'template': 'Ngăn mát',
    },
    {
      'id': 'space_freezer',
      'name': 'Ngăn đông',
      'itemCount': 3,
      'status': 'Bảo quản tốt (-18°C)',
      'template': 'Ngăn đông',
    },
    {
      'id': 'space_dry',
      'name': 'Tủ bếp',
      'itemCount': 5,
      'status': 'Khô ráo',
      'template': 'Tủ bếp',
    },
    {
      'id': 'space_spices',
      'name': 'Gia vị',
      'itemCount': 4,
      'status': 'Đầy đủ',
      'template': 'Vị trí khác',
    },
  ];

  static const List<Map<String, dynamic>> _defaultProducts = [
    {
      'id': 'prod_1',
      'name': 'Sữa tươi TH True Milk 1L',
      'space': 'Ngăn mát',
      'badge': 'Còn 2 ngày',
      'expiry': '29/10/2026',
      'daysLeft': 2,
      'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
    },
    {
      'id': 'prod_2',
      'name': 'Rau muống',
      'space': 'Ngăn mát',
      'badge': 'Còn 1 ngày',
      'expiry': '28/10/2026',
      'daysLeft': 1,
      'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=80',
    },
    {
      'id': 'prod_4',
      'name': 'Ức gà tươi CP',
      'space': 'Ngăn đông',
      'badge': 'Còn 3 ngày',
      'expiry': '30/10/2026',
      'daysLeft': 3,
      'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=400&q=80',
    },
  ];

  static const List<Map<String, dynamic>> _defaultActivities = [
    {
      'text': 'Phan Hà đã thêm 3 thực phẩm vào Ngăn mát',
      'timeAgo': '10 phút trước',
    },
    {
      'text': 'Huỳnh Văn Lợi đã dùng hết Sữa chua Vinamilk',
      'timeAgo': '2 giờ trước',
    },
    {
      'text': 'Đã đồng bộ kho gia đình thành công',
      'timeAgo': 'Hôm qua',
    },
  ];

  // Sửa: 3 hàm Stream dùng generic đầy đủ
  Stream<QuerySnapshot<Map<String, dynamic>>> _spaces() {
    if (!firebaseReady) return const Stream.empty();
    return FirebaseFirestore.instance.collection('spaces').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _products() {
    if (!firebaseReady) return const Stream.empty();
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _activities() {
    if (!firebaseReady) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots();
  }

  // Tiện ích format thời gian cho Activities
  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Vừa xong';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  // Lấy icon chuẩn cho không gian
  IconData _getIconForTemplate(String template) {
    switch (template) {
      case 'Ngăn đông':
        return FontAwesomeIcons.snowflake;
      case 'Tủ bếp':
        return FontAwesomeIcons.kitchenSet;
      case 'Ngăn mát':
        return FontAwesomeIcons.temperatureLow;
      case 'Vị trí khác':
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  // HÀM HIỂN THỊ BOTTOM SHEET "KHO GIA ĐÌNH" THEO THIẾT KẾ
  // HÀM HIỂN THỊ BOTTOM SHEET "KHO GIA ĐÌNH" THEO THIẾT KẾ
  void _showKhoGiaDinhBottomSheet(BuildContext pageContext) {
    // Đóng sheet rồi chuyển sang màn hình tương ứng
    void goTo(BuildContext sheetContext, String route) {
      Navigator.pop(sheetContext);
      Navigator.pushNamed(pageContext, route);
    }

    // Đóng sheet rồi báo tính năng chưa có màn hình
    void comingSoon(BuildContext sheetContext, String feature) {
      Navigator.pop(sheetContext);
      ScaffoldMessenger.of(pageContext).showSnackBar(
        SnackBar(
          content: Text('$feature đang được phát triển'),
          backgroundColor: AppColors.brand,
        ),
      );
    }

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true, // Sửa: cho phép sheet cao hơn mặc định
      useSafeArea: true,        // Sửa: không bị đè lên thanh trạng thái
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView( // Sửa: nội dung cuộn được, hết overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Thanh kéo (Drag handle)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kho gia đình',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.title),
                ),
                const SizedBox(height: 8),
                // Danh sách các hành động
                _bottomSheetAction(Icons.add_circle, AppColors.brand, 'Thêm không gian lưu trữ', false,
                    () => goTo(sheetContext, '/space-add')),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.person_add_outlined, Colors.blueAccent, 'Mời thêm thành viên', false,
                    () => goTo(sheetContext, '/invite-family')),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.people_outline, Colors.blueAccent, 'Danh sách thành viên', false,
                    () => goTo(sheetContext, '/family-list')),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.sync, AppColors.gray, 'Đồng bộ và hoạt động', false,
                    () => goTo(sheetContext, '/realtime-sync')),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.calendar_today, Colors.orangeAccent, 'Lịch hạn dùng món ăn', false,
                    () => comingSoon(sheetContext, 'Lịch hạn dùng món ăn')),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.auto_awesome, Colors.purpleAccent, 'AI gợi ý món ăn từ Kho của bạn', false,
                    () => comingSoon(sheetContext, 'AI gợi ý món ăn')),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.sentiment_satisfied_alt, Colors.teal, 'Kế hoạch bữa ăn', false,
                    () => comingSoon(sheetContext, 'Kế hoạch bữa ăn')),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.warning_amber_rounded, AppColors.dangerStrong, 'Giải quyết xung đột (1)', true,
                    () => comingSoon(sheetContext, 'Giải quyết xung đột')),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Sửa: thêm tham số onTap để mỗi dòng điều hướng riêng
  Widget _bottomSheetAction(
    IconData icon,
    Color iconColor,
    String title,
    bool isDanger,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDanger ? AppColors.dangerStrong : AppColors.title,
          fontWeight: isDanger ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          // Sửa: StreamBuilder có generic đầy đủ
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _products(),
            builder: (context, productSnap) {
              final productDocs = productSnap.data?.docs ?? [];
              final List<Map<String, dynamic>> productItems = productDocs.isNotEmpty
                  ? productDocs.map((doc) => {'id': doc.id, ...doc.data()}).toList()
                  : _defaultProducts;

              final expiring = productItems.where((item) {
                final days = item['daysLeft'];
                return days is num && days <= 3;
              }).length;

              // Sửa: StreamBuilder có generic đầy đủ
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _spaces(),
                builder: (context, spaceSnap) {
                  final spaceDocs = spaceSnap.data?.docs ?? [];
                  final List<Map<String, dynamic>> spaceItems = spaceDocs.isNotEmpty
                      ? spaceDocs.map((doc) => {'id': doc.id, ...doc.data()}).toList()
                      : _defaultSpaces;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SỰ KIỆN CLICK MỞ BOTTOM SHEET
                                GestureDetector(
                                  onTap: () => _showKhoGiaDinhBottomSheet(context),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Kho gia đình',
                                        style: TextStyle(
                                          color: AppColors.title,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.keyboard_arrow_right, color: AppColors.title),
                                    ],
                                  ),
                                ),
                                const Text(
                                  'Quản lý thực phẩm trong nhà',
                                  style: TextStyle(color: AppColors.gray, fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                const Row(
                                  children: [
                                    Icon(Icons.circle, size: 8, color: AppColors.brand),
                                    SizedBox(width: 6),
                                    Text(
                                      'Đã đồng bộ',
                                      style: TextStyle(
                                        color: AppColors.brand,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/family-list'),
                            child: const Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.greenBg,
                                  backgroundImage: NetworkImage('https://picsum.photos/seed/avatar/200'),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppColors.accent,
                                    child: Icon(Icons.add, size: 12, color: AppColors.title),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statCard('${productItems.length}', 'Món đang lưu trữ', Colors.white, AppColors.title),
                          const SizedBox(width: 8),
                          _statCard('$expiring', 'Món sắp hết hạn', AppColors.dangerBg, AppColors.dangerStrong),
                          const SizedBox(width: 8),
                          _statCard('${spaceItems.length}', 'Khu vực lưu trữ', Colors.white, AppColors.brand),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Không gian lưu trữ', 'Xem tất cả', () => Navigator.pushNamed(context, '/storage-spaces')),
                      const SizedBox(height: 12),
                      
                      // RENDER SPACES TỪ FIREBASE (ƯU TIÊN FIREBASE, FALLBACK MẪU)
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: spaceItems.length,
                          itemBuilder: (context, index) {
                            final data = spaceItems[index];
                            final id = data['id']?.toString() ?? 'space_$index';
                            final iconTemplate = _getIconForTemplate(data['template']?.toString() ?? '');
                            final status = data['status']?.toString() ?? '';
                            final isWarning = status.toLowerCase().contains('hết hạn');

                            return _spaceCard(
                              context,
                              id,
                              data['name']?.toString() ?? 'Không gian',
                              '${data['itemCount'] ?? 0} món',
                              status,
                              iconTemplate,
                              isWarning,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Sắp hết hạn', 'Xem tất cả', () => Navigator.pushNamed(context, '/space-selected')),
                      const Text('Cần xử lý trong 3 ngày tới', style: TextStyle(color: AppColors.gray, fontSize: 13)),
                      const SizedBox(height: 12),

                      // RENDER PRODUCTS TỪ FIREBASE (Chỉ lấy món sắp hết hạn, ƯU TIÊN FIREBASE, FALLBACK MẪU)
                      if (productItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: Text('Không có món nào sắp hết hạn', style: TextStyle(color: AppColors.gray))),
                        )
                      else
                        ...productItems.where((item) {
                          final days = item['daysLeft'];
                          return days is num && days <= 3;
                        }).take(5).map((item) {
                          return _productRow(
                            context,
                            item['id']?.toString() ?? 'prod_item',
                            item['name']?.toString() ?? 'Sản phẩm',
                            item['space']?.toString() ?? 'Không gian',
                            item['badge']?.toString() ?? '',
                            item['expiry']?.toString() ?? '',
                            (item['daysLeft'] is num) && (item['daysLeft'] as num) < 0,
                            item['imageUrl']?.toString(),
                          );
                        }),
                      
                      const SizedBox(height: 12),
                      _sectionTitle('Hoạt động gần đây', 'Xem lịch sử', () => Navigator.pushNamed(context, '/realtime-sync')),

                      // RENDER ACTIVITIES TỪ FIREBASE (ƯU TIÊN FIREBASE, FALLBACK MẪU)
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _activities(),
                        builder: (context, snap) {
                          final actDocs = snap.data?.docs ?? [];
                          final List<Map<String, dynamic>> actItems = actDocs.isNotEmpty
                              ? actDocs.map((d) => d.data()).toList()
                              : _defaultActivities;

                          return Column(
                            children: actItems.map((data) {
                              final text = data['text']?.toString() ?? 'Hoạt động mới';
                              final time = data['createdAt'] is Timestamp
                                  ? _getTimeAgo(data['createdAt'] as Timestamp)
                                  : (data['timeAgo']?.toString() ?? 'Vừa xong');
                              return _activity(
                                text,
                                time,
                                30 + text.hashCode.abs() % 20,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBlue,
        onPressed: () => showAppSheet(context, const VirtualRefrigeratorBottomSheet()),
        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 1),
    );
  }

  Widget _statCard(String value, String label, Color bg, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String action, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: AppColors.title, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(color: AppColors.brand, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _spaceCard(
    BuildContext context,
    String? id,
    String name,
    String count,
    String badge,
    IconData icon,
    bool warning,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/space-selected', arguments: {
        'spaceId': id,
        'spaceName': name,
      }),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFEEF2FF),
              child: FaIcon(icon, size: 16, color: AppColors.navBlue),
            ),
            const Spacer(),
            Text(name, style: const TextStyle(color: AppColors.title, fontWeight: FontWeight.w700)),
            Text(count, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
            if (badge.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: warning ? AppColors.dangerBg : AppColors.greenBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: warning ? AppColors.dangerStrong : AppColors.brand,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _productRow(
    BuildContext context,
    String? id,
    String name,
    String space,
    String badge,
    String expiry,
    bool overdue,
    String? imageUrl,
  ) {
    return GestureDetector(
      onTap: () => showAppSheet(
        context,
        ProductSelectedBottomSheet(
          productId: id,
          name: name,
          subtitle: space,
          badge: badge,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Thay vì dùng AppNetworkImage với seed tĩnh, ưu tiên ảnh từ Firebase nếu có
            imageUrl != null && imageUrl.startsWith('data:image') 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    Uri.parse(imageUrl).data!.contentAsBytes(),
                    width: 48, height: 48, fit: BoxFit.cover,
                  ),
                )
              : AppNetworkImage(size: 48, seed: name.hashCode.abs() % 80 + 1),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: AppColors.title, fontWeight: FontWeight.w700)),
                  Text(space, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                  Text('Hết hạn: $expiry', style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: overdue ? AppColors.dangerBg : AppColors.accent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: overdue ? AppColors.dangerStrong : AppColors.title,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activity(String text, String time, int seed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://picsum.photos/seed/$seed/200'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(color: AppColors.title, fontSize: 14)),
                Text(time, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}