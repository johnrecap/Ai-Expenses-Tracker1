import 'package:flutter/widgets.dart';

class DirectionalityUtils {
  DirectionalityUtils._();

  static double safeBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static EdgeInsetsDirectional safeContentPadding(BuildContext context,
      {double bottomNavHeight = 80}) {
    final bottom = safeBottomPadding(context);
    return EdgeInsetsDirectional.only(bottom: bottom + bottomNavHeight);
  }

  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }
}
