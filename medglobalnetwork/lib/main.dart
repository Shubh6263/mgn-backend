import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  firebase_auth.FirebaseAuth.instance.setLanguageCode('en');

  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const MedGlobalApp(),
    ),
  );
}
