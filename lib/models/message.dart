import 'package:loopchat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String msg;
  final String id;
  final DateTime createdAt;

  Message(this.msg, this.id, this.createdAt);

  factory Message.fromJson(jsonData) {
    final createdAtDate = jsonData[kCreatedAt];
    DateTime finalCreatedAt;
    if (createdAtDate is Timestamp) {
      finalCreatedAt = createdAtDate.toDate();
    } else {
      finalCreatedAt = DateTime.now();
    }
    return Message(jsonData[kMessage] as String? ?? '', jsonData['id'], finalCreatedAt);
  }
}