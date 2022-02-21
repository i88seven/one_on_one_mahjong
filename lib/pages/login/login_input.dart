import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/pages/game_user/register_name.dart';
import 'package:one_on_one_mahjong/pages/preparation/main.dart';

class LoginInput extends StatefulWidget {
  final Function(Map<String, dynamic> gameUserJson) onSubmit;

  const LoginInput({required this.onSubmit, Key? key}) : super(key: key);

  @override
  _LoginInputState createState() => _LoginInputState();
}

class _LoginInputState extends State<LoginInput> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String infoText = '';

  Future<void> _onCreateAccount() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final result = await auth.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      String uid = result.user!.uid;
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      await userRef.set({
        'name': '',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      await widget.onSubmit({'uid': uid, 'name': ''});
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return const RegisterGameUserNamePage();
        }),
      );
    } on FirebaseAuthException catch (e) {
      const errorMap = {
        'email-already-in-use': 'すでに登録されています。',
        'invalid-email': '不正なメールアドレスです。',
        'operation-not-allowed': '許可されていない操作です。',
        'weak-password': '強力なパスワードにしてください。',
      };
      setState(() {
        infoText = "登録に失敗しました。\n${errorMap[e.code]}";
      });
    }
  }

  Future<void> _onLogin() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final result = await auth.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      String uid = result.user!.uid;
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      final userData = await userRef.get();
      await widget.onSubmit({'uid': uid, 'name': userData['name']});

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<bool>(
          builder: (context) => const PreparationMainPage(),
        ),
      );
    } catch (e) {
      setState(() {
        infoText = "ログインに失敗しました：${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'メールアドレス'),
          ),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'パスワード'),
            obscureText: true,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              infoText,
              style: TextStyle(color: Colors.yellow[300]),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: const Text('ユーザー登録'),
              onPressed: () async {
                await _onCreateAccount();
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              child: const Text('ログイン'),
              onPressed: () async {
                await _onLogin();
              },
            ),
          ),
        ],
      ),
    );
  }
}
