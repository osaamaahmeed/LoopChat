import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

void updateUserStatus() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final userStatusRef = FirebaseDatabase.instance.ref('/status/$uid');

  final onlineStatus = {'isOnline': true};

  final offlineStatus = {'isOnline': false};

  userStatusRef.set(onlineStatus);

  userStatusRef.onDisconnect().set(offlineStatus);
}