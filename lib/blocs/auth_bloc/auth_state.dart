part of 'auth_bloc.dart';

// @immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

//Login States
final class LoginInitial extends AuthState {}
final class LoginSuccess extends AuthState {}
final class LoginLoading extends AuthState {}
final class LoginFailure extends AuthState {
  String errMessage;
  LoginFailure({required this.errMessage});
}

//Register States
final class RegisterInitial extends AuthState {}
final class RegisterSuccess extends AuthState {}
final class RegisterLoading extends AuthState {}
final class RegisterFailure extends AuthState {
  String errMessage;
  RegisterFailure({required this.errMessage});
}