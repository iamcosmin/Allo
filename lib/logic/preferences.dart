import 'package:allo/logic/theme.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core.dart';

//? <Preferences>

final darkMode = preference('isDarkModeEnabled');
final privateConversations = preference('privateConversations');
final reactionsDebug = preference('alloReactionsDebug');
final editMessageDebug = preference('alloEditMessageDebug');
final membersDebug = preference('alloParticipantsDebug');
final emulateIOSBehaviour = preference('experimentalEmulateIOSBehaviour');

//? </Preferences>

StateNotifierProvider<PreferenceManager, bool> preference(String parameter,
    {bool? online}) {
  return StateNotifierProvider<PreferenceManager, bool>((ref) {
    final returnValue = ref.read(preferencesProvider).getBool(parameter);
    return PreferenceManager(returnValue, parameter, online: online);
  });
}

final preferencesProvider = Provider<Preferences>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return Preferences(sharedPreferences: sharedPreferences);
});

class Preferences {
  Preferences({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  String getString(String preference) =>
      sharedPreferences.getString(preference) ?? 'Empty';

  bool? getBool(String preference) => sharedPreferences.getBool(preference);

  Future setString(String parameter, String setter) async =>
      await sharedPreferences.setString(parameter, setter);

  Future setBool(String parameter, bool setter) async =>
      await sharedPreferences.setBool(parameter, setter);

  Future remove(String parameter) async =>
      await sharedPreferences.remove(parameter);
}

class PreferenceManager extends StateNotifier<bool> {
  PreferenceManager(this.setter, this.parameter, {this.online})
      : super(online == true
            ? setter ?? FirebaseRemoteConfig.instance.getBool(parameter)
            : setter ?? false);
  final bool? setter;
  final String parameter;
  final bool? online;

  void _readAndUpdateState(WidgetRef ref, bool boolean) {
    ref
        .read(preferencesProvider)
        .setBool(parameter, boolean)
        .whenComplete(() => {state = boolean});
  }

  void switcher(WidgetRef ref, BuildContext context) {
    if (state) {
      _readAndUpdateState(ref, false);
    } else {
      _readAndUpdateState(ref, true);
    }
  }

  void cleanPreference(WidgetRef ref, BuildContext context) {
    ref.read(preferencesProvider).remove(parameter);
    if (online == true) {
      _readAndUpdateState(
          ref, FirebaseRemoteConfig.instance.getBool(parameter));
    } else {
      _readAndUpdateState(ref, false);
    }
    Core.stub.showInfoBar(
        context: context, icon: Icons.info, text: 'Preference cleared.');
  }
}
