import 'package:asset_yug_debugging/features/Main/presentation/pages/splash_screen.dart';

import 'package:asset_yug_debugging/config/theme/light_theme_data.dart';
import 'package:asset_yug_debugging/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(
    const ProviderScope(child: MyApp()),
  );
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asset Yug',
      theme: lightThemeData,
      // home: const LoginPage(),
      home: const SplashScreen(),
      // home: const MainPage(),
    );
  }
}