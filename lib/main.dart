import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_on_one_mahjong/pages/login/login_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: OneOnOneMahjongApp()));
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
