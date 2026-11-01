import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../app_theme.dart';
import '../models/food_post_model.dart';
import '../models/food_request_model.dart';

class FoodService {
  static final FoodService instance = FoodService._();
  FoodService._();

  // Danh sách dữ liệu mẫu chuẩn theo Figma để seed hoặc fallback
  static List<FoodPost> get defaultPosts => [
        FoodPost(
          id: 'post_banhmi_01',
          title: 'Bánh mì ngọt',
          category: 'Bánh mì',
          type: 'Cho',
          totalQuantity: 4,
          remainingQuantity: 4,
          unit: 'cái',
          daysLeft: 1,
          badge: 'Còn 1 ngày',
          distanceMeters: 250,
          pickupTime: '17:00 - 19:00',
          timeSlots: [
            '17:00 - 17:30',
            '17:30 - 18:00',
            '18:00 - 18:30',
            '18:30 - 19:00',
          ],
          condition: 'Còn nguyên túi, mua sáng nay',
          giverName: 'Lan Anh',
          giverAvatar: 'LA',
          giverRating: 4.8,
          giverShares: 12,
          addressHint: 'Địa chỉ chính xác hiện sau khi được duyệt',
          xPercent: 0.65,
          yPercent: 0.38,
          iconType: 'bread',
          status: 'available',
          createdAt: DateTime.now(),
        ),
        FoodPost(
          id: 'post_sua_02',
          title: 'Sữa tươi TH True Milk',
          category: 'Sữa',
          type: 'Cho',
          totalQuantity: 2,
          remainingQuantity: 2,
          unit: 'hộp',
          daysLeft: 2,
          badge: 'Còn 2 ngày',
          distanceMeters: 300,
          pickupTime: '08:00 - 20:00',
          timeSlots: [
            '08:00 - 11:00',
            '14:00 - 17:00',
            '18:00 - 20:00',
          ],
          condition: 'Hạn dùng còn 2 ngày, để ngăn mát từ lúc mua',
          giverName: 'Bảo An',
          giverAvatar: 'BA',
          giverRating: 4.9,
          giverShares: 8,
          addressHint: 'Địa chỉ chính xác hiện sau khi được duyệt',
          xPercent: 0.40,
          yPercent: 0.60,
          iconType: 'milk',
          status: 'available',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        FoodPost(
          id: 'post_trung_03',
          title: 'Trứng gà',
          category: 'Trứng',
          type: 'Xin',
          totalQuantity: 6,
          remainingQuantity: 6,
          unit: 'quả',
          daysLeft: 3,
          badge: 'Cần xin gấp',
          distanceMeters: 450,
          pickupTime: 'Tự đến lấy chiều nay',
          timeSlots: [
            '15:00 - 17:00',
            '17:00 - 19:00',
          ],
          condition: 'Cần xin làm bánh cho nhóm sinh viên',
          giverName: 'Quốc Huy',
          giverAvatar: 'QH',
          giverRating: 4.6,
          giverShares: 3,
          addressHint: 'Địa chỉ chính xác hiện sau khi được duyệt',
          xPercent: 0.72,
          yPercent: 0.70,
          iconType: 'egg',
          status: 'available',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        FoodPost(
          id: 'post_raucai_04',
          title: 'Rau cải xanh',
          category: 'Rau củ',
          type: 'Cho',
          totalQuantity: 1,
          remainingQuantity: 1,
          unit: 'bó',
          daysLeft: 1,
          badge: 'Còn 1 ngày',
          distanceMeters: 800,
          pickupTime: '16:00 - 21:00',
          timeSlots: [
            '16:00 - 18:00',
            '19:00 - 21:00',
          ],
          condition: 'Rau quê gửi lên nhiều ăn không hết',
          giverName: 'Thu Hà',
          giverAvatar: 'TH',
          giverRating: 4.9,
          giverShares: 15,
          addressHint: 'Địa chỉ chính xác hiện sau khi được duyệt',
          xPercent: 0.28,
          yPercent: 0.35,
          iconType: 'vegetable',
          status: 'available',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        FoodPost(
          id: 'post_thit_05',
          title: 'Ức gà tươi CP',
          category: 'Thịt cá',
          type: 'Cho',
          totalQuantity: 2,
          remainingQuantity: 2,
          unit: 'khay',
          daysLeft: 1,
          badge: 'Còn 1 ngày',
          distanceMeters: 620,
          pickupTime: '18:00 - 20:00',
          timeSlots: [
            '18:00 - 19:00',
            '19:00 - 20:00',
          ],
          condition: 'Mua tại WinMart sáng nay, chưa mở bao bì',
          giverName: 'Thanh Trúc',
          giverAvatar: 'TT',
          giverRating: 5.0,
          giverShares: 6,
          addressHint: 'Địa chỉ chính xác hiện sau khi được duyệt',
          xPercent: 0.52,
          yPercent: 0.25,
          iconType: 'meat',
          status: 'available',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];

  // In-memory fallback
  final List<FoodPost> _localPosts = List.from(defaultPosts);
  final List<FoodRequest> _localRequests = [];
  final StreamController<List<FoodRequest>> _localRequestsController =
      StreamController<List<FoodRequest>>.broadcast();

  /// Tự động seed dữ liệu mẫu lên Firestore nếu collection chưa có bài nào
  Future<void> seedInitialDataIfEmpty() async {
    if (!firebaseReady) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('food_posts')
          .limit(1)
          .get()
          .timeout(const Duration(milliseconds: 2000));

      if (snap.docs.isEmpty) {
        debugPrint('Bắt đầu Seed dữ liệu food_posts lên Firestore...');
        final batch = FirebaseFirestore.instance.batch();
        for (var p in defaultPosts) {
          final docRef = FirebaseFirestore.instance.collection('food_posts').doc(p.id);
          batch.set(docRef, p.toMap());
        }
        await batch.commit().timeout(const Duration(milliseconds: 2000));
        debugPrint('Seed dữ liệu food_posts thành công!');
      }
    } catch (e) {
      debugPrint('Không kết nối được Firestore thật (dùng dữ liệu demo): $e');
    }
  }

  /// Stream lấy danh sách bài đăng thực phẩm quanh bạn (có hỗ trợ filter)
  Stream<List<FoodPost>> getFoodPostsStream({
    String typeFilter = 'Tất cả', // 'Tất cả', 'Cho', 'Xin'
    String? categoryFilter,       // 'Thịt cá', 'Rau củ', etc.
    int? maxDistanceMeters,       // 500, 1000, 2000
  }) {
    if (firebaseReady) {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('food_posts');

      if (typeFilter != 'Tất cả') {
        query = query.where('type', isEqualTo: typeFilter);
      }
      if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'Tất cả') {
        query = query.where('category', isEqualTo: categoryFilter);
      }

      return query.snapshots().map((snap) {
        if (snap.docs.isEmpty) {
          return <FoodPost>[];
        }
        var list = snap.docs.map((doc) => FoodPost.fromFirestore(doc)).toList();
        if (maxDistanceMeters != null) {
          list = list.where((p) => p.distanceMeters <= maxDistanceMeters).toList();
        }
        return list;
      }).handleError((error) {
        debugPrint('Firestore query error: $error, fallback to local');
        return _filterLocal(typeFilter, categoryFilter, maxDistanceMeters);
      });
    }

    // Fallback in-memory
    return Stream.value(_filterLocal(typeFilter, categoryFilter, maxDistanceMeters));
  }

  List<FoodPost> _filterLocal(String type, String? category, int? maxDistance) {
    return _localPosts.where((p) {
      if (type != 'Tất cả' && p.type != type) return false;
      if (category != null && category.isNotEmpty && category != 'Tất cả' && p.category != category) {
        return false;
      }
      if (maxDistance != null && p.distanceMeters > maxDistance) return false;
      return true;
    }).toList();
  }

  /// Lấy chi tiết 1 bài đăng theo ID
  Future<FoodPost?> getFoodPostById(String id) async {
    if (firebaseReady) {
      try {
        final doc = await FirebaseFirestore.instance.collection('food_posts').doc(id).get();
        if (doc.exists) {
          return FoodPost.fromFirestore(doc);
        }
      } catch (e) {
        debugPrint('Lỗi getFoodPostById: $e');
      }
    }
    try {
      return _localPosts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gửi yêu cầu xin nhận thực phẩm (Màn 58)
  Future<FoodRequest> createFoodRequest({
    required FoodPost post,
    required int quantity,
    required String timeSlot,
    required String message,
  }) async {
    final now = DateTime.now();
    final reqId = 'req_${now.millisecondsSinceEpoch}';

    final request = FoodRequest(
      id: reqId,
      postId: post.id,
      foodTitle: post.title,
      giverName: post.giverName,
      requestedQuantity: quantity,
      unit: post.unit,
      timeSlot: timeSlot,
      message: message,
      status: 'pending',
      pickupAddress: 'Địa chỉ cụ thể sẽ mở khi ${post.giverName} đồng ý',
      createdAt: now,
    );

    // 1. Cập nhật ngay vào local memory
    _localRequests.insert(0, request);
    _localRequestsController.add(List.from(_localRequests));

    // 2. Giảm số lượng còn lại trong local
    final postIdx = _localPosts.indexWhere((p) => p.id == post.id);
    if (postIdx != -1) {
      final old = _localPosts[postIdx];
      final rem = old.remainingQuantity - quantity;
      _localPosts[postIdx] = FoodPost(
        id: old.id,
        title: old.title,
        category: old.category,
        type: old.type,
        totalQuantity: old.totalQuantity,
        remainingQuantity: rem > 0 ? rem : 0,
        unit: old.unit,
        daysLeft: old.daysLeft,
        badge: old.badge,
        distanceMeters: old.distanceMeters,
        pickupTime: old.pickupTime,
        timeSlots: old.timeSlots,
        condition: old.condition,
        giverName: old.giverName,
        giverAvatar: old.giverAvatar,
        giverRating: old.giverRating,
        giverShares: old.giverShares,
        addressHint: old.addressHint,
        xPercent: old.xPercent,
        yPercent: old.yPercent,
        iconType: old.iconType,
        status: rem <= 0 ? 'completed' : old.status,
        createdAt: old.createdAt,
      );
    }

    // Delay giả lập 500ms cho loading mượt mà
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Thử ghi Firestore thật (với timeout tối đa 2s, không bao giờ bị treo)
    if (firebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('food_requests')
            .doc(reqId)
            .set(request.toMap())
            .timeout(const Duration(milliseconds: 2000));

        await FirebaseFirestore.instance
            .collection('activities')
            .add({
              'text': 'Đã gửi yêu cầu xin $quantity ${post.unit} ${post.title} từ ${post.giverName}',
              'createdAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(milliseconds: 1500));

        final remaining = post.remainingQuantity - quantity;
        await FirebaseFirestore.instance
            .collection('food_posts')
            .doc(post.id)
            .update({
              'remainingQuantity': remaining > 0 ? remaining : 0,
              if (remaining <= 0) 'status': 'completed',
            })
            .timeout(const Duration(milliseconds: 1500));
      } catch (e) {
        debugPrint('Lỗi hoặc timeout Firestore (đã lưu local thành công): $e');
      }
    }

    return request;
  }

  /// Stream lấy danh sách yêu cầu của tôi (Màn 58c)
  Stream<List<FoodRequest>> getMyRequestsStream() {
    if (firebaseReady) {
      return FirebaseFirestore.instance
          .collection('food_requests')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => FoodRequest.fromFirestore(d)).toList())
          .handleError((e) {
            debugPrint('Lỗi getMyRequestsStream: $e');
            return _localRequests;
          });
    }
    return Stream.value(_localRequests);
  }

  /// Lấy yêu cầu mới nhất (để hiển thị sau khi submit)
  Future<FoodRequest?> getLatestRequest() async {
    if (firebaseReady) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('food_requests')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          return FoodRequest.fromFirestore(snap.docs.first);
        }
      } catch (e) {
        debugPrint('Lỗi getLatestRequest: $e');
      }
    }
    return _localRequests.isNotEmpty ? _localRequests.first : null;
  }

  /// Hủy yêu cầu (Màn 58c)
  Future<void> cancelRequest(String requestId) async {
    final idx = _localRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final old = _localRequests[idx];
      _localRequests[idx] = FoodRequest(
        id: old.id,
        postId: old.postId,
        foodTitle: old.foodTitle,
        giverName: old.giverName,
        requestedQuantity: old.requestedQuantity,
        unit: old.unit,
        timeSlot: old.timeSlot,
        message: old.message,
        status: 'cancelled',
        pickupAddress: old.pickupAddress,
        createdAt: old.createdAt,
      );
      _localRequestsController.add(List.from(_localRequests));
    }

    if (firebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('food_requests')
            .doc(requestId)
            .update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(milliseconds: 2000));

        await FirebaseFirestore.instance.collection('activities').add({
          'text': 'Đã hủy một yêu cầu xin nhận thực phẩm',
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(milliseconds: 1500));
      } catch (e) {
        debugPrint('Lỗi Firestore cancelRequest (đã cập nhật local): $e');
      }
    }
  }
}
