export 'auth_repository.dart';
export 'alerts_repository.dart';
export 'chats_repository.dart';
export 'error_codes.dart';
export 'navigation_repository.dart';
export 'theme_repository.dart';

import 'package:allo/repositories/alerts_repository.dart';
import 'package:allo/repositories/chats_repository.dart';
import 'package:allo/repositories/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_repository.dart';
import 'error_codes.dart';
import 'navigation_repository.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class Repositories {
  static final Provider<AlertsRepository> alerts = alertsProvider;
  static final Provider<AuthRepository> auth = authProvider;
  static final Provider<ChatsRepository> chats = chatsProvider;
  static final errorCodes = ErrorCodes;
  static final Provider<NavigationRepository> navigation = navigationProvider;
  static final Provider<AppTheme> theme = appThemeProvider;
  static final Provider<SharedPreferences> sharedPreferences =
      sharedPreferencesProvider;
  static final Provider<SharedUtility> sharedUtility = sharedUtilityProvider;
  static final StateNotifierProvider<AppThemeNotifier, bool> themeState =
      appThemeStateProvider;
}
