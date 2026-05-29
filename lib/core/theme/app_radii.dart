import 'package:flutter/widgets.dart';

class AppRadii {
  AppRadii._();

  static const BorderRadius sm = BorderRadius.all(Radius.circular(4));
  static const BorderRadius md = BorderRadius.all(Radius.circular(8));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(12));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(18));
  static const BorderRadius card = BorderRadius.all(Radius.circular(24));
  static const BorderRadiusGeometry sheet = BorderRadiusDirectional.only(
    topStart: Radius.circular(32),
    topEnd: Radius.circular(32),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
