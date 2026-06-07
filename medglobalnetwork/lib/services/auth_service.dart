import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  GoogleSignIn get _gs => _googleSignIn ??= GoogleSignIn();

  static const _tokenKey = 'auth_token';
  static const _biometricKey = 'biometric_enabled';

  ApiService get api => _api;

  User? get firebaseUser => _firebaseAuth.currentUser;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onError,
    required Future<void> Function(UserCredential credential) onAutoVerified,
    int? forceResendingToken,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (credential) async {
          final signedIn = await _firebaseAuth.signInWithCredential(credential);
          await onAutoVerified(signedIn);
        },
        verificationFailed: onError,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (_) {},
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      onError(e);
    }
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _gs.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserModel> googleAuthOnBackend({
    required String firebaseUid,
    required String email,
    required String displayName,
    required String profileImageUrl,
  }) async {
    final result = await _api.googleAuth(
      firebaseUid: firebaseUid,
      email: email,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
    );
    await _saveToken(result.token);
    return result.user;
  }

  Future<UserModel> registerOnBackend({
    required String firebaseUid,
    required String phoneNumber,
    String? email,
    String? displayName,
  }) async {
    final result = await _api.register(
      firebaseUid: firebaseUid,
      phoneNumber: phoneNumber,
      email: email,
      displayName: displayName,
    );
    await _saveToken(result.token);
    return result.user;
  }

  Future<UserModel> loginOnBackend({required String firebaseUid}) async {
    final result = await _api.login(firebaseUid: firebaseUid);
    await _saveToken(result.token);
    return result.user;
  }

  Future<void> _saveToken(String token) async {
    _api.setToken(token);
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<bool> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return false;
    _api.setToken(token);
    return _firebaseAuth.currentUser != null;
  }

  Future<bool> isBiometricEnabled() async {
    return (await _storage.read(key: _biometricKey)) == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricKey,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<void> signOut() async {
    await _gs.signOut();
    await _firebaseAuth.signOut();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _biometricKey);
    _api.clearToken();
  }
}
