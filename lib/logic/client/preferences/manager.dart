import 'package:allo/generated/l10n.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core.dart';

final sharedPreferencesProvider = runtimeProvider<SharedPreferences>();
final androidSdkVersionProvider = runtimeProvider<AndroidBuildVersion>();
final dynamicColorsProvider = runtimeProvider<CorePalette?>();

Provider<T> runtimeProvider<T>() {
  return Provider<T>(
    (ref) => throw UnimplementedError(
      'This needs to be instantiated in the main method of the app.',
    ),
  );
}

StateNotifierProvider<PreferenceManager<T>, T> createPreference<T>(
  String key,
  T implicitValue, {
  bool? online,
}) {
  return StateNotifierProvider<PreferenceManager<T>, T>(
    (ref) {
      final preferences = ref.read(preferencesProvider);
      final localValue = preferences.get<T>(key);
      return PreferenceManager<T>(
        key: key,
        ref: ref,
        online: online,
        firstValue: localValue,
        implicitValue: implicitValue,
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
  T? get<T>(String key) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _ = sharedPreferences.get(key);
    if (_ is T?) {
      return _;
    } else {
      throw Exception('The key specified does not return the required type.');
    }
  }

  /// This is a helper method for setting a value and assigning automatically
  /// the value type in storage.
  void set(String key, value) async {
    if (value is String) {
      await sharedPreferences.setString(key, value);
    } else if (value is bool) {
      await sharedPreferences.setBool(key, value);
    } else if (value is double) {
      await sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      await sharedPreferences.setInt(key, value);
    } else if (value is List<String>) {
      await sharedPreferences.setStringList(key, value);
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
      for (final key in keys) {
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
  // ignore: avoid_positional_boolean_parameters
  Future setBool(String parameter, bool setter) async =>
      await sharedPreferences.setBool(parameter, setter);
}

T _getRemoteValue<T>(String key) {
  final rConfig = FirebaseRemoteConfig.instance;
  if (T is String) {
    return rConfig.getString(key) as T;
  } else if (T is bool) {
    return rConfig.getBool(key) as T;
  } else if (T is int) {
    return rConfig.getInt(key) as T;
  } else if (T is double) {
    return rConfig.getDouble(key) as T;
  } else {
    throw Exception(
      'The type specified cannot be returned from online source FirebaseRemoteConfig.',
    );
  }
}

class PreferenceManager<T> extends StateNotifier<T> {
  PreferenceManager({
    required this.key,
    required T? firstValue,
    required this.implicitValue,
    required this.ref,
    this.online,
  }) : super(
          online == true
              ? firstValue ?? _getRemoteValue<T>(key)
              : firstValue ?? implicitValue,
        );
  final String key;
  final Ref ref;
  final T implicitValue;
  final bool? online;

  Preferences get _preferences => ref.read(preferencesProvider);

  void _readAndUpdateState(T value) {
    _preferences.set(key, value);
    state = value;
  }

  void changeValue(T value) {
    _readAndUpdateState(value);
  }

  void cleanPreference(
    @Deprecated('No need for context anymore.') BuildContext context,
  ) {
    _preferences.remove(key);
    if (online == true) {
      _readAndUpdateState(_getRemoteValue<T>(key));
    } else {
      _readAndUpdateState(implicitValue);
    }
    Core.stub.showInfoBar(
      icon: Icons.info,
      text: S.of(context).preferenceCleared,
    );
  }
}
