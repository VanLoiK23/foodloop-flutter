 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_theme.dart';
import '../services/user_session.dart';

class Screen17ThongBao extends StatefulWidget {
  const Screen17ThongBao({super.key});

  @override
  State<Screen17ThongBao> createState() => _Screen17ThongBaoState();
}

class _Screen17ThongBaoState extends State<Screen17ThongBao> {
  // =========================
  // USER ID
  // =========================

  String? userId;

  // Collection notify của user hiện tại
  CollectionReference<Map<String, dynamic>>? notifyCollection;

  // =========================
  // MÀU SẮC
  // =========================

  static const Color textColor = Color(0xFF2B3A35);
  static const Color hintColor = Color(0xFF6B7280);
  static const Color primaryColor = Color(0xFF2D7C31);
  static const Color backgroundColor = Color(0xFFFFF8E7);
  static const Color yellowColor = Color(0xFFF4B942);
  static const Color redColor = Color(0xFFD64545);

  @override
  void initState() {
    super.initState();

    // Lấy userID từ session
    _loadUserAndNotifications();
  }

  // =========================
  // 1. LẤY USER ID TỪ SESSION
  // =========================

  Future<void> _loadUserAndNotifications() async {
    try {
      // Lấy UID của người dùng đang đăng nhập
      final String? id = await UserSession.getUserId();

      if (id == null || id.isEmpty) {
        debugPrint('Không tìm thấy userID trong session');
        return;
      }

      // Lưu userID
      userId = id;

      // =========================
      // Firestore:
      // users/{userID}/notify
      // =========================

      notifyCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('notify');

      // Kiểm tra và tạo thông báo mặc định
      await _checkAndCreateNotifications();

      // Cập nhật giao diện
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Lỗi lấy userID: $e');
    }
  }

  // =========================
  // 2. KIỂM TRA DATABASE
  // =========================

  Future<void> _checkAndCreateNotifications() async {
    if (notifyCollection == null) {
      return;
    }

    try {
      // Lấy 1 document để kiểm tra
      final snapshot = await notifyCollection!.limit(1).get();

      // Nếu user chưa có thông báo
      if (snapshot.docs.isEmpty) {
        await _createDefaultNotifications();
      }
    } catch (e) {
      debugPrint(
        'Lỗi kiểm tra collection notify: $e',
      );
    }
  }

  // =========================
  // 3. TẠO 4 THÔNG BÁO MẶC ĐỊNH
  // =========================

  Future<void> _createDefaultNotifications() async {
    if (notifyCollection == null) {
      return;
    }

    try {
      // Dùng batch để tạo 4 document cùng lúc
      final WriteBatch batch =
          FirebaseFirestore.instance.batch();

      // =========================
      // Thông báo 1
      // =========================

      final DocumentReference notification1 =
          notifyCollection!.doc('notification_1');

      batch.set(notification1, {
        'section': 'Hôm nay',
        'title': 'Sữa tươi TH True Milk',
        'status': 'Đã hết hạn',
        'time': '10 phút trước',
        'type': 'expired',
        'imageUrl': '',
        'order': 1,
      });

      // =========================
      // Thông báo 2
      // =========================

      final DocumentReference notification2 =
          notifyCollection!.doc('notification_2');

      batch.set(notification2, {
        'section': 'Tuần này',
        'title': 'Rau muống',
        'status': 'Còn 2 ngày',
        'time': '1 giờ trước',
        'type': 'warning',
        'imageUrl': '',
        'order': 2,
      });

      // =========================
      // Thông báo 3
      // =========================

      final DocumentReference notification3 =
          notifyCollection!.doc('notification_3');

      batch.set(notification3, {
        'section': 'Tuần này',
        'title': 'Phan Hà',
        'status': 'Vừa thêm 3 thực phẩm',
        'time': '2 giờ trước',
        'type': 'activity',
        'imageUrl': '',
        'order': 3,
      });

      // =========================
      // Thông báo 4
      // =========================

      final DocumentReference notification4 =
          notifyCollection!.doc('notification_4');

      batch.set(notification4, {
        'section': 'Tuần này',
        'title': 'Báo cáo tiêu thụ tuần',
        'status': 'Đã sẵn sàng',
        'time': '5 ngày trước',
        'type': 'report',
        'imageUrl': '',
        'order': 4,
      });

      // Lưu cả 4 document
      await batch.commit();

      debugPrint(
        'Đã tạo 4 thông báo cho user: $userId',
      );
    } catch (e) {
      debugPrint(
        'Lỗi tạo thông báo mặc định: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =========================
      // 4. NỘI DUNG CHÍNH
      // =========================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // =========================
              // 5. HEADER
              // =========================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // Nút quay lại
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: textColor,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Tiêu đề
                    const Text(
                      'Thông báo',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // 6. DANH SÁCH THÔNG BÁO
              // =========================

              Expanded(
                child: _buildNotificationList(),
              ),
            ],
          ),
        ),
      ),

