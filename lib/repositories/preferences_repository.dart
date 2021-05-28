import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final StateProvider dummyParameter = StateProvider((ref) {
  final isActivated = ref.read(sharedUtilityProvider).isParamEnabled('dummy');
  return PreferencesRepository(isActivated, 'dummy');
});

class PreferencesRepository extends StateNotifier<bool> {
  final bool isActivated;
  final String parameter;
  PreferencesRepository(this.isActivated, this.parameter) : super(false);

  void deactivate(BuildContext context, String parameter) {
    context.read(sharedUtilityProvider).disableParam(parameter);
    state = false;
  }

  void activate(BuildContext context, String parameter) {
    context.read(sharedUtilityProvider).enableParam(parameter);
    state = true;
  }
}
