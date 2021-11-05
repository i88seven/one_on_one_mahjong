import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class CreateRoomPage extends StatelessWidget {
  CreateRoomPage(this.user);
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー作成'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return const LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('ログイン情報：${user.email}'),
      ),
    );
  }
}
