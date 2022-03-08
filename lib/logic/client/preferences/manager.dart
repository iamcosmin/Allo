import 'package:allo/generated/l10n.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'This needs to be instantiated in the main method of the app.',
  ),
);

final deviceInfoProvider = Provider<AndroidDeviceInfo>(
  (ref) => throw UnimplementedError(
    'This needs to be instantiated in the main method of the app.',
  ),
);

StateNotifierProvider<PreferenceManager, bool> preference(
  String preference, {
  bool? online,
}) {
  return StateNotifierProvider<PreferenceManager, bool>(
    (ref) {
      final localValue = ref.read(preferencesProvider).get(preference);
      return PreferenceManager(
        preference: preference,
        localValue: localValue,
        ref: ref,
        online: online,
      );
    },
  );
}

final preferencesProvider = Provider<Preferences>(
  (ref) {
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    return Preferences(sharedPreferences: sharedPreferences);
  },
);

class Preferences {
  Preferences({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  /// This is a helper method for getting a value stored on the device,
  /// without specifying a exact function of [SharedPreferences].
  dynamic get(String key) {
    return sharedPreferences.get(key);
  }

  /// This is a helper method for setting a value and assigning automatically
  /// the value type in storage.
  void set(String key, dynamic value) async {
    if (value is String) {
      sharedPreferences.setString(key, value);
    } else if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    } else if (value is List<String>) {
      sharedPreferences.setStringList(key, value);
    } else {
      throw Exception('The type specified is not compatible with this module.');
    }
  }

  /// Removes a key from storage.
  void remove(String key) => sharedPreferences.remove(key);

  /// Removes all keys from storage.
  /// If a exception is needed, please put the key in the exception list.
  void removeAll({List<String>? exception}) {
    if (exception != null) {
      final keys = sharedPreferences.getKeys();
      for (var key in keys) {
        if (!exception.contains(key)) {
          sharedPreferences.remove(key);
        }
      }
    }
  }

  @Deprecated('Please use the simple get method for compatibility.')
  String getString(String preference) =>
      sharedPreferences.getString(preference) ?? 'Empty';
  @Deprecated('Please use the simple get method for compatibility.')
  bool? getBool(String preference) => sharedPreferences.getBool(preference);
  @Deprecated('Please use the simple set method for compatibility.')
  Future setString(String parameter, String setter) async =>
      await sharedPreferences.setString(parameter, setter);
  @Deprecated('Please use the simple set method for compatibility.')
  Future setBool(String parameter, bool setter) async =>
      await sharedPreferences.setBool(parameter, setter);
}

// TODO: Make PreferenceManager dynamic.
class PreferenceManager extends StateNotifier<bool> {
  PreferenceManager(
      {required this.preference,
      required this.localValue,
      required this.ref,
      this.online})
      : super(
          online == true
              ? localValue ?? FirebaseRemoteConfig.instance.getBool(preference)
              : localValue ?? false,
        );
  final String preference;
  final bool? localValue;
  final Ref ref;
  final bool? online;

  void _readAndUpdateState(bool value) {
    ref.read(preferencesProvider).set(preference, value);
    state = value;
  }

  void switcher() {
    if (state) {
      _readAndUpdateState(false);
    } else {
      _readAndUpdateState(true);
    }
  }

  void cleanPreference(BuildContext context) {
    ref.read(preferencesProvider).remove(preference);
    if (online == true) {
      _readAndUpdateState(FirebaseRemoteConfig.instance.getBool(preference));
    } else {
      _readAndUpdateState(false);
    }
    Core.stub.showInfoBar(
      context: context,
      icon: Icons.info,
      text: S.of(context).preferenceCleared,
    );
  }
}
