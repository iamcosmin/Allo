export 'alerts_repository.dart';
export 'chats_repository.dart';
export 'error_codes.dart';
export 'theme_repository.dart';

import 'package:allo/repositories/alerts_repository.dart';
import 'package:allo/repositories/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_codes.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class Repositories {
  static final Provider<AlertsRepository> alerts = alertsProvider;
  static const errorCodes = ErrorCodes;
  static final Provider<AppTheme> theme = appThemeProvider;
  static final Provider<SharedPreferences> sharedPreferences =
      sharedPreferencesProvider;
  static final Provider<ColorsBuilt> colors = colorsProvider;
}
