import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../components/slivers/sliver_scaffold.dart';
import '../../../../components/slivers/top_app_bar.dart';

class AccountInfo extends HookWidget {
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final username = useState('');
    final locales = S.of(context);
    useEffect(
      () {
        Future.microtask(() async {
          username.value = await Core.auth.user.username;
        });
        return;
      },
      const [],
    );
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(locales.internalAccountInfo),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              SelectableText(
                '${locales.name}: ${Core.auth.user.name}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SelectableText(
                '${locales.initials}: ${Core.auth.user.nameInitials}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SelectableText(
                '${locales.uid}: ${Core.auth.user.uid}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SelectableText(
                '${locales.username}: ${username.value}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SelectableText(
                '${locales.profilePicture} ${Core.auth.user.profilePicture ?? locales.noProfilePicture}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
            ]),
          ),
        )
      ],
    );
  }
}
