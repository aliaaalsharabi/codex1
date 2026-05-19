import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:appwrite/appwrite.dart' hide Permission, Locale;
import 'package:codex_firebase/providers.dart';
import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/views/Splash_Screen.dart';
import 'package:codex_firebase/views/no_internet_widget.dart';
import 'package:codex_firebase/modelview/db_ai_vm.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

import 'modelview/cart_vm.dart';

late final AppwriteStorageService appwriteStorageService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final client = Client()
      .setEndpoint('https://fra.cloud.appwrite.io/v1')
      .setProject('6a067722000222d0bfbb');

  appwriteStorageService = AppwriteStorageService(client);
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
        Provider<AppwriteStorageService>.value(value: appwriteStorageService),
        ChangeNotifierProvider(create: (_) => DB_AI_Vm()),
        ChangeNotifierProvider(create: (_) => Cart_Vm()),
      ],
      child: Consumer<Language_Vm>(
        builder: (context, langVm, child) {
          return MaterialApp(
            key: ValueKey(langVm.currentLanguage),
            debugShowCheckedModeBanner: false,
            title: 'CODEX',
            locale: langVm.locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            // ✅ الإضافة الأساسية لحل المشكلة
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primaryColor: const Color(0xFF429EBD),
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Tajawal',
              useMaterial3: true,
            ),
            // ✅ builder يبقى كما هو - الآن يعمل صح لأن Localizations موجودة
            builder: (context, child) {
              return Directionality(
                textDirection: langVm.textDirection,
                child: child!,
              );
            },
            home: const ConnectivityWrapper(),
          );
        },
      ),
    );
  }
}

class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({super.key});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    try {
      final camera = await Permission.camera.request();
      print('Camera: $camera');
      final storage = await Permission.storage.request();
      print('Storage: $storage');
    } catch (e) {
      print('Error: $e');
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
                if (context.mounted) setState(() {});
              },
            ),
          );
        }
        return const WelcomeScreen();
      },
    );
  }
}
