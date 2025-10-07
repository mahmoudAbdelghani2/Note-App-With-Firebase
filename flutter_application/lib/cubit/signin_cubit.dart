
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application/cubit/auth_states.dart';
import 'package:flutter_application/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitialState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  
  void checkAuthStatus() {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthSignedInState(UserModel.fromFirebaseUser(user)));
    } else {
      emit(AuthSignedOutState());
    }
  }

  
  Future<void> signInWithGoogle() async {
    emit(AuthLoadingState());
    try {
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        
        emit(AuthSignedOutState());
        return;
      }

      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        emit(AuthSignedInState(UserModel.fromFirebaseUser(userCredential.user!)));
      } else {
        emit(AuthErrorState('Failed to sign in'));
      }
    } catch (e, stack) {
      debugPrint('Google sign-in failed: $e\n$stack');
      emit(AuthErrorState('Failed to sign in with Google: ${e.toString()}'));
    }
  }

  
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(AuthLoadingState());
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        emit(AuthSignedInState(UserModel.fromFirebaseUser(userCredential.user!)));
      } else {
        emit(AuthErrorState('Failed to sign in'));
      }
    } catch (e) {
      debugPrint('Email sign-in failed: $e');
      emit(AuthErrorState('Failed to sign in: ${e.toString()}'));
    }
  }

  
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    emit(AuthLoadingState());
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        emit(AuthSignedInState(UserModel.fromFirebaseUser(userCredential.user!)));
      } else {
        emit(AuthErrorState('Failed to create account'));
      }
    } catch (e) {
      debugPrint('Sign up failed: $e');
      emit(AuthErrorState('Failed to create account: ${e.toString()}'));
    }
  }

  
  Future<void> signOut() async {
    emit(AuthLoadingState());
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      emit(AuthSignedOutState());
    } catch (e) {
      debugPrint('Sign out failed: $e');
      emit(AuthErrorState('Failed to sign out: ${e.toString()}'));
    }
  }

  
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  
  Future<void> resetPassword(String email) async {
    emit(AuthLoadingState());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(AuthSignedOutState());
    } catch (e) {
      debugPrint('Password reset failed: $e');
      emit(AuthErrorState('Failed to send password reset email: ${e.toString()}'));
    }
  }
}
