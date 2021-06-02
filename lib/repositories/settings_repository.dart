import 'package:hooks_riverpod/hooks_riverpod.dart';

final setttingsProvider =
    Provider<SettingsRepository>((ref) => SettingsRepository());

class SettingsRepository {}
