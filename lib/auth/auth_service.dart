import 'package:firebase_auth/firebase_auth.dart';

/// Reusable authentication service for AquaIntel.
/// Uses Firebase Authentication with email/password only.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current Firebase user (null if not signed in).
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  /// Emits the current [User] when signed in, or null when signed out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email and password.
  /// On success, updates the display name and returns the [UserCredential].
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await credential.user?.updateDisplayName(name);
      // Reload so that currentUser reflects the updated name
      await credential.user?.reload();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Sign in an existing user with email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Converts Firebase-specific exceptions into clean, user-facing messages.
  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthException(
          'An account with this email already exists.',
        );
      case 'invalid-email':
        return AuthException(
          'Please enter a valid email address.',
        );
      case 'weak-password':
        return AuthException(
          'Password must contain at least 6 characters.',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException(
          'Incorrect email or password.',
        );
      case 'user-disabled':
        return AuthException(
          'This account has been disabled. Please contact support.',
        );
      case 'too-many-requests':
        return AuthException(
          'Too many attempts. Please try again later.',
        );
      case 'network-request-failed':
        return AuthException(
          'Please check your internet connection.',
        );
      default:
        return AuthException(
          'Something went wrong. Please try again.',
        );
    }
  }
}

/// Custom exception for clean, user-facing authentication error messages.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
