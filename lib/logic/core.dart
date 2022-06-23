import 'dart:io';

import 'package:allo/components/space.dart';
import 'package:allo/logic/backend/authentication/authentication.dart';
import 'package:allo/logic/backend/chat/chat.dart';
import 'package:allo/logic/backend/general/general.dart';
import 'package:allo/logic/client/extensions.dart';
import 'package:allo/logic/client/validators.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend/chat/chats.dart';
import 'client/preferences/manager.dart';

export 'backend/database.dart';
export 'client/extensions.dart';
export 'client/navigation.dart';
export 'client/notifications.dart';

// TODO: Migrate some of the items from Core to their own things.
class Core {
  static Authentication auth = Authentication();
  static Validators validators(BuildContext context) => Validators(context);
  static final General general = General();
  static ChatsLogic chats = ChatsLogic();
  // TODO(iamcosmin): Move this in ChatsLogic
  static Chats chat(chatId) => Chats(chatId: chatId);
  static final Stub stub = Stub();
}

class Keys {
  const Keys();
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
    bool selectableText = false,
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
                if (selectableText) SelectableText(text) else Text(text),
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
    showDialog(
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

  void error(BuildContext context, String error) {
    alert(
      context: context,
      dialogBuilder: DialogBuilder(
        icon: Icons.error,
        title: context.locale.error,
        body: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
