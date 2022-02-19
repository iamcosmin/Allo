import 'package:allo/logic/authentication.dart';
import 'package:allo/logic/chat/chat.dart';
import 'package:allo/logic/navigation.dart';
import 'package:allo/logic/notifications.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Core {
  static final Authentication auth = Authentication();
  static final Navigation navigation = Navigation();
  static final Notifications notifications = Notifications();
  static Chats chat(chatId) => Chats(chatId: chatId);
  static final Stub stub = Stub();
}

class Stub {
  void showInfoBar({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(icon),
            const Padding(padding: EdgeInsets.only(left: 20)),
            Text(text),
          ],
        ),
        dismissDirection: DismissDirection.vertical,
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

class Preference {
  const Preference(this.preference, this.switcher, this.clear);
  final bool preference;
  final void Function(WidgetRef, BuildContext) switcher;
  final void Function(WidgetRef, BuildContext) clear;
}

Preference usePreference(
  WidgetRef ref,
  StateNotifierProvider<PreferenceManager, bool> provider,
) {
  return Preference(
    ref.watch(provider),
    ref.watch(provider.notifier).switcher,
    ref.watch(provider.notifier).cleanPreference,
  );
}
