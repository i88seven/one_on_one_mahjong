import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/config/theme.dart';

final biggerIconSize = Vector2(12.0, 12.0);
final smallerIconSize = Vector2(8.0, 8.0);

void renderResultBackgroud(Canvas canvas, Vector2 size) {
  const primaryOuterBorderSide = BorderSide(
    color: AppColor.primaryColorMain,
    width: 2,
  );
  paintBorder(
    canvas,
    Rect.fromLTRB(0, 0, size.x, size.y),
    top: primaryOuterBorderSide,
    right: primaryOuterBorderSide,
    bottom: primaryOuterBorderSide,
    left: primaryOuterBorderSide,
  );
  const secondaryOuterBorderSide = BorderSide(
    color: AppColor.gameDialogBackground,
    width: 2,
  );
  const secondaryOuterPadding = 2.0;
  paintBorder(
    canvas,
    Rect.fromLTRB(
      secondaryOuterPadding,
      secondaryOuterPadding,
      size.x - secondaryOuterPadding,
      size.y - secondaryOuterPadding,
    ),
    top: secondaryOuterBorderSide,
    right: secondaryOuterBorderSide,
    bottom: secondaryOuterBorderSide,
    left: secondaryOuterBorderSide,
  );
  const innerPadding = 4.0;
  canvas.drawRect(
    Rect.fromLTRB(
      innerPadding,
      innerPadding,
      size.x - innerPadding,
      size.y - innerPadding,
    ),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: AppColor.gradientBackground,
      ).createShader(
        Rect.fromLTRB(
          innerPadding,
          innerPadding,
          size.x - innerPadding,
          size.y - innerPadding,
        ),
      ),
  );
  const bodyPadding = 16.0;
  canvas.drawRect(
    Rect.fromLTRB(
      bodyPadding,
      bodyPadding,
      size.x - bodyPadding,
      size.y - bodyPadding,
    ),
    Paint()..color = AppColor.gameDialogBackground,
  );

  _renderSideIcon(canvas, size, Vector2(size.x - bodyPadding, bodyPadding));
  _renderSideIcon(
      canvas,
      size,
      Vector2(bodyPadding + biggerIconSize.x * 2,
          size.y - bodyPadding - biggerIconSize.y * 2));
}

// define as position of center
void _renderSideIcon(Canvas canvas, Vector2 size, Vector2 position) {
  const iconBorderSide = BorderSide(
    color: AppColor.primaryColorMain,
    width: 1,
  );

  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(
        position.x - biggerIconSize.x / 2,
        position.y + biggerIconSize.y / 2,
      ),
      width: biggerIconSize.x,
      height: biggerIconSize.y,
    ),
    Paint()..color = AppColor.primaryBackgroundColor,
  );
  paintBorder(
    canvas,
    Rect.fromCenter(
      center: Offset(
        position.x - biggerIconSize.x / 2,
        position.y + biggerIconSize.y / 2,
      ),
      width: biggerIconSize.x,
      height: biggerIconSize.y,
    ),
    top: iconBorderSide,
    right: iconBorderSide,
    bottom: iconBorderSide,
    left: iconBorderSide,
  );

  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(
        position.x - biggerIconSize.x - biggerIconSize.x / 2,
        position.y + biggerIconSize.y + biggerIconSize.y / 2,
      ),
      width: biggerIconSize.x,
      height: biggerIconSize.y,
    ),
    Paint()..color = AppColor.primaryBackgroundColor,
  );
  paintBorder(
    canvas,
    Rect.fromCenter(
      center: Offset(
        position.x - biggerIconSize.x - biggerIconSize.x / 2,
        position.y + biggerIconSize.y + biggerIconSize.y / 2,
      ),
      width: biggerIconSize.x,
      height: biggerIconSize.y,
    ),
    top: iconBorderSide,
    right: iconBorderSide,
    bottom: iconBorderSide,
    left: iconBorderSide,
  );

  paintBorder(
    canvas,
    Rect.fromCenter(
      center: Offset(
        position.x - biggerIconSize.x - smallerIconSize.x / 2,
        position.y + biggerIconSize.y - smallerIconSize.y / 2,
      ),
      width: smallerIconSize.x,
      height: smallerIconSize.y,
    ),
    top: iconBorderSide,
    right: iconBorderSide,
    bottom: iconBorderSide,
    left: iconBorderSide,
  );

  paintBorder(
    canvas,
    Rect.fromCenter(
      center: Offset(
        position.x - biggerIconSize.x + smallerIconSize.x / 2,
        position.y + biggerIconSize.y + smallerIconSize.y / 2,
      ),
      width: smallerIconSize.x,
      height: smallerIconSize.y,
    ),
    top: iconBorderSide,
    right: iconBorderSide,
    bottom: iconBorderSide,
    left: iconBorderSide,
  );
}
