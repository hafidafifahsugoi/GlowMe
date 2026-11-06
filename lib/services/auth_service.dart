import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      print('Attempting login with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Login successful for user: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected login error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String name,
    String skinType,
  ) async {
    try {
      print('Attempting registration with email: $email');

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Registration successful for user: ${userCredential.user?.uid}');

      // Create user document in Firestore
      print('Creating user document in Firestore...');
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'name': name,
        'email': email,
        'skinType': skinType,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create default settings for user
      print('Creating default settings...');
      await _firestore
          .collection('settings')
          .doc(userCredential.user!.uid)
          .set({
        'userId': userCredential.user!.uid,
        'notificationMorning': true,
        'notificationNight': true,
        'morningTime': '07:00',
        'nightTime': '18:00',
        'darkMode': false,
      });

      print('User setup complete');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected registration error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    // Send password reset email
    // Link will open Firebase's default web page for password reset
    await _auth.sendPasswordResetEmail(email: email);
  }
}
