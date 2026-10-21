import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Fetch full UserModel from Firestore for the signed-in user
  static Future<UserModel?> getUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data()!);
    } catch (e) {
      // ignore: avoid_print
      print('getUserModel error: $e');
    }
    return null;
  }

  /// Register a new user. Returns null on success, error message on failure.
  static Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final model = UserModel(
        uid: cred.user!.uid,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        email: email,
      );

      await _db.collection('users').doc(cred.user!.uid).set(model.toMap());
      await cred.user!.updateDisplayName('$firstName $lastName');
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  /// Sign in an existing user. Returns null on success, error message on failure.
  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e.code);
    }
  }

  /// Send a password reset email. Returns null on success.
  static Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e.code);
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static String _friendlyMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
