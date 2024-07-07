import 'package:flutter/material.dart';

class InputBarStyle {
  static const double suggestionAvatarSize = 30;

  static const double suggestionAvatarFontSize = 15;

  static const double suggestionSize = 50;

  static const double suggestionBorderRadius = 12.0;

  static const double suggestionListPadding = 8.0;

  static TextStyle getTypeAheadTextStyle(BuildContext context) => TextStyle(
        fontSize: 15,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      );

  static const double suggestionTileAvatarTextGap = 8.0;
}
