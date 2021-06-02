import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//? <Preferences>

final darkMode = StateNotifierProvider<PreferenceManager, bool>((ref) {
  final parameter = 'isDarkModeEnabled';
  final returnValue =
      ref.read(updatedSharedUtilityProvider).returnBool(parameter);
  return PreferenceManager(returnValue, parameter);
});

final experimentalMessageOptions =
    StateNotifierProvider<PreferenceManager, bool>((ref) {
  final parameter = 'experimentalMessageOptions';
  final returnValue =
      ref.read(updatedSharedUtilityProvider).returnBool(parameter);
  return PreferenceManager(returnValue, parameter);
});

final newComposeMessage = StateNotifierProvider<PreferenceManager, bool>((ref) {
  final parameter = 'newComposeEnabled';
  final returnValue =
      ref.read(updatedSharedUtilityProvider).returnBool(parameter);
  return PreferenceManager(returnValue, parameter);
});

final experimentalProfilePicture =
    StateNotifierProvider<PreferenceManager, bool>((ref) {
  final parameter = 'experimentalProfilePicture';
  final returnValue =
      ref.read(updatedSharedUtilityProvider).returnBool(parameter);
  return PreferenceManager(returnValue, parameter);
});

//? </Preferences>

final updatedSharedUtilityProvider = Provider<UpdatedSharedUtility>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return UpdatedSharedUtility(sharedPreferences: sharedPreferences);
});

class UpdatedSharedUtility {
  UpdatedSharedUtility({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  String returnString(String parameter) {
    return sharedPreferences.getString(parameter) ?? 'Parameter is undefined.';
  }

  bool returnBool(String parameter) {
    return sharedPreferences.getBool(parameter) ?? false;
  }

  Future setString(String parameter, String setter) async {
    return await sharedPreferences.setString(parameter, setter);
  }

  Future setBool(String parameter, bool setter) async {
    return await sharedPreferences.setBool(parameter, setter);
  }
}

class PreferenceManager extends StateNotifier<bool> {
  PreferenceManager(this.setter, this.parameter) : super(setter);
  final bool setter;
  final String parameter;
  void _readAndUpdateState(BuildContext context, bool boolean) {
    context
        .read(updatedSharedUtilityProvider)
        .setBool(parameter, boolean)
        .whenComplete(() => {state = boolean});
  }

  @Deprecated('Please use the switcher for less boilerplate.')
  void setTrue(BuildContext context) {
    context
        .read(updatedSharedUtilityProvider)
        .setBool(parameter, true)
        .whenComplete(() => {state = true});
  }

  @Deprecated('Please use the switcher for less boilerplate.')
  void setFalse(BuildContext context) {
    context
        .read(updatedSharedUtilityProvider)
        .setBool('isDarkModeEnabled', false)
        .whenComplete(() => {state = false});
  }

  void switcher(BuildContext context) {
    if (state) {
      _readAndUpdateState(context, false);
    } else {
      _readAndUpdateState(context, true);
    }
  }
}
