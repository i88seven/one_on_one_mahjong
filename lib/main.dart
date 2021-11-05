import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const OneOnOneMahjongApp());
}

class OneOnOneMahjongApp extends StatelessWidget {
  const OneOnOneMahjongApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'タイマン麻雀',
      theme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}
