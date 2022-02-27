import 'manager.dart';

final darkMode = preference('isDarkModeEnabled');
final privateConversations = preference('privateConversations');
final reactionsDebug = preference('alloReactionsDebug');
final repliesDebug = preference('global_replies', online: true);
final editMessageDebug = preference('alloEditMessageDebug');
final membersDebug = preference('alloParticipantsDebug');
final emulateIOSBehaviour = preference('experimentalEmulateIOSBehaviour');
