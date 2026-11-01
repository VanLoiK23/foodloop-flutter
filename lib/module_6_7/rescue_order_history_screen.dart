import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 70: "Lịch sử đơn hàng" (Module 6 & 7)
class RescueOrderHistoryScreen extends StatefulWidget {
  const RescueOrderHistoryScreen({super.key});

  @override
  State<RescueOrderHistoryScreen> createState() =>
      _RescueOrderHistoryScreenState();
}

class _RescueOrderHistoryScreenState extends State<RescueOrderHistoryScreen> {
  String _selectedFilter = 'Tất cả';

  final List<String> _filters = const [
    'Tất cả',
    'Đang chờ',
    'Hoàn tất',
    'Hủy / Hoàn tiền',
  ];

  static const List<Map<String, dynamic>> _defaultOrders = [
    {
      'title': 'Giỏ rau củ cuối ngày',
      'status': 'Chờ nhận',
      'statusCode': 'pending',
      'price': '45.000 đ',
      'date': '27/10',
    },
    {
      'title': 'Giỏ bánh ngọt',
      'status': 'Hoàn tất',
      'statusCode': 'completed',
      'price': '60.000 đ',
      'date': '22/10',
    },
    {
      'title': 'Giỏ đồ chay',
      'status': 'Hoàn tất',
      'statusCode': 'completed',
      'price': '44.000 đ',
      'date': '15/10',
    },
    {
      'title': 'Giỏ đồ nấu sẵn',
      'status': 'Hoàn tất',
      'statusCode': 'completed',
      'price': '50.000 đ',
      'date': '08/10',
    },
    {
      'title': 'Giỏ đồ chay',
      'status': 'Đã hủy',
      'statusCode': 'cancelled',
      'price': '44.000 đ',
      'date': '05/10',
    },
    {
      'title': 'Giỏ rau củ',
      'status': 'Đang hoàn tiền',
      'statusCode': 'refunding',
      'price': '45.000 đ',
      'date': '02/10',
      'note': 'Cửa hàng hết đồ. Dự kiến hoàn trong 1–3 ngày làm việc.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 3,
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Lịch sử đơn hàng',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tháng 10/2026',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _filters.map((f) {
                        final isSelected = f == _selectedFilter;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedFilter = f);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 7.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppTokens.brand
                                    : AppTokens.border.withValues(alpha: 0.8),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: AppTokens.brand,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  f,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: isSelected
                                        ? AppTokens.brand
                                        : AppTokens.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Đã đặt',
                            mainText: '4',
                            suffixText: ' giỏ',
                            subtitle: 'Tháng 10/2026',
                          ),
                        ),
                        const SizedBox(width: AppTokens.space12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Tiết kiệm',
                            mainText: '116.000',
                            suffixText: ' đ',
                            subtitle: 'Tháng 10/2026',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space20),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FoodLoopFirestoreService.streamRescueOrders(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final List<Map<String, dynamic>> allOrders =
                            docs.isNotEmpty
                                ? docs.map((d) {
                                    final data = d.data();
                                    return {
                                      'title': data['title'] ?? 'Giỏ rau củ',
                                      'status': data['status'] ?? 'Chờ nhận',
                                      'statusCode': 'pending',
                                      'price': '${data['totalPrice'] ?? 45000} đ',
                                      'date': 'Hôm nay',
                                    };
                                  }).toList()
                                : _defaultOrders;

                        final filteredOrders = allOrders.where((order) {
                          final status = order['status'] as String? ?? '';
                          if (_selectedFilter == 'Tất cả') return true;
                          if (_selectedFilter == 'Đang chờ') {
                            return status.contains('Chờ') ||
                                status.contains('chờ') ||
                                status.contains('Giữ chỗ');
                          }
                          if (_selectedFilter == 'Hoàn tất') {
                            return status.contains('Hoàn tất') ||
                                status.contains('hoàn tất') ||
                                status.contains('thành công');
                          }
                          if (_selectedFilter == 'Hủy / Hoàn tiền') {
                            return status.contains('hủy') ||
                                status.contains('Hủy') ||
                                status.contains('hoàn tiền') ||
                                status.contains('Hoàn tiền');
                          }
                          return true;
                        }).toList();

                        if (filteredOrders.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppTokens.space24),
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTokens.border.withValues(alpha: 0.8),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Không có đơn hàng nào trong mục này.',
                                style: TextStyle(
                                  color: AppTokens.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: filteredOrders.map((order) {
                            return _buildOrderCard(order);
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: AppTokens.space24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String mainText,
    required String suffixText,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTokens.border.withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.0,
              color: AppTokens.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainText,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brand,
                ),
              ),
              Text(
                suffixText,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.0,
              color: AppTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String title = order['title'] ?? '';
    final String status = order['status'] ?? '';
    final String price = order['price'] ?? '';
    final String date = order['date'] ?? '';
    final String? note = order['note'];

    Color statusBg = const Color(0xFFEFF6FF);
    Color statusColor = const Color(0xFF1E40AF);
    Widget statusIcon = const Icon(
      Icons.sync_rounded,
      size: 16,
      color: Color(0xFF2563EB),
    );

    if (status == 'Hoàn tất') {
      statusBg = const Color(0xFFE8F5E9);
      statusColor = AppTokens.brand;
      statusIcon = const Icon(
        Icons.check_circle_outline_rounded,
        size: 16,
        color: AppTokens.brand,
      );
    } else if (status == 'Đã hủy') {
      statusBg = const Color(0xFFFEF2F2);
      statusColor = const Color(0xFFB91C1C);
      statusIcon = const Icon(
        Icons.error_outline_rounded,
        size: 16,
        color: Color(0xFFDC2626),
      );
    } else if (status == 'Đang hoàn tiền' || status == 'Chờ nhận') {
      statusBg = const Color(0xFFEFF6FF);
      statusColor = const Color(0xFF1E40AF);
      statusIcon = const Icon(
        Icons.sync_rounded,
        size: 16,
        color: Color(0xFF2563EB),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.space12),
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTokens.border.withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: AppTokens.brand,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                statusIcon,
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$price · $date',
            style: const TextStyle(
              fontSize: 13.0,
              color: AppTokens.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              note,
              style: const TextStyle(
                fontSize: 12.0,
                color: AppTokens.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

