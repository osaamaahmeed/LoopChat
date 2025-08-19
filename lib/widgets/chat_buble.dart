import 'package:loopchat/constants.dart';
import 'package:loopchat/models/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBuble extends StatelessWidget {
  const ChatBuble({super.key, required this.message, required this.username});
  final String username;
  final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          // width: 250,
          // alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 20),
          // height: 65,
          decoration: const BoxDecoration(
              color: kSecondaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
                bottomLeft: Radius.circular(32),
              )),
          child: Stack(
            alignment: Alignment.centerRight,
            clipBehavior: Clip.none,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.msg,
                  style: const TextStyle(color: Colors.white, fontSize: 17)),
              Positioned(
                  top: -35,
                  right: -20,
                  child: Row(
                    children: [
                      const Text(
                        "You ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        DateFormat('hh:mm a').format(message.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      )
                    ],
                  )),
            ],
          )),
    );
  }
}

class ChatBubleforFriend extends StatelessWidget {
  const ChatBubleforFriend(
      {super.key, required this.message, required this.username});
  final Message message;
  final String username;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        // width: 250,
        // alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 20),
        // height: 65,
        decoration: const BoxDecoration(
            color: Color(0xFF4A5568),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
              bottomRight: Radius.circular(32),
            )),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Text(
              message.msg,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            Positioned(
              top: -35,
              left: -20,
              child: Row(
              children: [
                Text(
                  "$username ",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(DateFormat('hh:mm a').format(message.createdAt), style: const TextStyle(color: Colors.grey),)
              ],
            ))
          ],
        ),
      ),
    );
  }
}
