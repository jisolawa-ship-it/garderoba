import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    debugPrint('[Auth] 1/4 otwieram wybór konta Google...');
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('[Auth] Użytkownik anulował wybór konta.');
      return null;
    }
    debugPrint('[Auth] 2/4 konto wybrane: ${googleUser.email}, pobieram tokeny...');

    final googleAuth = await googleUser.authentication;
    debugPrint(
      '[Auth] 3/4 tokeny odebrane (accessToken: '
      '${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}), '
      'loguję do Firebase...',
    );
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    debugPrint('[Auth] 4/4 zalogowano do Firebase: ${userCredential.user?.uid}');
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
