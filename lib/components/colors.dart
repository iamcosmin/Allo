import 'package:flutter/cupertino.dart';

class FluentColors {
  static final Color messageBubble = CupertinoDynamicColor.withBrightness(
      color: Color(0xFFdbdbdb), darkColor: Color(0x292929));
  static final Color nonColors = CupertinoDynamicColor.withBrightness(
      color: Color(0xFFFFFFFF), darkColor: Color(0xFF000000));
  static final Color messageInput = CupertinoDynamicColor.withBrightness(
      color: Color(0xFFFFFFFF), darkColor: CupertinoColors.darkBackgroundGray);
}
