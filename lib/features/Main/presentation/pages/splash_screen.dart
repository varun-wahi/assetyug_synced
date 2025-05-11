import 'package:asset_yug_debugging/firebase_options.dart';
import 'package:asset_yug_debugging/features/Inventory/data/repository/inventory_mongodb.dart';
import 'package:asset_yug_debugging/features/Auth/presentation/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; // Add this import


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
  }

  Future<void> _initializeApp() async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Hive
    await Hive.initFlutter();
    
    // Open the auth box
    final authBox = await Hive.openBox('auth_data');
    
    // Check if mobileId exists, if not create and save a new UUID
    if (!authBox.containsKey('mobileId')) {
      final uuid = const Uuid().v4(); // Generate a new UUID
      await authBox.put('mobileId', uuid);
      print('New mobile ID generated: $uuid');
    } else {
      final mobileId = authBox.get('mobileId');
      print('Existing mobile ID: $mobileId');
    }
    
    // Connect to MongoDB
    // await InventoryMongoDB.connect();

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