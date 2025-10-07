import 'package:flutter_application/models/user_model.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSignedInState extends AuthState {
  final UserModel user;
  AuthSignedInState(this.user);
}

class AuthSignedOutState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}