      // =========================
      // 7. NÚT THÊM
      // =========================

      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: yellowColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            // TODO: Xử lý nút thêm
          },
          icon: const Icon(
            Icons.add,
            color: textColor,
            size: 28,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      // =========================
      // 8. BOTTOM NAVIGATION CHUẨN
      // =========================

      bottomNavigationBar: const FoodLoopBottomNav(
        currentIndex: 0,
      ),
    );
  }

  // =========================
  // 9. HIỂN THỊ DANH SÁCH
  // =========================

  Widget _buildNotificationList() {
    // Chưa lấy được userID
    if (userId == null || notifyCollection == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      // Đọc realtime notify của user hiện tại
      stream: notifyCollection!.snapshots(),

      builder: (
        context,
        snapshot,
      ) {
        // =========================
        // ĐANG TẢI
        // =========================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }

        // =========================
        // CÓ LỖI
        // =========================

        if (snapshot.hasError) {
          debugPrint(
            'Lỗi đọc notify: ${snapshot.error}',
          );

          return const Center(
            child: Text(
              'Không thể tải thông báo',
              style: TextStyle(
                color: hintColor,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          );
        }

        // =========================
        // KHÔNG CÓ DỮ LIỆU
        // =========================

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có thông báo',
              style: TextStyle(
                color: hintColor,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          );
        }

        // =========================
        // LẤY DANH SÁCH
        // =========================

        final List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>> notifications =
            snapshot.data!.docs.toList();

        // =========================
        // SẮP XẾP THEO ORDER
        // =========================

        notifications.sort(
          (a, b) {
            final int orderA =
                a.data()['order'] ?? 999;

            final int orderB =
                b.data()['order'] ?? 999;

            return orderA.compareTo(orderB);
          },
        );

        // =========================
        // CHIA THÀNH 2 NHÓM
        // =========================

        final List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>> todayNotifications =
            notifications.where((doc) {
          return doc.data()['section'] == 'Hôm nay';
        }).toList();

        final List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>> weekNotifications =
            notifications.where((doc) {
          return doc.data()['section'] == 'Tuần này';
        }).toList();

        // =========================
        // HIỂN THỊ
        // =========================

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =========================
              // NHÓM HÔM NAY
              // =========================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (todayNotifications.isNotEmpty) ...[
                      const Text(
                        'Hôm nay',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Các thông báo hôm nay
                      ...todayNotifications.map(
                        (doc) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child:
                                _buildNotificationFromDatabase(
                              doc,
                            ),
                          );
                        },
                      ),
                    ],

                    // =========================
                    // NHÓM TUẦN NÀY
                    // =========================

                    if (weekNotifications.isNotEmpty) ...[
                      const SizedBox(height: 16),

                      const Text(
                        'Tuần này',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Các thông báo trong tuần
                      ...weekNotifications.map(
                        (doc) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child:
                                _buildNotificationFromDatabase(
                              doc,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // 10. CARD TỪ DATABASE
  // =========================

  Widget _buildNotificationFromDatabase(
    QueryDocumentSnapshot<
        Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data =
        doc.data();

    // Lấy dữ liệu Firestore
    final String title =
        data['title'] ?? '';

    final String status =
        data['status'] ?? '';

    final String time =
        data['time'] ?? '';

    final String type =
        data['type'] ?? '';

    final String imageUrl =
        data['imageUrl'] ?? '';

    // =========================
    // THÔNG BÁO HẾT HẠN
    // =========================

    if (type == 'expired') {
      return _buildExpiredNotification(
        title: title,
        status: status,
        time: time,
        imageUrl: imageUrl,
      );
    }

    // =========================
    // CÁC THÔNG BÁO CÒN LẠI
    // =========================

    return _buildFoodNotification(
      imageUrl: imageUrl,
      title: title,
      status: status,
      time: time,
      type: type,
    );
  }

  // =========================
  // 11. THÔNG BÁO HẾT HẠN
  // =========================

  Widget _buildExpiredNotification({
    required String title,
    required String status,
    required String time,
    required String imageUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.black.withOpacity(0.22),
          ),
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // Hình ảnh
          _buildNotificationImage(
            imageUrl: imageUrl,
            icon: Icons.local_drink_outlined,
            color: primaryColor,
          ),

          const SizedBox(width: 12),

          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // Tên thực phẩm
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                // Trạng thái
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration:
                      BoxDecoration(
                    color: redColor,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                // Thời gian
                Text(
                  time,
                  style: const TextStyle(
                    color: hintColor,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Mũi tên
          const Icon(
            Icons.chevron_right,
            color: hintColor,
            size: 22,
          ),
        ],
      ),
    );
  }

  // =========================
  // 12. THÔNG BÁO TRONG TUẦN
  // =========================

  Widget _buildFoodNotification({
    required String imageUrl,
    required String title,
    required String status,
    required String time,
    required String type,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.black.withOpacity(0.27),
          ),
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Hình ảnh
          _buildNotificationImage(
            imageUrl: imageUrl,
            icon: Icons.image_outlined,
            color: hintColor,
          ),

          const SizedBox(width: 10),

          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // Tên
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                // Trạng thái
                if (type == 'warning')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration:
                        BoxDecoration(
                      color: yellowColor,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: textColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style:
                              const TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    status,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: hintColor,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight:
                          FontWeight.w400,
                    ),
                  ),

                const SizedBox(height: 2),

                // Thời gian
                Text(
                  time,
                  style: const TextStyle(
                    color: hintColor,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight:
                        FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Mũi tên
          const Icon(
            Icons.chevron_right,
            color: hintColor,
            size: 22,
          ),
        ],
      ),
    );
  }

  // =========================
  // 13. HÌNH ẢNH
  // =========================

  Widget _buildNotificationImage({
    required String imageUrl,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: imageUrl.isEmpty
          ? Icon(
              icon,
              color: color,
              size: 22,
            )
          : ClipRRect(
              borderRadius:
                  BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Icon(
                    icon,
                    color: color,
                    size: 22,
                  );
                },
              ),
            ),
    );
  }
}
 