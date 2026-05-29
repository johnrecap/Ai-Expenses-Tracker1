import 'package:flutter/painting.dart';

class AppShadows {
  AppShadows._();

  static const BoxShadow glassCard = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 32,
    offset: Offset(0, 8),
  );

  static const BoxShadow modalSheet = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 40,
    offset: Offset(0, -10),
  );

  static const BoxShadow subtleTop = BoxShadow(
    color: Color(0x05000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}
