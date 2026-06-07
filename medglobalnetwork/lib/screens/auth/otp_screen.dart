import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isSignup;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.isSignup,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'OTP Code',
                  counterText: '',
                ),
              ),
              if (widget.isSignup) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (for profile avatar)',
                    hintText: 'your@email.com',
                  ),
                ),
              ],
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  auth.error!,
                  style: const TextStyle(color: Color(0xFFDC2626)),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: auth.status == AuthStatus.loading
                    ? null
                    : () async {
                        final success = await auth.verifyOtpAndLogin(
                          smsCode: _otpController.text.trim(),
                          email: _emailController.text.trim().isEmpty
                              ? null
                              : _emailController.text.trim(),
                          displayName: _nameController.text.trim().isEmpty
                              ? null
                              : _nameController.text.trim(),
                          isSignup: widget.isSignup,
                        );
                        if (success && context.mounted) {
                          Navigator.of(context).popUntil((r) => r.isFirst);
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
                    : const Text('Verify & Continue'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => auth.sendOtp(
                  widget.phoneNumber,
                  isSignup: widget.isSignup,
                ),
                child: const Text('Resend OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
