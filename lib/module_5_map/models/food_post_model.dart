import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPost {
  final String id;
  final String title;
  final String category; // 'Bánh mì', 'Sữa', 'Trứng', 'Rau củ', 'Thịt cá', 'Khác'
  final String type; // 'Cho' hoặc 'Xin'
  final int totalQuantity;
  final int remainingQuantity;
  final String unit; // 'cái', 'hộp', 'quả', 'bó'
  final int daysLeft;
  final String badge;
  final int distanceMeters;
  final String pickupTime;
  final List<String> timeSlots;
  final String condition;
  final String giverName;
  final String giverAvatar;
  final double giverRating;
  final int giverShares;
  final String addressHint;
  final double xPercent; // Vị trí trên bản đồ radar (0.0 -> 1.0)
  final double yPercent; // Vị trí trên bản đồ radar (0.0 -> 1.0)
  final String iconType; // 'bread', 'milk', 'egg', 'vegetable', 'meat', 'other'
  final String status; // 'available', 'completed'
  final DateTime createdAt;

  FoodPost({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.unit,
    required this.daysLeft,
    required this.badge,
    required this.distanceMeters,
    required this.pickupTime,
    required this.timeSlots,
    required this.condition,
    required this.giverName,
    required this.giverAvatar,
    required this.giverRating,
    required this.giverShares,
    required this.addressHint,
    required this.xPercent,
    required this.yPercent,
    required this.iconType,
    this.status = 'available',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'type': type,
      'totalQuantity': totalQuantity,
      'remainingQuantity': remainingQuantity,
      'unit': unit,
      'daysLeft': daysLeft,
      'badge': badge,
      'distanceMeters': distanceMeters,
      'pickupTime': pickupTime,
      'timeSlots': timeSlots,
      'condition': condition,
      'giverName': giverName,
      'giverAvatar': giverAvatar,
      'giverRating': giverRating,
      'giverShares': giverShares,
      'addressHint': addressHint,
      'xPercent': xPercent,
      'yPercent': yPercent,
      'iconType': iconType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FoodPost.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FoodPost.fromMap(doc.id, data);
  }

  factory FoodPost.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedDate;
    final createdField = data['createdAt'];
    if (createdField is Timestamp) {
      parsedDate = createdField.toDate();
    } else if (createdField is String) {
      parsedDate = DateTime.tryParse(createdField) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return FoodPost(
      id: id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'Khác',
      type: data['type'] ?? 'Cho',
      totalQuantity: (data['totalQuantity'] ?? 1) as int,
      remainingQuantity: (data['remainingQuantity'] ?? 1) as int,
      unit: data['unit'] ?? 'phần',
      daysLeft: (data['daysLeft'] ?? 1) as int,
      badge: data['badge'] ?? 'Còn 1 ngày',
      distanceMeters: (data['distanceMeters'] ?? 250) as int,
      pickupTime: data['pickupTime'] ?? '17:00 - 19:00',
      timeSlots: List<String>.from(data['timeSlots'] ?? [
        '17:00 - 17:30',
        '17:30 - 18:00',
        '18:00 - 18:30',
        '18:30 - 19:00',
      ]),
      condition: data['condition'] ?? 'Còn tươi ngon, bảo quản tốt',
      giverName: data['giverName'] ?? 'Người dùng FoodLoop',
      giverAvatar: data['giverAvatar'] ?? 'FL',
      giverRating: (data['giverRating'] is num) ? (data['giverRating'] as num).toDouble() : 4.8,
      giverShares: (data['giverShares'] ?? 10) as int,
      addressHint: data['addressHint'] ?? 'Địa chỉ chính xác hiện sau khi được duyệt',
      xPercent: (data['xPercent'] is num) ? (data['xPercent'] as num).toDouble() : 0.5,
      yPercent: (data['yPercent'] is num) ? (data['yPercent'] as num).toDouble() : 0.5,
      iconType: data['iconType'] ?? 'other',
      status: data['status'] ?? 'available',
      createdAt: parsedDate,
    );
  }

  String get distanceText => 'Cách bạn $distanceMeters m';
  String get quantityTitle => '$title · $remainingQuantity $unit';
}
