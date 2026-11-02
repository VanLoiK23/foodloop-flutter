import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';
// import 'product_selected_bottom_sheet.dart';
import 'space_selected_action_bottom_sheet.dart';
// import 'virtual_refrigerator_bottom_sheet.dart';

class SpaceSelected extends StatefulWidget {
  const SpaceSelected({super.key});

  @override
  State<SpaceSelected> createState() => _SpaceSelectedState();
}

class _SpaceSelectedState extends State<SpaceSelected> {
  String filter = 'Tất cả';
  String sortOption = 'Gần hết hạn nhất';
  TextEditingController searchController = TextEditingController();

  // Helper method to format time if needed, though not strictly required here based on design
  // ignore: unused_element
  String _formatTime(Timestamp? timestamp) {
      if (timestamp == null) return 'Vừa xong';
      return '...'; // Placeholder if needed later
  }

  // Define Badge Colors based on daysLeft
  Map<String, Color> _getBadgeColors(int daysLeft) {
    if (daysLeft < 0) {
      return {'bg': AppColors.dangerStrong, 'text': Colors.white};
    } else if (daysLeft <= 3) {
      return {'bg': const Color(0xFFF4B942), 'text': const Color(0xFF2B3A35)};
    } else {
      return {'bg': AppColors.greenBg, 'text': AppColors.brand};
    }
  }

