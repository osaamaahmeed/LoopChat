import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loopchat/helper/device_id_service.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

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
