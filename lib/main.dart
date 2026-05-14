import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:codex_firebase/providers.dart';
import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/views/Splash_Screen.dart';
import 'package:codex_firebase/views/no_internet_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CodexApp());
}

class CodexApp extends StatelessWidget {
  const CodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...AppProviders.providers,
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CODEX',
        theme: ThemeData(
          primaryColor: const Color(0xFF429EBD),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Tajawal',
          useMaterial3: true,
        ),
        home: const ConnectivityWrapper(),
      ),
    );
  }
}

// واجهة التحقق من الاتصال بالإنترنت قبل عرض التطبيق
class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({super.key});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  @override
  void initState() {
    super.initState();
    // ✅ طلب الصلاحيات عند بدء التطبيق
    requestPermissions();
  }

  // ✅ دالة طلب الصلاحيات
  Future<void> requestPermissions() async {
    try {
      // طلب صلاحيات التخزين والكاميرا والصور
      final statuses = await [
        Permission.storage,
        Permission.camera,
        Permission.photos,
      ].request();

      // طباعة حالة الصلاحيات للتصحيح
      print('✅ Permission storage: ${statuses[Permission.storage]}');
      print('✅ Permission camera: ${statuses[Permission.camera]}');
      print('✅ Permission photos: ${statuses[Permission.photos]}');

      // إذا كانت الصلاحيات ممنوعة، يمكن عرض رسالة للمستخدم
      if (statuses[Permission.camera]!.isDenied) {
        print('⚠️ صلاحية الكاميرا ممنوعة');
      }
      if (statuses[Permission.storage]!.isDenied) {
        print('⚠️ صلاحية التخزين ممنوعة');
      }
    } catch (e) {
      print('❌ خطأ في طلب الصلاحيات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (!connectivity.isConnected) {
          return Scaffold(
            body: NoInternetWidget(
              onRetry: () async {
                final newStatus = await connectivity.isConnected;
                if (newStatus && context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              },
            ),
          );
        }
        return const WelcomeScreen();
      },
    );
  }
}