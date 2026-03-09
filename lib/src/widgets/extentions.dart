import 'package:flutter/material.dart';

import '../design/app_spacing.dart';

extension OnPressed on Widget {
  Widget ripple(
    Function onPressed, {
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(AppRadius.sm),
    ),
  }) => Stack(
    children: <Widget>[
      this,
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: TextButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: borderRadius),
            ),
          ),
          onPressed: () {
            onPressed();
          },
          child: Container(),
        ),
      ),
    ],
  );
}
