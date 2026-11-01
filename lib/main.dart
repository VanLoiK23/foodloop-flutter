import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'module_3_4/add_product_manual.dart';
import 'app_theme.dart';
import 'module_3_4/family_list.dart';
import 'firebase_options.dart';
import 'module_3_4/import_product.dart';
import 'module_3_4/invite_family.dart';
import 'module_3_4/realtime_sync.dart';
import 'module_3_4/space_add.dart';
import 'module_3_4/space_edit.dart';
import 'module_3_4/space_selected.dart';
import 'module_3_4/storage_space_selection.dart';
import 'module_3_4/virtual_refrigerator_overview.dart';
import 'module_6_7/market_filter_results_screen.dart';
import 'module_6_7/market_filter_screen.dart';
import 'module_6_7/rescue_bank_card_screen.dart';
import 'module_6_7/rescue_booking_screen.dart';
import 'module_6_7/rescue_detail_screen.dart';
import 'module_6_7/rescue_market_screen.dart';
import 'module_6_7/rescue_order_history_screen.dart';
import 'module_6_7/rescue_payment_screen.dart';
import 'module_6_7/rescue_pickup_time_screen.dart';
import 'module_6_7/rescue_qr_payment_screen.dart';
import 'module_8_9/account_support_screen.dart';
import 'module_8_9/achievements_screen.dart';
import 'module_8_9/appeal_and_support_screen.dart';
import 'module_8_9/community_profile_screen.dart';
import 'module_8_9/decision_review_screen.dart';
import 'module_8_9/food_safety_check_screen.dart';
import 'module_8_9/honor_card_screen.dart';
import 'module_8_9/impact_trends_screen.dart';
import 'module_8_9/my_reports_screen.dart';
import 'module_8_9/received_thanks_screen.dart';
import 'module_8_9/report_appeal_screen.dart';
import 'module_8_9/settings_screen.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('ENV OK. projectId = ${dotenv.env['EXPO_PUBLIC_FIREBASE_PROJECT_ID']}');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('FIREBASE OK: ${Firebase.apps.map((a) => a.name).toList()}');
  } catch (error, stack) {
    debugPrint('FIREBASE INIT FAILED: $error\n$stack');
    // Hiện lỗi lên màn hình để biết nguyên nhân
    runApp(InitErrorApp(message: '$error'));
    return;
  }

  runApp(const MyApp());
  _signInAnonymously();
}

Future<void> _signInAnonymously() async {
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    debugPrint('AUTH OK: ${FirebaseAuth.instance.currentUser?.uid}');
  } catch (error) {
    debugPrint('FirebaseAuth Error: $error');
  }
}

class InitErrorApp extends StatelessWidget {
  const InitErrorApp({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Text(
                'Khởi tạo Firebase thất bại:\n\n$message',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodLoop App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const VirtualRefrigeratorOverview(),
        '/map': (context) => const VirtualRefrigeratorOverview(),
        '/shopping': (context) => const RescueMarketScreen(),
        '/market': (context) => const RescueMarketScreen(),
        '/rescue-market': (context) => const RescueMarketScreen(),
        '/market-filter': (context) => const MarketFilterScreen(),
        '/rescue-filter': (context) => const MarketFilterScreen(),
        '/market-filter-results': (context) => const MarketFilterResultsScreen(),
        '/rescue-detail': (context) => const RescueDetailScreen(),
        '/product-detail': (context) => const RescueDetailScreen(),
        '/rescue-booking': (context) => const RescueBookingScreen(),
        '/rescue-pickup-time': (context) => const RescuePickupTimeScreen(),
        '/rescue-payment': (context) => const RescuePaymentScreen(),
        '/payment': (context) => const RescuePaymentScreen(),
        '/rescue-bank-card': (context) => const RescueBankCardScreen(),
        '/rescue-qr-payment': (context) => const RescueQRPaymentScreen(),
        '/rescue-order-history': (context) => const RescueOrderHistoryScreen(),
        '/order-history': (context) => const RescueOrderHistoryScreen(),
        '/virtual-fridge': (context) => const VirtualRefrigeratorOverview(),
        '/family-list': (context) => const FamilyList(),
        '/space-add': (context) => const SpaceAdd(),
        '/space-edit': (context) => const SpaceEdit(),
        '/add-product': (context) => const AddProductManual(),
        '/import-product': (context) => const ImportProduct(),
        '/storage-spaces': (context) => const StorageSpaceSelection(),
        '/space-selected': (context) => const SpaceSelected(),
        '/invite-family': (context) => const InviteFamily(),
        '/realtime-sync': (context) => const RealtimeSync(),
        '/appeal-and-support': (context) => const AppealAndSupportScreen(),
        '/report-appeal': (context) => const ReportAppealScreen(),
        '/decision-review': (context) => const DecisionReviewScreen(),
        '/account-support': (context) => const AccountSupportScreen(),
        '/my-reports': (context) => const MyReportsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const SettingsScreen(),
        '/community-profile': (context) => const CommunityProfileScreen(),
        '/food-safety-check': (context) => const FoodSafetyCheckScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/impact-trends': (context) => const ImpactTrendsScreen(),
        '/received-thanks': (context) => const ReceivedThanksScreen(),
        '/honor-card': (context) => const HonorCardScreen(),
      },
    );
  }
}
