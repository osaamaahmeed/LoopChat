part of 'login_cubit.dart';


abstract class LoginState {}

final class LoginInitial extends LoginState {}
final class LoginSuccess extends LoginState {}
final class LoginLoading extends LoginState {}
final class LoginFailure extends LoginState {
  String errMessage;
  LoginFailure({required this.errMessage});
}
