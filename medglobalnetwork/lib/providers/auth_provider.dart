import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  biometricRequired,
  authenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  String? _verificationId;
  int? _resendToken;
  bool _pendingSignup = false;
  String? _pendingEmail;
  String? _pendingDisplayName;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  AuthService get authService => _authService;

  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final restored = await _authService.restoreSession();
    if (!restored) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    final biometricEnabled = await _authService.isBiometricEnabled();
    if (biometricEnabled) {
      _status = AuthStatus.biometricRequired;
      notifyListeners();
      return;
    }

    await _loadUser();
  }

  Future<bool> sendOtp(
    String phoneNumber, {
    bool isSignup = false,
    String? email,
    String? displayName,
  }) async {
    _error = null;
    _status = AuthStatus.loading;
    _pendingSignup = isSignup;
    _pendingEmail = email;
    _pendingDisplayName = displayName;
    notifyListeners();

    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
      onError: (e) {
        _error = _mapFirebaseOtpError(e);
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
      onAutoVerified: (credential) async {
        await _completeBackendAuth(
          firebaseUid: credential.user?.uid,
          phoneNumber: credential.user?.phoneNumber,
        );
      },
      forceResendingToken: _resendToken,
    );

    return _error == null;
  }

  Future<bool> verifyOtpAndLogin({
    required String smsCode,
    String? email,
    String? displayName,
    bool isSignup = false,
  }) async {
    if (_verificationId == null) {
      _error = 'Verification ID missing. Resend OTP.';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.verifyOtp(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final firebaseUid = credential.user!.uid;
      final phone = credential.user!.phoneNumber ?? '';

      await _completeBackendAuth(
        firebaseUid: firebaseUid,
        phoneNumber: phone,
        isSignup: isSignup,
        email: email,
        displayName: displayName,
      );

      // If backend returned a user, consider auth successful.
      if (_user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'OTP verification failed';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    final available = await _biometricService.isAvailable();
    if (!available) {
      _error = 'Biometric authentication not available';
      notifyListeners();
      return false;
    }

    final success = await _biometricService.authenticate(
      reason: 'Login to MedGlobal Network',
    );

    if (!success) {
      _error = 'Biometric authentication failed';
      notifyListeners();
      return false;
    }

    await _loadUser();
    return true;
  }

  Future<void> skipBiometric() async {
    await _loadUser();
  }

  Future<void> enableBiometric() async {
    await _authService.setBiometricEnabled(true);
    if (_user != null) {
      _user = await _authService.api.updateProfile(biometricEnabled: true);
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? profileImageUrl,
  }) async {
    _user = await _authService.api.updateProfile(
      displayName: displayName,
      email: email,
      profileImageUrl: profileImageUrl,
    );
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        _error = 'Google sign-in failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final uid = firebaseUser.uid;
      final email = firebaseUser.email ?? '';
      final displayName = firebaseUser.displayName ?? email.split('@').first;
      final profileImageUrl = firebaseUser.photoURL ?? '';

      _user = await _authService.googleAuthOnBackend(
        firebaseUid: uid,
        email: email,
        displayName: displayName,
        profileImageUrl: profileImageUrl,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _verificationId = null;
    _status = AuthStatus.unauthenticated;
    _pendingSignup = false;
    _pendingEmail = null;
    _pendingDisplayName = null;
    notifyListeners();
  }

  Future<void> _completeBackendAuth({
    required String? firebaseUid,
    required String? phoneNumber,
    bool? isSignup,
    String? email,
    String? displayName,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final uid = firebaseUid;
    final phone = phoneNumber;

    if (uid == null || phone == null || phone.isEmpty) {
      _error = 'Firebase verification failed';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    final signup = isSignup ?? _pendingSignup;
    final backendEmail = email ?? _pendingEmail;
    final backendDisplayName = displayName ?? _pendingDisplayName;

    try {
      if (signup) {
        _user = await _authService.registerOnBackend(
          firebaseUid: uid,
          phoneNumber: phone,
          email: backendEmail,
          displayName: backendDisplayName,
        );
      } else {
        try {
          _user = await _authService.loginOnBackend(firebaseUid: uid);
        } catch (e) {
          final message = e.toString().toLowerCase();
          if (message.contains('user not found')) {
            _user = await _authService.registerOnBackend(
              firebaseUid: uid,
              phoneNumber: phone,
              email: backendEmail,
              displayName: backendDisplayName,
            );
          } else {
            rethrow;
          }
        }
      }

      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      _error = _user != null ? null : 'Authentication failed';
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadUser() async {
    try {
      _user = await _authService.api.getProfile();
      _status = AuthStatus.authenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  String _mapFirebaseOtpError(FirebaseAuthException e) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();

    if (code == 'too-many-requests' ||
        code == 'quota-exceeded' ||
        message.contains('unusual activity') ||
        code == '17010') {
      return 'Firebase temporarily blocked OTP requests from this device. Use a Firebase test phone number or wait and try again later.';
    }

    if (message.contains('recaptcha')) {
      return 'Firebase reCAPTCHA / Play Integrity setup is incomplete. Check SHA-1/SHA-256 and Firebase phone auth settings.';
    }

    return e.message ?? 'OTP send failed';
  }
}
