import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is LoginEvent) {
        try {
          emit(LoginLoading());
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: event.email, password: event.password);
          emit(LoginSuccess());
        } on FirebaseAuthException catch (e) {
          if (e.code == 'invalid-credential') {
            emit(LoginFailure(
                errMessage: "Incorrect email or password. Please try again."));
          } else {
            emit(
                LoginFailure(errMessage: e.message ?? "unknown error occured"));
          }
        } catch (e) {
          emit(LoginFailure(errMessage: "something went wrong"));
        }
      }
    });
  }
}
