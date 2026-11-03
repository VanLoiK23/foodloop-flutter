import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Dịch vụ nạp dữ liệu mẫu hoàn chỉnh vào Firebase Firestore cho toàn bộ hệ thống FoodLoop
class FoodLoopSeederService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Tự động kiểm tra và nạp dữ liệu nếu Firestore đang trống
  static Future<void> seedIfEmpty() async {
    try {
      final snap = await _firestore.collection('rescue_baskets').limit(1).get();
      if (snap.docs.isEmpty) {
        debugPrint('Firestore trống, tự động nạp dữ liệu mẫu ban đầu...');
        await seedAll();
      }
    } catch (e) {
      debugPrint('Kiểm tra Firestore seed: $e');
    }
  }

  /// Nạp toàn bộ dữ liệu mẫu lên Firestore
  static Future<Map<String, dynamic>> seedAll({bool overwrite = true}) async {
    final uid = _auth.currentUser?.uid ?? 'default_user';
    debugPrint('Bắt đầu nạp dữ liệu Firebase cho user: $uid...');

    int totalDocsCreated = 0;

    try {
      // 1. SEED USERS (Hồ sơ người dùng & tài khoản)
      final userBatch = _firestore.batch();
      final userData = {
        'name': 'Minh Anh',
        'fullName': 'Nguyễn Minh Anh',
        'displayName': 'Minh Anh',
        'email': 'minhanh.foodloop@gmail.com',
        'phone': '0912345678',
        'avatarUrl':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
        'householdType': 'Gia đình',
        'memberCount': 4,
        'memberSince': '10/2026',
        'trustScore': 86,
        'trustScoreMax': 100,
        'trustInfoTitle': 'Điểm tin cậy được tính thế nào?',
        'trustInfoDescription':
            'Điểm tin cậy dựa trên số thực phẩm an toàn bạn đã chia sẻ, lời cảm ơn nhận được và không vi phạm quy tắc an toàn thực phẩm.',
        'badgesCount': 6,
        'sharedMeals': 18,
        'co2SavedKg': 61.5,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      userBatch.set(_firestore.collection('users').doc('default_user'), userData, SetOptions(merge: true));
      if (uid != 'default_user') {
        userBatch.set(_firestore.collection('users').doc(uid), userData, SetOptions(merge: true));
      }
      totalDocsCreated += 2;

      // 2. SEED NOTIFICATIONS (Thông báo cá nhân trong users/{uid}/notify)
      final notifications = [
        {
          'id': 'notification_1',
          'section': 'Hôm nay',
          'title': 'Sữa tươi TH True Milk 1L',
          'status': 'Cận date - còn 1 ngày',
          'time': '15 phút trước',
          'type': 'warning',
          'imageUrl':
              'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=200&q=80',
          'order': 1,
        },
        {
          'id': 'notification_2',
          'section': 'Hôm nay',
          'title': 'Bạn Thu vừa cảm ơn bạn!',
          'status': 'Đã tặng nhãn dán: Thật tử tế!',
          'time': '1 giờ trước',
          'type': 'success',
          'imageUrl': '',
          'order': 2,
        },
        {
          'id': 'notification_3',
          'section': 'Tuần này',
          'title': 'Giỏ bánh ngọt - Nắng Mai',
          'status': 'Khung giờ nhận: 20:00 - 21:00 hôm nay',
          'time': '3 giờ trước',
          'type': 'info',
          'imageUrl':
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=200&q=80',
          'order': 3,
        },
        {
          'id': 'notification_4',
          'section': 'Tuần này',
          'title': 'Rau muống hữu cơ',
          'status': 'Đã quá hạn sử dụng 1 ngày',
          'time': 'Hôm qua',
          'type': 'expired',
          'imageUrl':
              'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=200&q=80',
          'order': 4,
        },
      ];

      for (var n in notifications) {
        final docRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('notify')
            .doc(n['id'] as String);
        userBatch.set(docRef, {
          ...n,
          'createdAt': FieldValue.serverTimestamp(),
        });
        totalDocsCreated++;
      }
      await userBatch.commit();

      // 3. SEED SETTINGS (Cài đặt)
      final settingsBatch = _firestore.batch();
      final settingsData = {
        'profileName': 'Minh Anh',
        'profileSubtitle': 'Hồ sơ cộng đồng & Điểm tin cậy: 86',
        'honorCards': '3 thẻ vinh danh',
        'badgeSubtitle': '6 huy hiệu đã mở khóa',
        'remindExpiry': true,
        'recipeSuggestions': true,
        'receiveRequests': true,
        'profileVisibility': 'Ai có thể xem hồ sơ của bạn',
        'locationSharing': 'Chỉ hiển thị khu vực gần đúng',
        'locationPermission': true,
        'cameraPermission': true,
        'pushNotificationPermission': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      settingsBatch.set(_firestore.collection('settings').doc('default_user'), settingsData, SetOptions(merge: true));
      if (uid != 'default_user') {
        settingsBatch.set(_firestore.collection('settings').doc(uid), settingsData, SetOptions(merge: true));
      }
      await settingsBatch.commit();
      totalDocsCreated += 2;

      // 4. SEED SPACES (Không gian lưu trữ - Tủ lạnh)
      final spacesBatch = _firestore.batch();
      final spaces = [
        {
          'id': 'space_ngan_mat',
          'name': 'Ngăn mát',
          'template': 'Tủ lạnh',
          'note': 'Rau củ, trứng sữa và thực phẩm dùng trong tuần',
          'remindDays': 3,
          'itemCount': 6,
          'status': 'ĐANG SỬ DỤNG',
        },
        {
          'id': 'space_ngan_dong',
          'name': 'Ngăn đông',
          'template': 'Tủ đông',
          'note': 'Thịt heo, bò, hải sản và đồ đông lạnh',
          'remindDays': 7,
          'itemCount': 4,
          'status': 'ĐANG SỬ DỤNG',
        },
        {
          'id': 'space_tu_kho',
          'name': 'Tủ khô',
          'template': 'Tủ khô',
          'note': 'Mì gói, ngũ cốc, đồ hộp và gia vị khô',
          'remindDays': 14,
          'itemCount': 5,
          'status': 'ĐANG SỬ DỤNG',
        },
        {
          'id': 'space_ke_bep',
          'name': 'Kệ bếp',
          'template': 'Kệ bếp',
          'note': 'Hành tây, tỏi, khoai tây và trái cây',
          'remindDays': 5,
          'itemCount': 3,
          'status': 'ĐANG SỬ DỤNG',
        },
      ];

      for (var s in spaces) {
        final docRef = _firestore.collection('spaces').doc(s['id'] as String);
        spacesBatch.set(docRef, {
          ...s,
          'createdAt': FieldValue.serverTimestamp(),
        });
        totalDocsCreated++;
      }
      await spacesBatch.commit();

      // 5. SEED PRODUCTS & FRIDGE ITEMS
      final productsBatch = _firestore.batch();
      final products = [
        {
          'name': 'Sữa tươi TH True Milk 1L',
          'category': 'Sữa & Trứng',
          'quantity': 2,
          'unit': 'hộp',
          'space': 'Ngăn mát',
          'expiry': '04/11/2026',
          'purchased': '01/11/2026',
          'noExpiry': false,
          'daysLeft': 2,
          'badge': 'Còn 2 ngày',
          'imageUrl':
              'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
          'isShared': true,
        },
        {
          'name': 'Rau muống xanh',
          'category': 'Rau củ',
          'quantity': 1,
          'unit': 'bó',
          'space': 'Ngăn mát',
          'expiry': '03/11/2026',
          'purchased': '31/10/2026',
          'noExpiry': false,
          'daysLeft': 1,
          'badge': 'Còn 1 ngày',
          'imageUrl':
              'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=80',
          'isShared': true,
        },
        {
          'name': 'Trứng gà Ba Huân',
          'category': 'Sữa & Trứng',
          'quantity': 10,
          'unit': 'quả',
          'space': 'Ngăn mát',
          'expiry': '12/11/2026',
          'purchased': '28/10/2026',
          'noExpiry': false,
          'daysLeft': 10,
          'badge': 'Còn 10 ngày',
          'imageUrl':
              'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=400&q=80',
          'isShared': false,
        },
        {
          'name': 'Thịt ba chỉ bò Úc',
          'category': 'Thịt & Hải sản',
          'quantity': 500,
          'unit': 'g',
          'space': 'Ngăn đông',
          'expiry': '25/11/2026',
          'purchased': '25/10/2026',
          'noExpiry': false,
          'daysLeft': 23,
          'badge': 'Còn 23 ngày',
          'imageUrl':
              'https://images.unsplash.com/photo-1603048588665-791ca8aea617?auto=format&fit=crop&w=400&q=80',
          'isShared': false,
        },
        {
          'name': 'Cà chua bi Đà Lạt',
          'category': 'Rau củ',
          'quantity': 500,
          'unit': 'g',
          'space': 'Kệ bếp',
          'expiry': '05/11/2026',
          'purchased': '01/11/2026',
          'noExpiry': false,
          'daysLeft': 3,
          'badge': 'Còn 3 ngày',
          'imageUrl':
              'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=400&q=80',
          'isShared': true,
        },
        {
          'name': 'Sữa chua không đường Vinamilk',
          'category': 'Sữa & Trứng',
          'quantity': 4,
          'unit': 'hộp',
          'space': 'Ngăn mát',
          'expiry': '06/11/2026',
          'purchased': '29/10/2026',
          'noExpiry': false,
          'daysLeft': 4,
          'badge': 'Còn 4 ngày',
          'imageUrl':
              'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=400&q=80',
          'isShared': false,
        },
      ];

      for (var p in products) {
        productsBatch.set(_firestore.collection('products').doc(), {
          ...p,
          'createdAt': FieldValue.serverTimestamp(),
        });
        // Đồng thời thêm vào fridge_items cho Home Dashboard
        productsBatch.set(_firestore.collection('fridge_items').doc(), {
          'title': p['name'],
          'name': p['name'],
          'category': p['category'],
          'space': p['space'],
          'quantity': p['quantity'],
          'unit': p['unit'],
          'remainingDays': p['daysLeft'],
          'isExpiring': (p['daysLeft'] as int) <= 3,
          'imageUrl': p['imageUrl'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        totalDocsCreated += 2;
      }

      // Hai document sản phẩm đặc biệt cho Module 8 & 9
      productsBatch.set(_firestore.collection('products').doc('target_report_product'), {
        'productName': 'Sữa tươi TH True Milk 1L',
        'productSubtitle': '2 hộp · Ngăn mát · HSD: 2 ngày',
        'productImage':
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
        'status': 'Đang xem xét',
        'reason': 'Nghi vấn cận date quá hạn sử dụng',
        'detail': 'Người nhận thông báo sản phẩm có vị chua nhẹ.',
      });

      productsBatch.set(_firestore.collection('products').doc('food_safety_check_target'), {
        'productName': 'Sữa tươi TH True Milk 1L',
        'productSubtitle': '2 hộp · Ngăn mát · HSD: 2 ngày',
        'productImage':
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
        'expiryText': 'Còn 2 ngày',
        'ruleTitle': 'Quy tắc an toàn thực phẩm FoodLoop',
        'ruleMessage':
            'Chỉ chia sẻ thực phẩm còn hạn, bao bì nguyên vẹn và đúng điều kiện bảo quản nhiệt độ.',
        'checklist': [
          'Thực phẩm còn hạn sử dụng và đúng với thông tin đã nhập',
          'Bao bì nguyên vẹn, không phồng, rách hay rò rỉ',
          'Đã bảo quản đúng cách (ngăn mát hoặc ngăn đông nếu cần)',
        ],
        'isSafetyVerified': true,
      });
      totalDocsCreated += 2;
      await productsBatch.commit();

      // 6. SEED MEMBERS (Kho gia đình)
      final membersBatch = _firestore.batch();
      final members = [
        {
          'name': 'Nguyễn Minh Anh',
          'email': 'minhanh.foodloop@gmail.com',
          'role': 'Chủ sở hữu',
          'avatar':
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        },
        {
          'name': 'Huỳnh Văn Lợi',
          'email': 'loihv@gmail.com',
          'role': 'Đồng quản trị',
          'avatar':
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
        },
        {
          'name': 'Trần Thu Hà',
          'email': 'thuha.tran@gmail.com',
          'role': 'Thành viên',
          'avatar':
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
        },
      ];

      for (var m in members) {
        membersBatch.set(_firestore.collection('members').doc(), {
          ...m,
          'joinedAt': FieldValue.serverTimestamp(),
        });
        totalDocsCreated++;
      }
      await membersBatch.commit();

      // 7. SEED RESCUE BASKETS (Chợ giải cứu - Module 6 & 7)
      final basketsBatch = _firestore.batch();
      final baskets = [
        {
          'id': 'basket_1',
          'title': 'Giỏ rau củ tươi cuối ngày',
          'store': 'Rau Sạch Xanh',
          'distance': '350 m',
          'originalPrice': 80000,
          'discountedPrice': 45000,
          'savings': 'Tiết kiệm 35.000 đ',
          'remainingTime': 'Còn 3 giờ',
          'pickupTime': '18:00–19:30',
          'category': 'Rau củ',
          'imageUrl':
              'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=80',
          'expiryHint': 'Dùng trong 2-3 ngày',
          'description':
              'Giỏ rau củ hữu cơ tươi ngon cuối ngày từ nông trại Đà Lạt: xà lách, cà rốt, dưa chuột và cà chua bi. Chất lượng tươi đạt chuẩn, ưu tiên chống lãng phí.',
        },
        {
          'id': 'basket_2',
          'title': 'Giỏ bánh ngọt & bánh nướng',
          'store': 'Tiệm Bánh Nắng Mai',
          'distance': '600 m',
          'originalPrice': 90000,
          'discountedPrice': 60000,
          'savings': 'Tiết kiệm 30.000 đ',
          'remainingTime': 'Còn 2 giờ',
          'pickupTime': '20:00–21:00',
          'category': 'Bánh ngọt',
          'imageUrl':
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&q=80',
          'expiryHint': 'Dùng trong ngày mai',
          'description':
              'Combo 4 loại bánh tươi ra lò trong ngày: Croissant bơ Pháp, bánh cuộn nho khô, bánh mì ngũ cốc và muffin sô-cô-la thơm ngon.',
        },
        {
          'id': 'basket_3',
          'title': 'Giỏ đồ chay dinh dưỡng',
          'store': 'Quán Cơm Chay An Lạc',
          'distance': '900 m',
          'originalPrice': 70000,
          'discountedPrice': 44000,
          'savings': 'Tiết kiệm 26.000 đ',
          'remainingTime': 'Còn 1 giờ',
          'pickupTime': '19:00–20:30',
          'category': 'Đồ chay',
          'imageUrl':
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=400&q=80',
          'expiryHint': 'Dùng ngay trong tối nay',
          'description':
              'Khẩu phần chay thanh đạm đầy đủ chất: nấm kho tiêu xanh, đậu hũ sốt cà chua, canh rong biển hạt sen và cơm gạo lứt.',
        },
        {
          'id': 'basket_4',
          'title': 'Giỏ cơm trưa & đồ nấu sẵn',
          'store': 'Bếp Mẹ Nấu - Cơm Văn Phòng',
          'distance': '1.2 km',
          'originalPrice': 65000,
          'discountedPrice': 39000,
          'savings': 'Tiết kiệm 26.000 đ',
          'remainingTime': 'Còn 4 giờ',
          'pickupTime': '17:30–19:00',
          'category': 'Đồ nấu sẵn',
          'imageUrl':
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
          'expiryHint': 'Hâm nóng dùng trước 21:00',
          'description':
              'Suất cơm nóng hổi chuẩn vị gia đình còn dư buổi trưa bảo quản nóng sạch: gà kho gừng, rau xào tỏi và canh rau ngót thịt bằm.',
        },
        {
          'id': 'basket_5',
          'title': 'Giỏ củ quả & trái cây Đà Lạt',
          'store': 'Nông Sản Sạch Đà Lạt',
          'distance': '800 m',
          'originalPrice': 95000,
          'discountedPrice': 55000,
          'savings': 'Tiết kiệm 40.000 đ',
          'remainingTime': 'Còn 2.5 giờ',
          'pickupTime': '18:30–20:00',
          'category': 'Rau củ',
          'imageUrl':
              'https://images.unsplash.com/photo-1597362925123-77861d3fbac7?auto=format&fit=crop&w=400&q=80',
          'expiryHint': 'Dùng trong 3 ngày',
          'description':
              'Khoai lang mật, bí đỏ mini, bơ 034 và chuối sứ chín tự nhiên, không chất bảo quản.',
        },
        {
          'id': 'basket_6',
          'title': 'Giỏ bánh mì men tự nhiên',
          'store': 'Tiệm Bánh Paris Baguette',
          'distance': '1.5 km',
          'originalPrice': 85000,
          'discountedPrice': 48000,
          'savings': 'Tiết kiệm 37.000 đ',
          'remainingTime': 'Còn 1.5 giờ',
          'pickupTime': '19:30–21:00',
          'category': 'Bánh ngọt',
          'imageUrl':
              'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=400&q=80',
          'expiryHint': 'Dùng trong 2 ngày',
          'description':
              'Bánh mì Sourdough lên men tự nhiên giòn vỏ mềm ruột, bánh mì hoa cúc và bánh gối lúa mạch.',
        },
      ];

      for (var b in baskets) {
        final docRef = _firestore.collection('rescue_baskets').doc(b['id'] as String);
        basketsBatch.set(docRef, {
          ...b,
          'createdAt': FieldValue.serverTimestamp(),
        });
        totalDocsCreated++;
      }

      // Đơn hàng giải cứu mẫu
      final orders = [
        {
          'title': 'Giỏ rau củ cuối ngày',
          'store': 'Rau Sạch Xanh',
          'quantity': 1,
          'totalPrice': 45000,
          'pickupTime': '18:00–19:30 hôm nay',
          'customerName': 'Minh Anh',
          'customerPhone': '0912345678',
          'status': 'Chờ nhận',
          'paymentMethod': 'Trả tại cửa hàng',
        },
        {
          'title': 'Giỏ bánh ngọt',
          'store': 'Tiệm Bánh Nắng Mai',
          'quantity': 1,
          'totalPrice': 60000,
          'pickupTime': '20:00–21:00 ngày 22/10',
          'customerName': 'Minh Anh',
          'customerPhone': '0912345678',
          'status': 'Hoàn tất',
          'paymentMethod': 'Ví MoMo',
        },
      ];

      for (var o in orders) {
        basketsBatch.set(_firestore.collection('rescue_orders').doc(), {
          ...o,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': uid,
        });
        totalDocsCreated++;
      }
      await basketsBatch.commit();

      // 8. SEED FOOD POSTS (Bản đồ Radar Module 5)
      final mapBatch = _firestore.batch();
      final posts = [
        {
          'id': 'post_1',
          'title': 'Bánh mì hoa cúc Harrys 500g',
          'category': 'Bánh ngọt',
          'type': 'Cho',
          'totalQuantity': 2,
          'remainingQuantity': 2,
          'unit': 'gói',
          'daysLeft': 2,
          'badge': 'Còn 2 ngày',
          'distanceMeters': 350,
          'pickupTime': '18:00 - 20:00',
          'timeSlots': ['18:00 - 19:00', '19:00 - 20:00'],
          'condition': 'Nguyên tem, chưa khui',
          'giverName': 'Minh Anh',
          'giverAvatar':
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
          'giverRating': 4.9,
          'giverShares': 18,
          'addressHint': 'Chung cư Sunrise City, Quận 7',
          'xPercent': 0.45,
          'yPercent': 0.35,
          'iconType': 'bread',
          'status': 'available',
        },
        {
          'id': 'post_2',
          'title': 'Sữa chua uống TH True Yoghurt',
          'category': 'Đồ uống',
          'type': 'Cho',
          'totalQuantity': 4,
          'remainingQuantity': 3,
          'unit': 'hộp',
          'daysLeft': 3,
          'badge': 'Còn 3 ngày',
          'distanceMeters': 600,
          'pickupTime': '17:30 - 19:30',
          'timeSlots': ['17:30 - 18:30', '18:30 - 19:30'],
          'condition': 'Bảo quản ngăn mát liên tục',
          'giverName': 'Cô Mai',
          'giverAvatar':
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
          'giverRating': 5.0,
          'giverShares': 24,
          'addressHint': 'Hẻm 48 Điện Biên Phủ, Bình Thạnh',
          'xPercent': 0.65,
          'yPercent': 0.55,
          'iconType': 'milk',
          'status': 'available',
        },
        {
          'id': 'post_3',
          'title': 'Cà chua bi & xà lách sạch',
          'category': 'Rau củ',
          'type': 'Cho',
          'totalQuantity': 1,
          'remainingQuantity': 1,
          'unit': 'kg',
          'daysLeft': 2,
          'badge': 'Còn 2 ngày',
          'distanceMeters': 850,
          'pickupTime': '19:00 - 21:00',
          'timeSlots': ['19:00 - 20:00', '20:00 - 21:00'],
          'condition': 'Mới thu hoạch vườn nhà',
          'giverName': 'Anh Tuấn',
          'giverAvatar':
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
          'giverRating': 4.8,
          'giverShares': 12,
          'addressHint': 'Phường Thảo Điền, TP. Thủ Đức',
          'xPercent': 0.25,
          'yPercent': 0.70,
          'iconType': 'vegetable',
          'status': 'available',
        },
        {
          'id': 'post_4',
          'title': 'Cần xin 2 quả trứng gà làm bánh',
          'category': 'Sữa & Trứng',
          'type': 'Xin',
          'totalQuantity': 2,
          'remainingQuantity': 2,
          'unit': 'quả',
          'daysLeft': 1,
          'badge': 'Cần gấp',
          'distanceMeters': 400,
          'pickupTime': 'Nhận ngay trong tối nay',
          'timeSlots': ['Ngay bây giờ', 'Trước 21:00'],
          'condition': 'Trứng còn tươi',
          'giverName': 'Huyền My',
          'giverAvatar':
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
          'giverRating': 4.9,
          'giverShares': 7,
          'addressHint': 'Khu đô thị Sala, Quận 2',
          'xPercent': 0.50,
          'yPercent': 0.80,
          'iconType': 'egg',
          'status': 'available',
        },
      ];

      for (var p in posts) {
        final docRef = _firestore.collection('food_posts').doc(p['id'] as String);
        mapBatch.set(docRef, {
          ...p,
          'createdAt': FieldValue.serverTimestamp(),
        });
        totalDocsCreated++;
      }
      await mapBatch.commit();

      // 9. SEED ACTIVITIES, IMPACT TRENDS, HONOR CARD & ACHIEVEMENTS (Module 8 & 9)
      final actBatch = _firestore.batch();

      actBatch.set(_firestore.collection('activities').doc('impact_trends'), {
        'savingsTrend': [
          {'label': 'Tuần 1', 'value': 180.0},
          {'label': 'Tuần 2', 'value': 145.0},
          {'label': 'Tuần 3', 'value': 160.0},
          {'label': 'Tuần 4', 'value': 220.0},
        ],
        'preventedWaste': [
          {'label': 'Tháng 8', 'value': 12.5, 'displayValue': '12.5 kg'},
          {'label': 'Tháng 9', 'value': 18.2, 'displayValue': '18.2 kg'},
          {'label': 'Tháng 10', 'value': 24.6, 'displayValue': '24.6 kg'},
        ],
        'consumedSummary': '18 món',
        'consumedItems': 18,
        'wastedSummary': '1.2 kg',
        'wastedWeight': 1.2,
      });

      actBatch.set(_firestore.collection('activities').doc('received_thanks'), {
        'thanksCount': 12,
        'reputationScore': 86,
        'stickers': [
          'Cảm ơn bạn!',
          'Thật tử tế!',
          'Hàng xóm tuyệt vời',
          'Vì môi trường xanh',
        ],
        'recentThanks': [
          {
            'title': 'Anh Hùng · Cảm ơn bạn!',
            'subtitle': '2 hộp sữa tươi TH True Milk · 27/10/2026',
          },
          {
            'title': 'Bạn Thu · Thật tử tế!',
            'subtitle': '1 bó rau muống xanh hữu cơ · 24/10/2026',
          },
          {
            'title': 'Cô Mai · Hàng xóm tuyệt vời',
            'subtitle': '500g cà chua bi Đà Lạt · 20/10/2026',
          },
          {
            'title': 'Anh Tuấn · Nhờ bạn mà không lãng phí',
            'subtitle': '1 ổ bánh mì ngũ cốc nguyên cám · 15/10/2026',
          },
        ],
        'reputationHistory': [
          {
            'label': 'Chia sẻ thực phẩm an toàn',
            'points': '+10',
            'time': '27/10/2026',
          },
          {
            'label': 'Nhận nhãn dán: Thật tử tế!',
            'points': '+5',
            'time': '24/10/2026',
          },
          {
            'label': 'Cứu thành công giỏ cận date',
            'points': '+15',
            'time': '20/10/2026',
          },
        ],
      });

      actBatch.set(_firestore.collection('activities').doc('honor_card'), {
        'userName': 'Minh Anh',
        'monthYear': 'Tháng 10/2026',
        'preventedWaste': '24,6',
        'reducedCo2': '61,5',
        'savedMoney': '428.000',
        'foodSaved': '24.6 kg',
      });

      // Badges
      final badges = [
        {
          'type': 'achievement',
          'title': 'Tác động mạnh mẽ',
          'description': 'Gây ảnh hưởng tích cực đến cộng đồng chống lãng phí!',
          'isUnlocked': true,
          'progress': 1.0,
          'progressText': '1/1 lần',
          'icon': 'nature',
        },
        {
          'type': 'achievement',
          'title': 'Chiến thần giải cứu',
          'description': 'Giải cứu thành công hơn 10 giỏ thực phẩm cận date.',
          'isUnlocked': true,
          'progress': 1.0,
          'progressText': '12/10 giỏ',
          'icon': 'shopping_basket',
        },
        {
          'type': 'achievement',
          'title': 'Bậc thầy bảo quản',
          'description':
              'Quản lý 4 không gian tủ lạnh không có đồ quá hạn trong 30 ngày.',
          'isUnlocked': true,
          'progress': 1.0,
          'progressText': '30/30 ngày',
          'icon': 'kitchen',
        },
        {
          'type': 'achievement',
          'title': 'Hàng xóm thân thiện',
          'description': 'Nhận được 10 lời cảm ơn từ người nhận thực phẩm.',
          'isUnlocked': true,
          'progress': 1.0,
          'progressText': '12/10 lời cảm ơn',
          'icon': 'favorite',
        },
      ];

      for (var b in badges) {
        actBatch.set(_firestore.collection('activities').doc(), {
          ...b,
          'createdAt': FieldValue.serverTimestamp(),
        });
        totalDocsCreated++;
      }
      totalDocsCreated += 3;
      await actBatch.commit();

      // 10. SEED REPORTS & APPEALS (Báo cáo & Kháng nghị Module 8 & 9)
      final reportsBatch = _firestore.batch();
      reportsBatch.set(_firestore.collection('reports').doc('BC-1001'), {
        'code': 'BC-1001',
        'productName': 'Sữa tươi TH True Milk 1L',
        'productSubtitle': '2 hộp · Ngăn mát · HSD: 2 ngày',
        'productImage':
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
        'status': 'Đang xử lý',
        'postStatus': 'Đang chờ duyệt',
        'isResolved': false,
        'reason': 'Nghi vấn cận date quá hạn an toàn',
        'detail': 'Người nhận báo sản phẩm nắp có dấu hiệu mở trước đó và vị hơi chua.',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
      });

      reportsBatch.set(_firestore.collection('reports').doc('BC-1000'), {
        'code': 'BC-1000',
        'productName': 'Bánh bao nhân thịt',
        'productSubtitle': '4 cái · Tủ đông · HSD: 5 ngày',
        'productImage':
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
        'status': 'Đã giải quyết',
        'postStatus': 'Đã gỡ bài',
        'isResolved': true,
        'reason': 'Bao bì bị rách',
        'detail': 'Bao bì bị rách trong quá trình vận chuyển, chủ bài đăng đã tự nguyện gỡ bỏ.',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
      });

      reportsBatch.set(_firestore.collection('appeals').doc('flagged_notice'), {
        'headerSubtitle': 'Nếu cho rằng quyết định là nhầm lẫn, bạn có thể gửi kháng nghị.',
        'flagTitle': 'Bài đăng bị gắn cờ',
        'flagReason': 'Vi phạm quy chuẩn an toàn thực phẩm. Đã tạm ẩn khỏi cộng đồng.',
        'productName': 'Sữa tươi TH True Milk 1L',
        'productSubtitle': '2 hộp · Ngăn mát · HSD: 2 ngày',
        'productImage':
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
        'decisionReviewTitle': 'Bạn muốn xem xét lại?',
      });

      reportsBatch.set(_firestore.collection('appeals').doc('account_support_info'), {
        'headerTitle': 'Liên hệ hỗ trợ tài khoản',
        'headerSubtitle': 'Chúng tôi sẽ phản hồi qua email trong vòng 24 giờ làm việc.',
        'introTitle': 'Bạn gặp vấn đề về tài khoản?',
        'introSubtitle': 'Vui lòng mô tả chi tiết vấn đề để đội ngũ hỗ trợ giải quyết nhanh nhất.',
      });

      totalDocsCreated += 4;
      await reportsBatch.commit();

      debugPrint('Đã nạp thành công $totalDocsCreated document lên Firestore!');
      return {
        'success': true,
        'totalDocs': totalDocsCreated,
        'userId': uid,
      };
    } catch (e, stack) {
      debugPrint('Lỗi nạp dữ liệu Firebase: $e\n$stack');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
