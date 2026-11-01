import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/action_card.dart';
import '../components/bottom_nav.dart';
import '../components/metric_stat_card.dart';
import '../components/screen_header.dart';
import '../components/trend_bar_chart_card.dart';
import '../components/trend_line_chart_card.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 96: "Xu hướng tác động" (module_8_9)
class ImpactTrendsScreen extends StatelessWidget {
  const ImpactTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 4, // Tab cá nhân được active theo Figma
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình
            const ScreenHeader(
              title: 'Xu hướng tác động',
              subtitle: 'Theo dõi theo tuần và tháng.',
            ),

            // 2. Nội dung cuộn lắng nghe dữ liệu từ Firestore
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamImpactTrends(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final data = snapshot.data?.data() ?? {};

                  // 1. Dữ liệu biểu đồ đường xu hướng tiết kiệm
                  final rawSavings = data['savingsTrend'] as List<dynamic>?;
                  final List<LineChartPoint> savingsPoints = rawSavings != null
                      ? rawSavings.map((item) {
                          final map = item as Map<String, dynamic>;
                          return LineChartPoint(
                            label: map['label'] ?? '',
                            value: (map['value'] as num?)?.toDouble() ?? 0.0,
                          );
                        }).toList()
                      : const [
                          LineChartPoint(label: 'Tuần 1', value: 180.0),
                          LineChartPoint(label: 'Tuần 2', value: 145.0),
                          LineChartPoint(label: 'Tuần 3', value: 160.0),
                        ];

                  // 2. Dữ liệu biểu đồ cột rác thải ngăn chặn
                  final rawWaste = data['preventedWaste'] as List<dynamic>?;
                  final List<BarChartItem> wasteItems = rawWaste != null
                      ? rawWaste.map((item) {
                          final map = item as Map<String, dynamic>;
                          return BarChartItem(
                            label: map['label'] ?? '',
                            value: (map['value'] as num?)?.toDouble() ?? 0.0,
                            displayValue: map['displayValue'] ?? '0',
                          );
                        }).toList()
                      : const [
                          BarChartItem(label: 'T2', value: 1.2, displayValue: '1,2'),
                          BarChartItem(label: 'T3', value: 2.0, displayValue: '2'),
                          BarChartItem(label: 'T4', value: 1.6, displayValue: '1,6'),
                          BarChartItem(label: 'T5', value: 2.8, displayValue: '2,8'),
                          BarChartItem(label: 'T6', value: 3.4, displayValue: '3,4'),
                          BarChartItem(label: 'T7', value: 2.6, displayValue: '2,6'),
                          BarChartItem(label: 'CN', value: 4.0, displayValue: '4'),
                        ];

                  // 3. Chỉ số tóm tắt trung bình và tuần tốt nhất
                  final String weeklyAvgValue = data['weeklyAvgValue'] ?? '6,2';
                  final String weeklyAvgPeriod = data['weeklyAvgPeriod'] ?? 'Tháng 10/2026';
                  final String bestWeekValue = data['bestWeekValue'] ?? '7,2';
                  final String bestWeekPeriod = data['bestWeekPeriod'] ?? 'Tuần 3';

                  // 4. Danh sách báo cáo tóm tắt
                  final rawReports = data['summaryReports'] as List<dynamic>?;
                  final List<Map<String, dynamic>> summaryReports = rawReports != null
                      ? rawReports.map((e) => e as Map<String, dynamic>).toList()
                      : [
                          {
                            'title': 'Tuần 4 (19/10 – 25/10)',
                            'subtitle': '6,0 kg rác ngăn chặn · 97.000 đ tiết kiệm',
                          },
                          {
                            'title': 'Tháng 10/2026',
                            'subtitle': '24,6 kg rác ngăn chặn · 428.000 đ tiết kiệm',
                          },
                        ];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TrendLineChartCard(
                          title: 'Xu hướng tiết kiệm',
                          unit: 'nghìn đồng',
                          legendLabel: 'Tiết kiệm',
                          points: savingsPoints,
                          maxY: 200.0,
                          yLevels: const [200.0, 100.0, 0.0],
                        ),

                        const SizedBox(height: AppTokens.space16),
                        TrendBarChartCard(
                          title: 'Rác thải ngăn chặn',
                          unit: 'kg',
                          legendLabel: 'Đã ngăn chặn',
                          items: wasteItems,
                          maxY: 4.0,
                          yLevels: const [4.0, 2.0, 0.0],
                        ),

                        const SizedBox(height: AppTokens.space16),

                        Row(
                          children: [
                            Expanded(
                              child: MetricStatCard(
                                title: 'Trung bình tuần',
                                value: weeklyAvgValue,
                                unit: 'kg',
                                subtitle: weeklyAvgPeriod,
                                onTap: () => _showNotice(context, 'Chi tiết trung bình tuần'),
                              ),
                            ),
                            const SizedBox(width: AppTokens.space12),
                            Expanded(
                              child: MetricStatCard(
                                title: 'Tuần tốt nhất',
                                value: bestWeekValue,
                                unit: 'kg',
                                subtitle: bestWeekPeriod,
                                onTap: () => _showNotice(context, 'Chi tiết tuần tốt nhất'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTokens.space24),

                        Text(
                          'Báo cáo tóm tắt',
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 16.0,
                            color: AppTokens.title,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space12),

                        ...summaryReports.map((report) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTokens.space12),
                            child: ActionCard(
                              title: report['title'] ?? '',
                              subtitle: report['subtitle'] ?? '',
                              onTap: () => _showNotice(
                                context,
                                'Mở chi tiết báo cáo: ${report['title']}',
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: AppTokens.space24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTokens.brand,
      ),
    );
  }
}

