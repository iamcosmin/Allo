import 'package:flutter/material.dart';

import 'manager.dart';

final darkMode = initSetting(
  'theme_mode',
  defaultValue: ThemeMode.system.toString(),
);
final privateConversations = initSetting(
  'privateConversations',
  defaultValue: false,
);
final reactionsDebug = initSetting(
  'alloReactionsDebug',
  defaultValue: false,
);
final editMessageDebug = initSetting(
  'alloEditMessageDebug',
  defaultValue: false,
);
final membersDebug = initSetting(
  'alloParticipantsDebug',
  defaultValue: false,
);
final revampedAccountSettingsDebug = initSetting(
  'revamped_account_settings_debug',
  defaultValue: false,
);
final emulateIOSBehaviour = initSetting(
  'experimentalEmulateIOSBehaviour',
  defaultValue: false,
);
