import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loopchat/constants.dart';
import 'package:loopchat/helper/device_id_service.dart';
// import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  //Login Functions
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

  //Register Functions
    Future<void> registerNewAcc({required email, required password, required userName}) async {
    final String? deviceId = await DeviceIdService.getDeviceId();
    if (email.isEmpty || password.isEmpty || userName.isEmpty) {
      throw "Please fill in all fields";
    }

    if (deviceId == null) {
      throw "Unable to get the user's device id";
    }
    try {
      emit(RegisterLoading());
      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('registerUserWithDeviceCheck');
      await callable.call<Map<String, dynamic>>({
        'email': email,
        'password': password,
        'username': userName,
        'deviceId': deviceId
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(RegisterSuccess());
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'resource-exhausted') {
        emit(RegisterFailure(errMessage: "Account limit reached for this device.")); 
      } else {
        emit(RegisterFailure(errMessage: e.message ?? "An unknown error occurred."));
      }
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(errMessage: e.code));
    } 
    catch (e) {
      emit(RegisterFailure(errMessage: e.toString()));
    }
  }

}
