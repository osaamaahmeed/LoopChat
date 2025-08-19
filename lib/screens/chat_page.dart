import 'package:loopchat/constants.dart';
import 'package:loopchat/helper/show_snack_bar.dart';
import 'package:loopchat/models/message.dart';
import 'package:loopchat/screens/login_page.dart';
import 'package:loopchat/widgets/chat_buble.dart';
import 'package:loopchat/widgets/fullscreen_loader.dart';
import 'package:loopchat/widgets/online_user_counter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  static String id = "ChatPage";

  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference msg =
      FirebaseFirestore.instance.collection(kMessagesCollection);

  CollectionReference user =
      FirebaseFirestore.instance.collection(kUsersCollection);

  TextEditingController controller = TextEditingController();

  final listController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // String username = ModalRoute.of(context)!.settings.arguments as String;
    final fbUser = FirebaseAuth.instance.currentUser;
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || fbUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Not Logged In !"),
        ),
      );
    }
    final String username = fbUser.displayName ?? fbUser.email ?? fbUser.uid;
    // var email = ModalRoute.of(context)!.settings.arguments;
    return StreamBuilder<DocumentSnapshot>(
        stream: user.doc(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: null,
              ),
            );
          }

          if (userSnapshot.hasError ||
              !userSnapshot.hasData ||
              !userSnapshot.data!.exists) {
            return const Scaffold(
              body: Center(
                child: Text("Error Loading user data"),
              ),
            );
          }

          final userData = userSnapshot.data!;
          final int leftMessages = userData['leftMessages'];
          final bool canSendMessage = leftMessages > 0;

          return StreamBuilder<QuerySnapshot>(
            stream: msg.orderBy(kCreatedAt, descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                FullScreenLoader.hide();
                List<Message> messagesList = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  messagesList.add(Message.fromJson(snapshot.data!.docs[i]));
                }

                return Scaffold(
                  appBar: AppBar(
                    leading: Image.asset(kLogo),
                    // leadingWidth: 50,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Public Chat",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.5,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "$leftMessages messages left",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                              textAlign: TextAlign.left,
                            )
                          ],
                        ),
                        const OnlineUserCounter(),
                      ],
                    ),
                    backgroundColor: kAppBarColor,
                    actions: [
                      IconButton(
                          onPressed: () async {
                            signOut(context);
                          },
                          icon:
                              const Icon(Icons.logout, color: kSecondaryColor))
                    ],
                  ),
                  body: Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 24, 24, 24)
                        // color: Colors.white
                        ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              reverse: true,
                              itemCount: messagesList.length,
                              controller: listController,
                              itemBuilder: (context, index) {
                                return messagesList[index].id == username
                                    ? ChatBuble(
                                        message: messagesList[index],
                                        username: messagesList[index].id)
                                    : ChatBubleforFriend(
                                        message: messagesList[index],
                                        username: messagesList[index].id,
                                      );
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            controller: controller,
                            onSubmitted: (data) async {
                              try {
                                sendMessage(context, data, username,
                                    userData.reference, canSendMessage);
                              } catch (e) {
                                snackBarMessage(context, e.toString());
                              }
                            },
                            readOnly: !canSendMessage,
                            decoration: InputDecoration(
                              hintText: canSendMessage
                                  ? "Send Message"
                                  : "Limit Reached",
                              hintStyle: TextStyle(
                                  color: canSendMessage
                                      ? Colors.grey
                                      : Colors.red.shade400),
                              suffixIcon: IconButton(
                                onPressed: canSendMessage
                                    ? () {
                                        if (controller.text.trim().isNotEmpty) {
                                          sendMessage(
                                              context,
                                              controller.text.trim(),
                                              username,
                                              userData.reference,
                                              canSendMessage);
                                        }
                                      }
                                    : null,
                                icon: canSendMessage
                                    ? const Icon(Icons.send)
                                    : const Icon(null),
                                color: kSecondaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: kPrimaryColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 16,
                        ),
                        Text("Getting your chat ready ..."),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        });
  }

  void sendMessage(BuildContext context, String data, String email,
      DocumentReference userRef, bool canSend) {
    if (canSend == false) {
      snackBarMessage(context, "Limit reached, wait 24 hours");
      return;
    }
    try {
      msg.add({
        kMessage: data,
        kCreatedAt: FieldValue.serverTimestamp(),
        'id': email,
      });
      userRef.update({'leftMessages': FieldValue.increment(-1)});
      controller.clear();
      listController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
      );
    } catch (e) {
      snackBarMessage(context, "Failed to send message: ${e.toString()}");
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> signOut(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final userStatusRef = FirebaseDatabase.instance.ref('/status/$uid');
      await userStatusRef.set({'isOnline': false});
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, LoginPage.id, (route) => false);
    } catch (e) {
      snackBarMessage(context, "Error Signing out $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    listController.dispose();
    super.dispose();
  }
}
