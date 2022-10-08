import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../components/slivers/sliver_scaffold.dart';
import '../../../../components/slivers/top_app_bar.dart';

class AccountInfo extends HookWidget {
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final username = useFuture(Core.auth.user.getUsername());
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.loc.internalAccountInfo),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              SelectableText(
                '${context.loc.name}: ${Core.auth.user.name}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SelectableText(
                '${context.loc.initials}: ${Core.auth.user.nameInitials}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SelectableText(
                '${context.loc.uid}: ${Core.auth.user.userId}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SelectableText(
                '${context.loc.username}: ${username.data}',
                style: const TextStyle(fontSize: 17),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SelectableText(
                '${context.loc.profilePicture} ${Core.auth.user.profilePictureUrl ?? context.loc.noProfilePicture}',
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
