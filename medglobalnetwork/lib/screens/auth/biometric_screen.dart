import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class BiometricScreen extends StatelessWidget {
  const BiometricScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D6E6E).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 72,
                  color: Color(0xFF0D6E6E),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Fingerprint Login',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Use your fingerprint to securely access MedGlobal Network',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  auth.error!,
                  style: const TextStyle(color: Color(0xFFDC2626)),
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => auth.authenticateWithBiometric(),
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Authenticate'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => auth.skipBiometric(),
                child: const Text('Use phone login instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
