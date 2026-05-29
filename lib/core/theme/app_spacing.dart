import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double containerPadding = 20;
  static const double cardGutter = 12;

  static const EdgeInsetsDirectional screenPadding = EdgeInsetsDirectional.symmetric(
    horizontal: containerPadding,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsetsDirectional cardPaddingDirectional = EdgeInsetsDirectional.all(md);
  static const EdgeInsetsDirectional listPadding = EdgeInsetsDirectional.symmetric(
    vertical: sm,
  );
}
