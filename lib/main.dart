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
        // '/': (context) => const HomeDashboard(),
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
      },
    );
  }
}