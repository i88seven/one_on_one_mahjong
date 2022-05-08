import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppColor {
  static const primaryColorMain = Color(0xFFCBC943);
  static const primaryBackgroundColor = Color(0xFFB90001);
  static const primaryGameButton = Color(0xFFBAECD2);
  static const gameDialogBackground = Color(0xFFFFFFFF);
  static const gameDialogText = Color(0xFF4C3B3B);
  static const gradientBackground = [
    Color(0xFF007D3C),
    Color(0xFFBAECD2),
    Color(0xFF4C0EBA),
  ];
  static const errorColor = Color(0xFFDD4B39);
  static const textBaseColor = Color(0xFF333333);
  static const textSubColor = Color(0xFF999999);
}

class AppFontSize {
  static const xSmall = 10.0;
  static const small = 12.0;
  static const midium = 14.0;
  static const large = 16.0;
  static const xLarge = 18.0;
}

final themeProvider = Provider((_ref) {
  final themeData = ThemeData.light();

  return themeData.copyWith(
    primaryColor: AppColor.primaryBackgroundColor,
    hintColor: AppColor.primaryBackgroundColor,
    errorColor: AppColor.errorColor,
    dividerColor: AppColor.primaryBackgroundColor,
    appBarTheme: themeData.appBarTheme.copyWith(
      backgroundColor: AppColor.primaryBackgroundColor,
      titleTextStyle: const TextStyle(
        color: AppColor.primaryColorMain,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      caption: themeData.textTheme.caption?.copyWith(
        color: AppColor.textBaseColor,
      ),
      bodyText1: themeData.textTheme.bodyText1?.copyWith(
        fontSize: AppFontSize.small,
        color: AppColor.textBaseColor,
      ),
      bodyText2: themeData.textTheme.bodyText2?.copyWith(
        fontSize: AppFontSize.midium,
        color: AppColor.textBaseColor,
      ),
      overline: themeData.textTheme.overline?.copyWith(
        color: AppColor.textBaseColor,
      ),
      button: themeData.textTheme.button?.copyWith(
        color: AppColor.primaryColorMain,
      ),
      subtitle1: themeData.textTheme.subtitle1?.copyWith(
        color: AppColor.textBaseColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        onPrimary: AppColor.primaryColorMain,
        primary: AppColor.primaryBackgroundColor,
        elevation: 0,
        padding: const EdgeInsets.all(4),
        textStyle: themeData.textTheme.button?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        minimumSize: const Size(150, 30),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: AppColor.primaryBackgroundColor,
        elevation: 0,
        padding: const EdgeInsets.all(4),
        textStyle: themeData.textTheme.button?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        side: const BorderSide(
          color: AppColor.primaryBackgroundColor,
          width: 1,
          style: BorderStyle.solid,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        minimumSize: const Size(150, 30),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        color: AppColor.textBaseColor,
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: AppColor.primaryBackgroundColor,
        ),
      ),
    ),
    cardTheme: const CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        side: BorderSide(
          width: 2,
          color: AppColor.primaryBackgroundColor,
        ),
      ),
    ),
  );
});
