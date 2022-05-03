
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginInput extends StatefulWidget {
  final Function(String uid) onCreate;
  final Function(String uid) onLogin;

  const LoginInput({required this.onCreate, required this.onLogin, Key? key})
      : super(key: key);

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

      await widget.onCreate(result.user!.uid);
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
      await widget.onLogin(result.user!.uid);
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
