import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iBIT/Onboarding_screen.dart';
import 'package:iBIT/Splashscreen.dart';
import 'SignUpPage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await requestStoragePermission();

 await FirebaseAppCheck.instance.activate();

  // Initialize emulators only in development;
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseFirestore.instance.settings = Settings(
  //   host: 'localhost:8080',
  //   sslEnabled: false,
  //   persistenceEnabled: false,
  // );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Up',
      home: SplashScreen(),
    );
  }
}

Future<void> requestStoragePermission() async {
  PermissionStatus status = await Permission.storage.status;

  if (status.isGranted) {
    print('Storage permission already granted.'); 
  } else if (status.isDenied || status.isPermanentlyDenied) {
    // Request the permission
    status = await Permission.storage.request();

    if (status.isGranted) {
      print('Storage permission granted.');
    } else if (status.isDenied) {
      print('Storage permission denied.');
    } else if (status.isPermanentlyDenied) {
      print('Storage permission permanently denied. Opening app settings...');
      // Open app settings
      openAppSettings();
    }
  }
}

