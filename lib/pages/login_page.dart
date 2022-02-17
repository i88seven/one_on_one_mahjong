import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/pages/preparation/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String infoText = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
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
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      String uid = result.user!.uid;
                      final LocalStorage _storage =
                          LocalStorage('one_one_one_mahjong');
                      await _storage.ready;
                      _storage.setItem('myUid', result.user!.uid);
                      DocumentReference userRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid);
                      await userRef.set({
                        'name': '',
                        'createdAt': Timestamp.now(),
                        'updatedAt': Timestamp.now(),
                      });

                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return const PreparationMainPage();
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
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  child: const Text('ログイン'),
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      final LocalStorage _storage =
                          LocalStorage('one_one_one_mahjong');
                      await _storage.ready;
                      _storage.setItem('myUid', result.user!.uid);

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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
