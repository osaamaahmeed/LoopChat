import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loopchat/constants.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  String ?email;
  String ?userName;

  Future<void> loginUser({required email, required password}) async {
    this.email = email;
    try {
      emit(LoginLoading());
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);    
      getUserId();
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        emit(LoginFailure(errMessage: "Incorrect email or password. Please try again."));
      } else {
        emit(LoginFailure(errMessage: e.message ?? "unkown error occured"));
      }
    } 
    catch (e) {
      emit(LoginFailure(errMessage: "something went wrong"));
    }
  }

    Future<void> getUserId() async {
    var userQuery = FirebaseFirestore.instance.collection(kUsersCollection).where('email', isEqualTo: email).get();
    var querySnapshot = await userQuery;
    if (querySnapshot.docs.isNotEmpty) {
      var document = querySnapshot.docs.first;
      userName = (document.data())['username'];
    } else {
      throw "Can't Find a username for the email";
    }
  }

}
