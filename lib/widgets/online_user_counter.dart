import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OnlineUserCounter extends StatelessWidget {
  const OnlineUserCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final countRef = FirebaseDatabase.instance.ref('/online_users_count');

    return StreamBuilder(
        stream: countRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
      width: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            color: Colors.green,
            size: 20,
          ),
          Text(
            "0",
            style: TextStyle(color: Colors.green, fontSize: 16),
          ),
        ],
      ),
    );
          }
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data!.snapshot.value != null) {
            final count = snapshot.data!.snapshot.value ?? 0;
            return OnlineStatus(
              num: count,
            );
          }
          return const OnlineStatus(
            num: 0,
          );
        });
  }
}

class OnlineStatus extends StatelessWidget {
  const OnlineStatus({super.key, required this.num});
  final Object num;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person,
            color: Colors.green,
            size: 20,
          ),
          Text(
            "$num",
            style: const TextStyle(color: Colors.green, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
