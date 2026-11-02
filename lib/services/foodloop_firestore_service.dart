import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodLoopFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  /// Lắng nghe danh sách báo cáo đang xử lý thời gian thực từ Firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveReports() {
    return _firestore
        .collection('reports')
        .where('isResolved', isEqualTo: false)
        .snapshots();
  }

  /// Lắng nghe danh sách báo cáo đã xử lý (lịch sử) thời gian thực từ Firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamResolvedReports() {
    return _firestore
        .collection('reports')
        .where('isResolved', isEqualTo: true)
        .snapshots();
  }

  /// Thêm một báo cáo mới do người dùng gửi lên Firestore
  static Future<void> addReport({
    required String reason,
    required String detail,
    required String productName,
    required String productSubtitle,
    String? productImage,
  }) async {
    final countSnap = await _firestore.collection('reports').get();
    final newCode = 'BC-${1000 + countSnap.docs.length + 1}';

    await _firestore.collection('reports').add({
      'code': newCode,
      'productName': productName,
      'productSubtitle': productSubtitle,
      'productImage': productImage ?? '',
      'status': 'Đang xử lý',
      'postStatus': 'Đang chờ duyệt',
      'isResolved': false,
      'reason': reason,
      'detail': detail,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': currentUserId ?? 'anonymous',
    });
  }

  /// Lắng nghe dữ liệu thông báo vi phạm và quyết định gỡ bài từ Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamFlaggedNotice() {
    return _firestore
        .collection('appeals')
        .doc('flagged_notice')
        .snapshots();
  }

  /// Gửi đơn kháng nghị của người dùng lên Firestore
  static Future<void> submitAppeal({
    required String productName,
    required String requestType,
    required String explanation,
  }) async {
    await _firestore.collection('appeals').add({
      'type': 'user_appeal',
      'productName': productName,
      'requestType': requestType,
      'explanation': explanation,
      'status': 'Đang xem xét',
      'createdAt': FieldValue.serverTimestamp(),
      'userId': currentUserId ?? 'anonymous',
    });
  }

  /// Lắng nghe dữ liệu sản phẩm đang bị xem xét/báo cáo từ Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamReportTargetProduct() {
    return _firestore
        .collection('products')
        .doc('target_report_product')
        .snapshots();
  }

  /// Lắng nghe thông tin cấu hình hỗ trợ tài khoản từ Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamAccountSupportInfo() {
    return _firestore
        .collection('appeals')
        .doc('account_support_info')
        .snapshots();
  }

  /// Gửi yêu cầu hỗ trợ tài khoản của người dùng lên Firestore
  static Future<void> submitSupportRequest({
    required String email,
    required String content,
  }) async {
    await _firestore.collection('appeals').add({
      'type': 'account_support',
      'email': email,
      'content': content,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'userId': currentUserId ?? 'anonymous',
    });
  }

  /// Lắng nghe cấu hình người dùng trực tiếp từ Firestore theo UID
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserSettings() {
    final uid = currentUserId ?? 'default_user';
    return _firestore.collection('settings').doc(uid).snapshots();
  }

  /// Cập nhật một thiết lập bất kỳ lên Firestore
  static Future<void> updateSetting(String key, dynamic value) async {
    final uid = currentUserId ?? 'default_user';
    await _firestore.collection('settings').doc(uid).set(
      {key: value},
      SetOptions(merge: true),
    );
  }

  /// Lắng nghe dữ liệu hồ sơ cộng đồng và điểm tin cậy từ collection 'users'
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamCommunityProfile([String? userId]) {
    final uid = userId ?? currentUserId ?? 'default_user';
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Lắng nghe danh sách lịch sử món quà đã chia sẻ từ collection 'products'
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamSharedHistory() {
    return _firestore
        .collection('products')
        .where('isShared', isEqualTo: true)
        .snapshots();
  }

  // ==============================================================
  // --- 7. FOOD SAFETY CHECK (KIỂM TRA AN TOÀN THỰC PHẨM - MÀN 81) ---
  // ==============================================================

  /// Lắng nghe thông tin sản phẩm và quy tắc kiểm tra an toàn thực phẩm từ Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamFoodSafetyCheck([String? docId]) {
    final targetId = docId ?? 'food_safety_check_target';
    return _firestore.collection('products').doc(targetId).snapshots();
  }

  /// Cập nhật kết quả kiểm tra an toàn thực phẩm lên Firestore
  static Future<void> submitFoodSafetyVerification({
    required String productId,
    required bool isPassed,
    required List<String> confirmedItems,
  }) async {
    await _firestore.collection('products').doc(productId).set({
      'isSafetyVerified': isPassed,
      'safetyConfirmedItems': confirmedItems,
      'safetyVerifiedAt': FieldValue.serverTimestamp(),
      'verifiedBy': currentUserId ?? 'anonymous',
    }, SetOptions(merge: true));
  }

  // =================================================================
  // --- 8. ACHIEVEMENTS & BADGES (HUY HIỆU THÀNH TỰU - MÀN 95) ---
  // =================================================================

  /// Lắng nghe danh sách huy hiệu thành tựu thời gian thực từ Firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAchievements() {
    return _firestore
        .collection('activities')
        .where('type', isEqualTo: 'achievement')
        .snapshots();
  }

  // =================================================================
  // --- 9. IMPACT TRENDS (XU HƯỚNG TÁC ĐỘNG - MÀN 96) ---
  // =================================================================

  /// Lắng nghe dữ liệu biểu đồ xu hướng tiết kiệm và rác thải từ Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamImpactTrends() {
    return _firestore
        .collection('activities')
        .doc('impact_trends')
        .snapshots();
  }

  // =================================================================
  // --- 10. RECEIVED THANKS & REPUTATION (LỜI CẢM ƠN ĐÃ NHẬN - MÀN 89) ---
  // =================================================================

  /// Lắng nghe dữ liệu lời cảm ơn, nhãn dán và lịch sử danh tiếng từ Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamReceivedThanksData() {
    return _firestore
        .collection('activities')
        .doc('received_thanks')
        .snapshots();
  }

  // =================================================================
  // --- 11. HONOR CARD (THẺ VINH DANH - MÀN 98) ---
  // =================================================================

  /// Lắng nghe dữ liệu số liệu thẻ vinh danh tác động xanh từ Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamHonorCardData() {
    return _firestore
        .collection('activities')
        .doc('honor_card')
        .snapshots();
  }

  // =================================================================
  // --- 12. RESCUE MARKET (CHỢ GIẢI CỨU - MÀN 61 - MODULE 6_7) ---
  // =================================================================

  /// Lắng nghe danh sách giỏ giải cứu / thực phẩm cận date từ Firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamRescueBaskets({String? category}) {
    Query<Map<String, dynamic>> query = _firestore.collection('rescue_baskets');
    if (category != null && category != 'Tất cả' && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots();
  }

  /// Đặt giữ chỗ giỏ hàng giải cứu (Màn 64)
  static Future<void> createRescueBooking({
    required String title,
    required String store,
    required int quantity,
    required int totalPrice,
    required String pickupTime,
    required String customerName,
    required String customerPhone,
  }) async {
    await _firestore.collection('rescue_orders').add({
      'title': title,
      'store': store,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'pickupTime': pickupTime,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'status': 'Giữ chỗ thành công',
      'paymentMethod': 'Trả tại cửa hàng',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': currentUserId ?? 'anonymous',
    });
  }

  /// Lắng nghe lịch sử đơn hàng giải cứu từ Firestore (Màn 70)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamRescueOrders() {
    return _firestore
        .collection('rescue_orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // =================================================================
  // --- 13. DASHBOARD & HOME (TRANG CHỦ - MODULE 1_2) ---
  // =================================================================

  /// Lắng nghe thông tin tài khoản người dùng từ collection 'users'
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile([String? userId]) {
    final uid = userId ?? currentUserId ?? 'default_user';
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Lắng nghe danh sách thực phẩm trong tủ lạnh của người dùng
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamFridgeItems([String? userId]) {
    return _firestore.collection('fridge_items').snapshots();
  }

  /// Lắng nghe danh sách thông báo của người dùng
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUserNotifications([String? userId]) {
    final uid = userId ?? currentUserId;
    if (uid != null && uid.isNotEmpty) {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('notify')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return _firestore.collection('notifications').snapshots();
  }
}
