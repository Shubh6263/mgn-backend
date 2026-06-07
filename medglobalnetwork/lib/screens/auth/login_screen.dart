import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  bool _isSignup = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6E6E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 48,
                    color: Color(0xFF0D6E6E),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'MedGlobal Network',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignup
                      ? 'Create your account with phone OTP'
                      : 'Login with your phone number',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
                const SizedBox(height: 40),
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    _phoneNumber = phone.completeNumber;
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return 'Enter phone number';
                    }
                    return null;
                  },
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.error!,
                    style: const TextStyle(color: Color(0xFFDC2626)),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: auth.status == AuthStatus.loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final sent = await auth.sendOtp(
                            _phoneNumber,
                            isSignup: _isSignup,
                          );
                          if (sent &&
                              context.mounted &&
                              auth.error == null &&
                              auth.status != AuthStatus.authenticated) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtpScreen(
                                  phoneNumber: _phoneNumber,
                                  isSignup: _isSignup,
                                ),
                              ),
                            );
                          }
                        },
                  child: auth.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isSignup ? 'Send OTP & Sign Up' : 'Send OTP & Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isSignup = !_isSignup),
                  child: Text(
                    _isSignup
                        ? 'Already have an account? Login'
                        : 'New user? Create account',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: auth.status == AuthStatus.loading
                      ? null
                      : () => auth.signInWithGoogle(),
                  icon: const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                    side: const BorderSide(color: Color(0xFFDADCE0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
