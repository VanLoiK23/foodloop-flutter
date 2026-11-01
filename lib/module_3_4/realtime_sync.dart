import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';

class RealtimeSync extends StatefulWidget {
  const RealtimeSync({super.key});

  @override
  State<RealtimeSync> createState() => _RealtimeSyncState();
}

class _RealtimeSyncState extends State<RealtimeSync> {
  String filter = 'Tất cả';

  // Lọc hoạt động dựa trên từ khóa trong Firebase
  // Sửa: thêm generic <Map<String, dynamic>> cho QueryDocumentSnapshot
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterActivities(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> activities) {
    if (filter == 'Tất cả') return activities;
    
    return activities.where((doc) {
      final text = (doc.data()['text']?.toString() ?? '').toLowerCase();
      if (filter == 'Thêm') {
        return text.contains('thêm') || text.contains('tạo');
      }
      if (filter == 'Chỉnh sửa') {
        return text.contains('sửa') || text.contains('cập nhật');
      }
      if (filter == 'Đã dùng' || filter == 'Xóa') {
        return text.contains('xóa') || text.contains('dùng');
      }
      return true;
    }).toList();
  }

  // Format thời gian từ Timestamp
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Vừa xong';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Hôm nay lúc ${DateFormat('HH:mm').format(date)}';
    } else if (dateToCheck == yesterday) {
      return 'Hôm qua lúc ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  // Gán Icon dựa trên text hoạt động
  FaIconData _getIconForActivity(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('thêm') || lowerText.contains('tạo')) return FontAwesomeIcons.plus;
    if (lowerText.contains('cập nhật') || lowerText.contains('sửa')) return FontAwesomeIcons.pen;
    if (lowerText.contains('xóa') || lowerText.contains('hỏng')) return FontAwesomeIcons.trashCan;
    if (lowerText.contains('dùng') || lowerText.contains('đánh dấu')) return FontAwesomeIcons.check;
    if (lowerText.contains('đồng bộ')) return FontAwesomeIcons.sync;
    return FontAwesomeIcons.clockRotateLeft;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          // Sửa: StreamBuilder có generic đầy đủ
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firebaseReady
                ? FirebaseFirestore.instance
                    .collection('activities')
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                : const Stream.empty(),
            builder: (context, snapshot) {
              final rawActivities = snapshot.data?.docs ?? [];
              final filteredActivities = _filterActivities(rawActivities);
              
              // Tính thời gian đồng bộ cuối cùng
              final lastSync = rawActivities.isNotEmpty 
                  ? _formatTime(rawActivities.first.data()['createdAt'] as Timestamp?)
                  : 'Chưa đồng bộ';

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/virtual-fridge'),
                        icon: const Icon(Icons.arrow_back, color: AppColors.title),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đồng bộ & hoạt động',
                              style: TextStyle(color: AppColors.title, fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Theo dõi thay đổi trong kho gia đình',
                              style: TextStyle(color: AppColors.gray, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (!firebaseReady) return;
                          await FirebaseFirestore.instance.collection('activities').add({
                            'text': 'Đã đồng bộ dữ liệu kho gia đình',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        },
                        icon: const Icon(Icons.sync, color: AppColors.brand),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.greenBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.brand),
                            SizedBox(width: 8),
                            Text('Đã đồng bộ', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.brand)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Dữ liệu đã được cập nhật', style: TextStyle(color: AppColors.title)),
                        Text('Lần đồng bộ gần nhất: $lastSync', style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lịch sử hoạt động',
                    style: TextStyle(color: AppColors.title, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8,
                      children: ['Tất cả', 'Thêm', 'Chỉnh sửa', 'Đã dùng']
                          .map(
                            (item) => ChoiceChip(
                              label: Text(item),
                              selected: filter == item,
                              selectedColor: AppColors.brand.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: filter == item ? AppColors.brand : AppColors.gray,
                                fontWeight: filter == item ? FontWeight.w600 : FontWeight.normal,
                              ),
                              onSelected: (_) => setState(() => filter = item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // HIỂN THỊ DỮ LIỆU TỪ FIREBASE
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator(color: AppColors.brand)),
                    )
                  else if (filteredActivities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Không có hoạt động nào phù hợp.',
                          style: TextStyle(color: AppColors.gray, fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    ...filteredActivities.map((doc) {
                      final data = doc.data();
                      final text = data['text']?.toString() ?? 'Hoạt động';
                      final timestamp = data['createdAt'] as Timestamp?;
                      
                      return _row(
                        text,
                        _formatTime(timestamp),
                        _getIconForActivity(text),
                        doc.id.hashCode.abs() % 50 + 1, // Tạo avatar ngẫu nhiên dựa trên ID
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 4),
    );
  }

  Widget _row(String text, String time, FaIconData icon, int seed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://picsum.photos/seed/$seed/200'),
            backgroundColor: AppColors.cream,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text, 
                  style: const TextStyle(color: AppColors.title, fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.greenBg,
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, size: 14, color: AppColors.brand),
          ),
        ],
      ),
    );
  }
}