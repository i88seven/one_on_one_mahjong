import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PreparationBackground extends StatelessWidget {
  const PreparationBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contraint) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 4,
            bottom: 12,
          ),
          child: SvgPicture.asset(
            'assets/icons/flower.svg',
            width: 116,
            height: 124,
          ),
        ),
      );
    });
  }
}
