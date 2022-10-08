import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core.dart';

const kCompatibleTypes = <Type>[
  String,
  bool,
  double,
  int,
  List<String>,
];
const kCompatibleServerTypes = <Type>[String, bool, int, double];

final sharedPreferencesProvider = runtimeProvider<SharedPreferences>();
final androidSdkVersionProvider = runtimeProvider<AndroidBuildVersion>();

final corePaletteProvider = FutureProvider<CorePalette?>((ref) {
  return DynamicColorPlugin.getCorePalette();
});

final accentColorProvider = FutureProvider<Color?>((ref) {
  return DynamicColorPlugin.getAccentColor();
});

Provider<T> runtimeProvider<T>() {
  return Provider<T>(
    (ref) => throw UnimplementedError(
      'This needs to be instantiated in the main method of the app.',
    ),
  );
}

final preferencesProvider = Provider<Preferences>(
  (ref) {
    return Preferences(
      sharedPreferences: ref.read(sharedPreferencesProvider),
    );
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
}

/// [getRemoteSetting] fetches the setting using online sources, then returns it based on
/// what type it is.
T? getRemoteSetting<T>(String id) {
  assert(
    kCompatibleServerTypes.contains(T),
    'The type ${T.toString()} is not a type that is compatible with server fetching types (${kCompatibleServerTypes.toString()}). '
    'Please try a compatible type, or provide a method for converting a type to another one.',
  );
  final server = FirebaseRemoteConfig.instance;
  if (T == String) {
    return server.getString(id) as T;
  } else if (T == bool) {
    return server.getBool(id) as T;
  } else if (T == int) {
    return server.getInt(id) as T;
  } else if (T == double) {
    return server.getDouble(id) as T;
  } else {
    return null;
  }
}

Setting<T> useSetting<T>(
  WidgetRef ref,
  StateNotifierProvider<SettingManager<T>, T> provider,
) {
  return Setting(
    ref.watch(provider),
    ref.read(provider.notifier).update,
    ref.read(provider.notifier).delete,
  );
}

class Setting<T> {
  /// [Setting] is returned by [useSetting].
  const Setting(
    this.setting,
    this.update,
    this.delete,
  );

  final T setting;
  final void Function(T value) update;
  final void Function(BuildContext context) delete;
}

// ignore: library_private_types_in_public_api
StateNotifierProvider<SettingManager<T>, T> initSetting<T>(
  String id, {
  required T defaultValue,
  bool fetchFromServer = false,
  // dynamic Function(T incompatibleValue)? toCompatibleValue,
}) {
  return StateNotifierProvider<SettingManager<T>, T>((ref) {
    final currentValue = ref.read(preferencesProvider).get(id);
    return SettingManager(
      id: id,
      currentValue: currentValue,
      defaultValue: defaultValue,
      ref: ref,
      fetchFromServer: fetchFromServer,
      // toCompatibleValue: toCompatibleValue,
    );
  });
}

class SettingManager<T> extends StateNotifier<T> {
  /// [SettingManager] is a data class which you will indirectly use when calling [useSetting].
  /// This class actually manages all the mutations of the state in a setting.
  SettingManager({
    required this.id,
    required this.ref,
    required this.currentValue,
    required this.defaultValue,
    this.fetchFromServer = false,
    // this.toCompatibleValue,
  })  :

        /// Complicated stuff. To ensure toCompatibleValue is not null when T is not contained in
        /// kCompatibleTypes or kCompatibleServerTypes, we need to assert these accordingly.
        assert(
          (fetchFromServer && kCompatibleServerTypes.contains(T)) ||
              (!fetchFromServer && kCompatibleTypes.contains(T)),
          'When using a Setting, you need to make sure that the type you want to make a setting '
          'is compatible with the remote or the local database. Please make sure that you are '
          'using the correct types based on your preferences.',
        ),
        super(
          // Easy logic: first, if you say it should fetch from the server, it will try, but
          // otherwise will fail. If there is a value overriding the server, that value will be used.
          // If there is no value on the server and no current value, the provided defaultValue will
          // be used.
          // Then, not fetching by the server will just return the current value (or if it's null,
          // the default value).
          //
          // I could've made this so it would fetch everytime from the server (as if it is not on
          // the server, it would still return the default value), though that will consume some
          // internet.
          fetchFromServer
              ? currentValue ?? getRemoteSetting(id) ?? defaultValue
              : currentValue ?? defaultValue,
        );

  /// Good old [ref]. We use this to retreive any necessary information from other providers, such
  /// as the protocolar preference manager.
  final Ref ref;

  /// Your friend, [id]. He's the identification data that you will use to identify the setting you
  /// want to display / change.
  final String id;

  /// [currentValue] is, despite of it's name, not the currentValue. It's more of a first-time link,
  /// this will be obsolete if the value changes as the state will continue handling the value.
  /// This is just for setting the state of the class, please do not use it as it is, always use [state].
  final T? currentValue;

  /// This is the value you want the setting to take if there's neither a value stored locally
  /// (for the moment), and neither a value stored on the server. This ensures the setting has
  /// a fallback option.
  final T defaultValue;

  /// [fetchFromServer] asks you if the [SettingManager] should be local or it should be first retreived
  /// from the database. Cleaning the preference locally with this set to [true] will reset to online.
  final bool fetchFromServer;

  // /// [toCompatibleValue] is a very complicated thing to use.
  // /// This would ensure that you are using a compatible type in local storage.
  // /// A use case may be returning a compatible type.
  // final dynamic Function(T incompatibleValue)? toCompatibleValue;

  bool get incompatibleValue =>
      !((fetchFromServer && kCompatibleServerTypes.contains(T)) ||
          (!fetchFromServer && kCompatibleTypes.contains(T)));

  Preferences get _settings => ref.read(preferencesProvider);

  /// Function used internally to trigger both a state change and a local database change.
  void _updateState(T value) {
    // If the value is compatible with the current set of compatible types, just update.
    _settings.set(id, value);
    state = value;
  }

  /// [update] is the method you would want to use if you want to change the value of the setting
  /// in real time (while triggering a app-wide state change).
  void update(T value) => _updateState(value);

  /// [delete] should be used when you want to fallback to the server value or the default value
  /// (in case the user wants the default value the app provided).
  void delete(BuildContext context) {
    _settings.remove(id);
    fetchFromServer
        ? _updateState(getRemoteSetting(id))
        : _updateState(defaultValue);
    Core.stub.showInfoBar(
      icon: Icons.info,
      text: context.loc.preferenceCleared,
    );
  }
}
