import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//? <Preferences>

final darkMode = StateNotifierProvider<PreferenceManager, bool>((ref) {
  const parameter = 'isDarkModeEnabled';
  final returnValue = ref.read(preferencesProvider).getBool(parameter);
  return PreferenceManager(returnValue, parameter);
});

final experimentalMessageOptions =
    StateNotifierProvider<PreferenceManager, bool>((ref) {
  const parameter = 'experimentalMessageOptions';
  final returnValue = ref.read(preferencesProvider).getBool(parameter);
  return PreferenceManager(returnValue, parameter);
});

final experimentalProfilePicture =
    StateNotifierProvider<PreferenceManager, bool>((ref) {
  const parameter = 'experimentalProfilePicture';
  final returnValue = ref.read(preferencesProvider).getBool(parameter);
  return PreferenceManager(returnValue, parameter);
});

//? </Preferences>

final preferencesProvider = Provider<Preferences>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return Preferences(sharedPreferences: sharedPreferences);
});

class Preferences {
  Preferences({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  String getString(String preference) =>
      sharedPreferences.getString(preference) ?? 'Empty';

  bool getBool(String preference) =>
      sharedPreferences.getBool(preference) ?? false;

  Future setString(String parameter, String setter) async =>
      await sharedPreferences.setString(parameter, setter);

  Future setBool(String parameter, bool setter) async =>
      await sharedPreferences.setBool(parameter, setter);
}

class PreferenceManager extends StateNotifier<bool> {
  PreferenceManager(this.setter, this.parameter) : super(setter);
  final bool setter;
  final String parameter;
  void _readAndUpdateState(BuildContext context, bool boolean) {
    context
        .read(preferencesProvider)
        .setBool(parameter, boolean)
        .whenComplete(() => {state = boolean});
  }

  void switcher(BuildContext context) {
    if (state) {
      _readAndUpdateState(context, false);
    } else {
      _readAndUpdateState(context, true);
    }
  }
}
