import 'dart:io';

import 'package:allo/components/space.dart';
import 'package:allo/logic/backend/authentication/authentication.dart';
import 'package:allo/logic/backend/chat/chat.dart';
import 'package:allo/logic/backend/general/general.dart';
import 'package:allo/logic/client/navigation.dart';
import 'package:allo/logic/client/notifications.dart';
import 'package:allo/logic/client/validators.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend/chat/chats.dart';
import 'client/preferences/manager.dart';

export 'backend/database.dart';
export 'client/extensions.dart';
export 'client/navigation.dart';

// TODO: Migrate some of the items from Core to their own things.
class Core {
  static const Authentication auth = Authentication();
  static final Navigation navigation = Navigation();
  static Validators validators(BuildContext context) => Validators(context);
  static const Notifications notifications = Notifications();
  static final General general = General();
  static const ChatsLogic chats = ChatsLogic();
  // TODO(iamcosmin): Move this in ChatsLogic
  static Chats chat(chatId) => Chats(chatId: chatId);
  static final Stub stub = Stub();

  static Future<List<Override>> getOverrides() async {
    return [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),

      // These providers are specifically designed to be run on Android.
      // Please keep them that way.
      if (!kIsWeb && Platform.isAndroid) ...[
        androidSdkVersionProvider.overrideWithValue(
          (await DeviceInfoPlugin().androidInfo).version,
        ),
        dynamicColorsProvider.overrideWithValue(
          await DynamicColorPlugin.getCorePalette(),
        )
      ]
    ];
  }
}

class Keys {
  const Keys();
  @Deprecated(
    'These API keys are deprecated. Please use DefaultFirebaseOptions.currentPlatform.',
  )
  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyAyLt2_FAHc0I2c1iBLH_MxWzo2kllSvA8",
    authDomain: "allo-ms.firebaseapp.com",
    projectId: "allo-ms",
    storageBucket: "allo-ms.appspot.com",
    messagingSenderId: "1049075385887",
    appId: "1:1049075385887:web:89f4887e574f8b93f2372a",
    measurementId: "G-N5D9CRB413",
  );
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

class DialogBuilder {
  final IconData icon;
  final String title;
  final Widget? body;
  final List<ButtonStyleButton> actions;

  const DialogBuilder({
    required this.icon,
    required this.title,
    required this.actions,
    this.body,
  });
}

class Stub {
  void showInfoBar({
    required IconData icon,
    required String text,
    @Deprecated('This function does not require context anymore, as it relies on ScaffoldMessengerState key.')
        BuildContext? context,
  }) {
    final key = Keys.scaffoldMessengerKey.currentState;
    if (key != null) {
      key
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(icon),
                const Padding(padding: EdgeInsets.only(left: 20)),
                Text(text),
              ],
            ),
          ),
        );
    } else {
      throw Exception('The scaffoldMessengerKey is null.');
    }
  }

  void alert({
    required BuildContext context,
    required DialogBuilder dialogBuilder,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showPlatformDialog(
      context: context,
      builder: (context) => AlertDialog(
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: colorScheme.surface,
        title: Column(
          children: [
            Icon(
              dialogBuilder.icon,
              color: colorScheme.error,
            ),
            const Space(1),
            Text(
              dialogBuilder.title,
              style: TextStyle(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: DefaultTextStyle(
          style: TextStyle(color: colorScheme.onSurface),
          textAlign: TextAlign.center,
          child: dialogBuilder.body ?? Container(),
        ),
        actions: dialogBuilder.actions,
      ),
    );
  }
}

/// [useMemoizedFuture()]

/// Stores an [AsyncSnapshot] as well as a reference to a function [refresh]
/// that should re-call the future that was used to generate the [snapshot].
class MemoizedAsyncSnapshot<T> {
  final AsyncSnapshot<T> snapshot;
  final Function() refresh;

  const MemoizedAsyncSnapshot(this.snapshot, this.refresh);
}

/// Subscribes to a [Future] and returns its current state in a
/// [MemoizedAsyncSnapshot].
/// The [future] is memoized and will only be re-called if any of the [keys]
/// change or if [MemoizedAsyncSnapshot.refresh] is called.
///
/// * [initialData] specifies what initial value the [AsyncSnapshot] should
///   have.
/// * [preserveState] defines if the current value should be preserved when
///   changing the [Future] instance.
///
/// See also:
///   * [useFuture], the hook responsible for getting the future.
///   * [useMemoized], the hook responsible for the memoization.
MemoizedAsyncSnapshot<T> useMemoizedFuture<T>(
  Future<T> Function() future, {
  List<Object> keys = const <Object>[],
  T? initialData,
  bool preserveState = true,
}) {
  final refresh = useState(0);
  final result = useFuture(
    useMemoized(future, [refresh.value, ...keys]),
    initialData: initialData,
    preserveState: preserveState,
  );

  void refreshMe() => refresh.value++;

  return MemoizedAsyncSnapshot<T>(result, refreshMe);
}
