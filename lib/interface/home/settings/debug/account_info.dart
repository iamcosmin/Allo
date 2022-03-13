import 'package:allo/components/appbar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AccountInfo extends HookWidget {
  const AccountInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final username = useState('');
    final locales = S.of(context);
    useEffect(() {
      Future.microtask(() async {
        username.value = await Core.auth.user.username;
      });
      return;
    }, const []);
    return Scaffold(
      appBar: NAppBar(
        title: Text(locales.internalAccountInfo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              '${locales.name}: ' + Core.auth.user.name,
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            SelectableText(
              '${locales.initials}: ' + Core.auth.user.nameInitials,
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            SelectableText(
              '${locales.uid}: ' + Core.auth.user.uid,
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            SelectableText(
              '${locales.username}: ' + username.value,
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            SelectableText(
              '${locales.profilePicture} ' +
                  (Core.auth.user.profilePicture ?? locales.noProfilePicture),
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
          ],
        ),
      ),
    );
  }
}
