import 'package:asset_yug_debugging/firebase_options.dart';
import 'package:asset_yug_debugging/features/Inventory/data/repository/inventory_mongodb.dart';
import 'package:asset_yug_debugging/features/Auth/presentation/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'MainPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  
  void initState() {
    super.initState();
    _initializeApp();
    //test commit
  }

  Future<void> _initializeApp() async {
    // Simulate some initialization process
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  
    );
    await Hive.initFlutter();
    await InventoryMongoDB.connect();

    // Navigate to the LoginPage after initialization
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => const MainPage()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                'assets/images/asset_yug_logo.png'), // Your splash image
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
