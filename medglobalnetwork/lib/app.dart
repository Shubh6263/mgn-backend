import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/biometric_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

class MedGlobalApp extends StatelessWidget {
  const MedGlobalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedGlobal Network',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.biometricRequired:
            return const BiometricScreen();
          case AuthStatus.authenticated:
            return const MainShell();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
