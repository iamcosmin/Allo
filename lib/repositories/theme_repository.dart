import 'package:allo/repositories/preferences_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeProvider = Provider<AppTheme>((ref) => AppTheme());

// Please update _TextThemeDefaultsBuilder accordingly after changing the default
// color here, as their implementation depends on the default value of the color
// field.
//
// Values derived from https://developer.apple.com/design/resources/.
const TextStyle _kDefaultTextStyle = TextStyle(
  inherit: false,
  fontFamily: 'VarDisplay',
  fontSize: 17.0,
  color: CupertinoColors.label,
  decoration: TextDecoration.none,
);

// Please update _TextThemeDefaultsBuilder accordingly after changing the default
// color here, as their implementation depends on the default value of the color
// field.
//
// Values derived from https://developer.apple.com/design/resources/.
const TextStyle _kDefaultActionTextStyle = TextStyle(
  inherit: false,
  fontFamily: 'VarDisplay',
  fontSize: 17.0,
  color: CupertinoColors.white,
  decoration: TextDecoration.none,
);

// Please update _TextThemeDefaultsBuilder accordingly after changing the default
// color here, as their implementation depends on the default value of the color
// field.
//
// Values derived from https://developer.apple.com/design/resources/.
const TextStyle _kDefaultTabLabelTextStyle = TextStyle(
  inherit: false,
  fontFamily: 'VarDisplay',
  fontSize: 11.0,
  color: CupertinoColors.inactiveGray,
);

const TextStyle _kDefaultMiddleTitleTextStyle = TextStyle(
  inherit: false,
  fontFamily: 'VarDisplay',
  fontSize: 17.0,
  fontWeight: FontWeight.w600,
  color: CupertinoColors.label,
);

const TextStyle _kDefaultLargeTitleTextStyle = TextStyle(
  inherit: false,
  fontFamily: 'VarDisplay',
  fontSize: 34.0,
  fontWeight: FontWeight.w700,
  color: CupertinoColors.label,
);

// Please update _TextThemeDefaultsBuilder accordingly after changing the default
// color here, as their implementation depends on the default value of the color
// field.
//
// Inspected on iOS 13 simulator with "Debug View Hierarchy".
// Value extracted from off-center labels. Centered labels have a font size of 25pt.
//
// The letterSpacing sourced from iOS 14 simulator screenshots for comparison.
// See also:
//
// * https://github.com/flutter/flutter/pull/65501#discussion_r486557093
const TextStyle _kDefaultPickerTextStyle = TextStyle(
  inherit: false,
  fontFamily: 'VarDisplay',
  fontSize: 21.0,
  fontWeight: FontWeight.w400,
  color: CupertinoColors.label,
);

// Please update _TextThemeDefaultsBuilder accordingly after changing the default
// color here, as their implementation depends on the default value of the color
// field.
//
// Inspected on iOS 13 simulator with "Debug View Hierarchy".
// Value extracted from off-center labels. Centered labels have a font size of 25pt.
const TextStyle _kDefaultDateTimePickerTextStyle = TextStyle(
  inherit: false,
  fontFamily: 'VarDisplay',
  fontSize: 21,
  fontWeight: FontWeight.normal,
  color: CupertinoColors.label,
);

class AppTheme {
  static final _textTheme = CupertinoTextThemeData(
    actionTextStyle: _kDefaultActionTextStyle,
    dateTimePickerTextStyle: _kDefaultDateTimePickerTextStyle,
    navActionTextStyle: _kDefaultActionTextStyle,
    navLargeTitleTextStyle: _kDefaultLargeTitleTextStyle,
    navTitleTextStyle: _kDefaultMiddleTitleTextStyle,
    pickerTextStyle: _kDefaultPickerTextStyle,
    tabLabelTextStyle: _kDefaultTabLabelTextStyle,
    textStyle: _kDefaultTextStyle,
  );
  static final CupertinoThemeData _kLightTheme = CupertinoThemeData(
    barBackgroundColor: CupertinoColors.systemGroupedBackground,
    brightness: Brightness.light,
    primaryColor: CupertinoColors.activeBlue,
    primaryContrastingColor: CupertinoColors.black,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    textTheme: _textTheme,
  );

  static final CupertinoThemeData _kDarkTheme = CupertinoThemeData(
      barBackgroundColor: CupertinoColors.black,
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.activeBlue,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: CupertinoColors.black,
      textTheme: _textTheme);

  CupertinoThemeData getAppThemeData(
      BuildContext context, bool isDarkModeEnabled) {
    if (isDarkModeEnabled) {
      return _kDarkTheme;
    } else if (!isDarkModeEnabled) {
      return _kLightTheme;
    } else {
      return _kLightTheme;
    }
  }
}

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final colorsProvider = Provider<Colors>((ref) {
  final dark = ref.watch(darkMode);
  return Colors(dark);
});

class Colors {
  Colors(this.darkMode);
  bool darkMode;

  Color returnColor(Color light, Color dark) {
    if (darkMode) {
      return dark;
    } else {
      return light;
    }
  }

  Color get messageBubble => returnColor(Color(0xFFdbdbdb), Color(0xFF292929));
  Color get nonColors => returnColor(Color(0xFFFFFFFF), Color(0xFF000000));
  Color get messageInput =>
      returnColor(Color(0xFFFFFFFF), CupertinoColors.darkBackgroundGray);
  Color get tabBarColor =>
      returnColor(CupertinoColors.white, CupertinoColors.darkBackgroundGray);
  Color get spinnerColor => returnColor(Color(0xFFD2D2D2), Color(0xFF363636));
  Color get contrast => returnColor(Color(0xFF000000), Color(0xFFFFFFFF));
}