  void _showProductActionBottomSheet(BuildContext context, String productId, String productName, String spaceName, int daysLeft, String qty, String imageUrl) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final badgeColors = _getBadgeColors(daysLeft);
          final badgeText = daysLeft < 0 ? 'Quá hạn ${daysLeft.abs()} ngày' : 'Còn $daysLeft ngày';

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                    leading: imageUrl.startsWith('data:image') 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            Uri.parse(imageUrl).data!.contentAsBytes(),
                            width: 48, height: 48, fit: BoxFit.cover,
                          ),
                        )
                      : AppNetworkImage(size: 48, seed: productName.hashCode.abs() % 80 + 10),
                    title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.title)),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('$qty - $spaceName', style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: badgeColors['bg'],
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                    badgeText,
                                    style: TextStyle(color: badgeColors['text'], fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                            )
                        ]
                    )
                ),
                const Divider(),
                _bottomSheetAction(Icons.share_outlined, AppColors.brand, 'Chia sẻ 1 chạm', false, () {}),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.check_circle_outline, AppColors.title, 'Đã dùng hết', false, () {
                    _deleteProduct(productId, spaceName, productName, 'Đã đánh dấu dùng hết $productName');
                }),
                const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48, endIndent: 20),
                _bottomSheetAction(Icons.delete_outline, AppColors.dangerStrong, 'Bỏ đi', true, () {
                    _showDeleteConfirmationDialog(context, productId, spaceName, productName);
                }),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
  }

  // Sửa: IconData -> IconData (vì truyền vào là Icons.*)
  Widget _bottomSheetAction(IconData icon, Color iconColor, String title, bool isDanger, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDanger ? AppColors.dangerStrong : AppColors.title,
          fontWeight: isDanger ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
          Navigator.pop(context); // Close Bottom Sheet first
          onTap();
      },
    );
  }

  Future<void> _deleteProduct(String productId, String spaceName, String productName, String activityText) async {
       try {
            await FirebaseFirestore.instance.collection('products').doc(productId).delete();
            
            // Decrease itemCount in spaces
            final spaceQuery = await FirebaseFirestore.instance
                .collection('spaces')
                .where('name', isEqualTo: spaceName)
                .limit(1)
                .get();

            if (spaceQuery.docs.isNotEmpty) {
                final spaceDocId = spaceQuery.docs.first.id;
                await FirebaseFirestore.instance.collection('spaces').doc(spaceDocId).update({
                    'itemCount': FieldValue.increment(-1),
                });
            }

            // Log activity
            await FirebaseFirestore.instance.collection('activities').add({
                'text': activityText,
                'createdAt': FieldValue.serverTimestamp(),
            });

            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã cập nhật $productName'), backgroundColor: AppColors.brand),
                );
            }
       } catch (e) {
           if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.dangerStrong),
                );
            }
       }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String productId, String spaceName, String productName) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn bỏ đi $productName?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Hủy', style: TextStyle(color: AppColors.gray)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Bỏ đi', style: TextStyle(color: AppColors.dangerStrong)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteProduct(productId, spaceName, productName, 'Đã bỏ đi $productName');
                },
              ),
            ],
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final spaceId = args?['spaceId']?.toString();
    final spaceName = args?['spaceName']?.toString() ?? 'Ngăn mát';

    // Sửa: generic đầy đủ cho Stream
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream = !firebaseReady
        ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
        : FirebaseFirestore.instance
            .collection('products')
            .where('space', isEqualTo: spaceName) // Filter by space name
            .snapshots();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          // Sửa: StreamBuilder có generic đầy đủ
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              var products = snapshot.data?.docs ?? [];
              
              // Search filtering
              if (searchController.text.isNotEmpty) {
                  products = products.where((doc) => (doc.data()['name']?.toString() ?? '').toLowerCase().contains(searchController.text.toLowerCase())).toList();
              }

              // Status filtering based on 'daysLeft'
              if (filter == 'Sắp hết hạn') {
                  products = products.where((doc) {
                      final days = doc.data()['daysLeft'];
                      return days is num && days >= 0 && days <= 3;
                  }).toList();
              } else if (filter == 'Đã quá hạn') {
                   products = products.where((doc) {
                      final days = doc.data()['daysLeft'];
                      return days is num && days < 0;
                  }).toList();
              } else if (filter == 'Chưa có hạn') {
                  products = products.where((doc) => doc.data()['noExpiry'] == true).toList();
              }

              // Sorting
              if (sortOption == 'Gần hết hạn nhất') {
                  products.sort((a, b) {
                      final aDays = a.data()['daysLeft'] as num? ?? double.infinity;
                      final bDays = b.data()['daysLeft'] as num? ?? double.infinity;
                      return aDays.compareTo(bDays);
                  });
              } else if (sortOption == 'Mới thêm') {
                   products.sort((a, b) {
                      final aTime = a.data()['createdAt'] as Timestamp? ?? Timestamp(0,0);
                      final bTime = b.data()['createdAt'] as Timestamp? ?? Timestamp(0,0);
                      return bTime.compareTo(aTime); // Descending
                  });
              }

              final expiringCount = products.where((doc) {
                  final days = doc.data()['daysLeft'];
                  return days is num && days >= 0 && days <= 3;
              }).length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.title),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spaceName,
                              style: const TextStyle(
                                color: AppColors.title,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                                children: [
                                    Text(
                                    '${products.length} món đang lưu trữ',
                                    style: const TextStyle(color: AppColors.gray, fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.check_circle, size: 12, color: AppColors.brand),
                                    const SizedBox(width: 4),
                                    const Text('Đã đồng bộ', style: TextStyle(color: AppColors.brand, fontSize: 12, fontWeight: FontWeight.bold))
                                ]
                            )
                            
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => showAppSheet(
                          context,
                          SpaceSelectedActionBottomSheet(spaceId: spaceId, spaceName: spaceName),
                        ),
                        icon: const Icon(Icons.more_horiz, color: AppColors.title),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    // Sửa: generic đầy đủ cho StreamBuilder của danh sách spaces
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>( // Fetch all spaces for the top scroller
                        stream: FirebaseFirestore.instance.collection('spaces').snapshots(),
                        builder: (context, spaceSnapshot) {
                             final spaceDocs = spaceSnapshot.data?.docs ?? [];
                             return ListView(
                                scrollDirection: Axis.horizontal,
                                children: spaceDocs.map((doc) {
                                    final name = doc.data()['name']?.toString() ?? '';
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(name),
                                        selected: name == spaceName,
                                        selectedColor: AppColors.brand,
                                        labelStyle: TextStyle(color: name == spaceName ? Colors.white : AppColors.title),
                                        onSelected: (_) => Navigator.pushReplacementNamed(
                                          context,
                                          '/space-selected',
                                          arguments: {'spaceId': doc.id, 'spaceName': name},
                                        ),
                                      ),
                                    );
                                }).toList()
                             );
                        }
                    )
                  ),
                  const SizedBox(height: 12),
                  if (expiringCount > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                            children: [
                                Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: AppColors.dangerStrong.withOpacity(0.1),
                                        shape: BoxShape.circle
                                    ),
                                    child: const Icon(Icons.history, color: AppColors.dangerStrong)
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$expiringCount món sắp hết hạn', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.title)),
                                        const Text('Kiểm tra ngay để tránh lãng phí', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                                      ],
                                    ),
                                ),
                                const Text('Xem đồ sắp hết hạn', style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.bold, fontSize: 12)),
                                const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.brand)
                            ]
                        )
                      ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    onChanged: (_) => setState((){}),
                    decoration: InputDecoration(
                      hintText: 'Tìm thực phẩm trong $spaceName',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        children: ['Tất cả', 'Sắp hết hạn', 'Đã quá hạn', 'Chưa có hạn']
                            .map(
                              (item) => ChoiceChip(
                                label: Text(item),
                                selected: filter == item,
                                selectedColor: AppColors.brand,
                                labelStyle: TextStyle(color: filter == item ? Colors.white : AppColors.title),
                                onSelected: (_) => setState(() => filter = item),
                              ),
                            )
                            .toList(),
                      ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text(
                            '${products.length} mặt hàng',
                            style: const TextStyle(color: AppColors.title, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          DropdownButton<String>(
                              value: sortOption,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                              elevation: 16,
                              style: const TextStyle(color: AppColors.gray, fontSize: 13),
                              underline: Container(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  sortOption = newValue!;
                                });
                              },
                              items: <String>['Gần hết hạn nhất', 'Mới thêm']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                      ]
                  ),
                  
                  const SizedBox(height: 8),
                  if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                  else if (products.isEmpty)
                     const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('Không có thực phẩm nào phù hợp', style: TextStyle(color: AppColors.gray))),
                     )
                  else
                    ...products.map((doc) {
                      final data = doc.data();
                      final daysLeft = data['daysLeft'] as int? ?? 0;
                      return _item(
                        context,
                        doc.id,
                        data['name']?.toString() ?? 'Sản phẩm',
                        '${data['quantity'] ?? ''} ${data['unit'] ?? ''}'.trim(),
                        daysLeft,
                        data['imageUrl']?.toString() ?? '',
                        spaceName
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF4B942), // Accent color for FAB
        onPressed: () => Navigator.pushNamed(context, '/import-product'), // Navigate to add product
        child: const Icon(Icons.add, color: AppColors.title),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 1),
    );
  }

  Widget _item(BuildContext context, String? id, String name, String qty, int daysLeft, String imageUrl, String spaceName) {
    final badgeColors = _getBadgeColors(daysLeft);
    final badgeText = daysLeft < 0 ? 'Quá hạn ${daysLeft.abs()} ngày' : 'Còn $daysLeft ngày';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () {
            // Placeholder for viewing product details if needed, currently opens action sheet based on design
        },
        leading: imageUrl.isNotEmpty && imageUrl.startsWith('data:image') 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    Uri.parse(imageUrl).data!.contentAsBytes(),
                    width: 48, height: 48, fit: BoxFit.cover,
                  ),
                )
              : AppNetworkImage(size: 48, seed: name.hashCode.abs() % 80 + 10),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.title)),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(qty, style: const TextStyle(color: AppColors.gray)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColors['bg'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                           if(daysLeft < 0)
                                const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(Icons.warning_amber_rounded, size: 10, color: Colors.white)
                                )
                            else
                                Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(Icons.schedule, size: 10, color: badgeColors['text'])
                                ),
                          Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColors['text'],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ]
                  )
                  
                ),
            ]
        ),
        trailing: IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.gray),
            onPressed: () => _showProductActionBottomSheet(context, id!, name, spaceName, daysLeft, qty, imageUrl)
        ),
      ),
    );
  }
}