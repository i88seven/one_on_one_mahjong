import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginInput extends StatefulWidget {
  final Function(String uid) onCreate;
  final Function(String uid) onLogin;
  final Function(String uid) onLoginAnonymously;

  const LoginInput({
    required this.onCreate,
    required this.onLogin,
    required this.onLoginAnonymously,
    Key? key,
  }) : super(key: key);

  @override
  _LoginInputState createState() => _LoginInputState();
}

class _LoginInputState extends State<LoginInput> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String infoText = '';

  Future<void> _onCreateAccount() async {
    try {
      setState(() {
        infoText = '';
      });
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
      setState(() {
        infoText = '';
      });
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

  Future<void> _onAppleLogin() async {
    try {
      if (!Platform.isIOS) {
        setState(() {
          infoText = "ログインに失敗しました：iOS以外でAppleログインはできません";
        });
        return;
      }
      setState(() {
        infoText = '';
      });
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [],
      );

      OAuthProvider oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final FirebaseAuth auth = FirebaseAuth.instance;
      final result = await auth.signInWithCredential(credential);
      if (result.additionalUserInfo!.isNewUser) {
        await widget.onCreate(result.user!.uid);
      } else {
        await widget.onLogin(result.user!.uid);
      }
    } catch (e) {
      setState(() {
        infoText = "ログインに失敗しました：${e.toString()}";
      });
    }
  }

  Future<void> _onGoogleLogin() async {
    try {
      setState(() {
        infoText = '';
      });
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw 'googleUser is not found';
      }
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseAuth auth = FirebaseAuth.instance;
      final result = await auth.signInWithCredential(credential);
      if (result.additionalUserInfo!.isNewUser) {
        await widget.onCreate(result.user!.uid);
      } else {
        await widget.onLogin(result.user!.uid);
      }
    } catch (e) {
      setState(() {
        infoText = "ログインに失敗しました：${e.toString()}";
      });
    }
  }

  Future<void> _onLoginAnonymously() async {
    try {
      setState(() {
        infoText = '';
      });
      final FirebaseAuth auth = FirebaseAuth.instance;
      final result = await auth.signInAnonymously();
      await widget.onLoginAnonymously(result.user!.uid);
    } catch (e) {
      setState(() {
        infoText = "ログインに失敗しました：${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 255,
              validator: (value) {
                if (value == null || value == '') {
                  return '入力してください';
                }
                if (!EmailValidator.validate(value)) {
                  return '不正なメールアドレスです';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
              maxLength: 32,
              validator: (value) {
                if (value == null || value == '') {
                  return '入力してください';
                }
                if (value.length < 8) {
                  return '8文字以上入力してください';
                }
                return null;
              },
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
                  if (!_key.currentState!.validate()) {
                    return;
                  }
                  await _onCreateAccount();
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                child: const Text('ログイン'),
                onPressed: () async {
                  if (!_key.currentState!.validate()) {
                    return;
                  }
                  await _onLogin();
                },
              ),
            ),
            const SizedBox(height: 24),
            if (Platform.isIOS)
              SizedBox(
                width: double.infinity,
                child: SignInButton(
                  Buttons.Apple,
                  onPressed: () async {
                    await _onAppleLogin();
                  },
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: SignInButton(
                Buttons.GoogleDark,
                onPressed: () async {
                  await _onGoogleLogin();
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                child: const Text('匿名ユーザーで使用'),
                onPressed: () async {
                  await _onLoginAnonymously();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
