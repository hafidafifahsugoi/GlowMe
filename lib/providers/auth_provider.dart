import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  User? get firebaseUser => _authService.currentUser;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    _currentUser = await _authService.getUserData(userId);
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailPassword(email, password);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          _errorMessage = 'Kata sandi salah';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          _errorMessage = 'Akun telah dinonaktifkan';
          break;
        case 'too-many-requests':
          _errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti';
          break;
        case 'network-request-failed':
          _errorMessage = 'Tidak ada koneksi internet';
          break;
        case 'invalid-credential':
          _errorMessage = 'Email atau kata sandi salah';
          break;
        case 'INVALID_LOGIN_CREDENTIALS':
          _errorMessage = 'Email atau kata sandi salah';
          break;
        default:
          _errorMessage = 'Login gagal: ${e.message}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String name,
    String skinType,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUpWithEmailPassword(
        email,
        password,
        name,
        skinType,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Pendaftaran tidak diizinkan. Hubungi admin';
          break;
        case 'weak-password':
          _errorMessage = 'Kata sandi terlalu lemah';
          break;
        case 'network-request-failed':
          _errorMessage = 'Tidak ada koneksi internet';
          break;
        default:
          _errorMessage = 'Pendaftaran gagal: ${e.message}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'network-request-failed':
          _errorMessage = 'Tidak ada koneksi internet';
          break;
        default:
          _errorMessage = 'Gagal mengirim email: ${e.message}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }
}
