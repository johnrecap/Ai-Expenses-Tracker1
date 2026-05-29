import 'package:flutter/widgets.dart';
import 'app_breakpoints.dart';

class ResponsiveConstraints {
  const ResponsiveConstraints._();

  static BoxConstraints mobileContent(double availableWidth) {
    final maxWidth = availableWidth.clamp(
      AppBreakpoints.width360,
      AppBreakpoints.maxMobileWidth,
    );
    return BoxConstraints(maxWidth: maxWidth);
  }

  static BoxConstraints get mobileMax {
    return const BoxConstraints(maxWidth: AppBreakpoints.maxMobileWidth);
  }
}
