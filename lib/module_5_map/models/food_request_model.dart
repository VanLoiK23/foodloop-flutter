import 'package:cloud_firestore/cloud_firestore.dart';

class FoodRequest {
  final String id;
  final String postId;
  final String foodTitle;
  final String giverName;
  final int requestedQuantity;
  final String unit;
  final String timeSlot;
  final String message;
  final String status; // 'pending' (Đang chờ duyệt), 'approved' (Đã duyệt), 'cancelled' (Đã hủy), 'completed' (Đã nhận)
  final String? pickupAddress;
  final DateTime createdAt;

  FoodRequest({
    required this.id,
    required this.postId,
    required this.foodTitle,
    required this.giverName,
    required this.requestedQuantity,
    required this.unit,
    required this.timeSlot,
    required this.message,
    this.status = 'pending',
    this.pickupAddress,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'foodTitle': foodTitle,
      'giverName': giverName,
      'requestedQuantity': requestedQuantity,
      'unit': unit,
      'timeSlot': timeSlot,
      'message': message,
      'status': status,
      'pickupAddress': pickupAddress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FoodRequest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FoodRequest.fromMap(doc.id, data);
  }

  factory FoodRequest.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedDate;
    final createdField = data['createdAt'];
    if (createdField is Timestamp) {
      parsedDate = createdField.toDate();
    } else if (createdField is String) {
      parsedDate = DateTime.tryParse(createdField) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return FoodRequest(
      id: id,
      postId: data['postId'] ?? '',
      foodTitle: data['foodTitle'] ?? '',
      giverName: data['giverName'] ?? 'Người cho',
      requestedQuantity: (data['requestedQuantity'] ?? 1) as int,
      unit: data['unit'] ?? 'phần',
      timeSlot: data['timeSlot'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      pickupAddress: data['pickupAddress'],
      createdAt: parsedDate,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'approved':
        return 'Đã duyệt';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Đã nhận';
      case 'pending':
      default:
        return 'Đang chờ duyệt';
    }
  }

  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isApproved => status == 'approved';
}
