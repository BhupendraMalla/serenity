import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'src/app.dart';
// import 'src/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // For now, we'll skip Firebase initialization in demo mode
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  // Initialize Hive for local storage
  // TODO: Enable after generating adapters
  // await HiveService.initialize();
  
  runApp(
    const ProviderScope(
      child: SerenityApp(),
    ),
  );
}
