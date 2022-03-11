import 'manager.dart';

final darkMode = createPreference('isDarkModeEnabled', false);
final privateConversations = createPreference('privateConversations', false);
final reactionsDebug = createPreference('alloReactionsDebug', false);
final editMessageDebug = createPreference('alloEditMessageDebug', false);
final membersDebug = createPreference('alloParticipantsDebug', false);
final emulateIOSBehaviour =
    createPreference('experimentalEmulateIOSBehaviour', false);
