import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AccountInfo extends HookWidget {
  const AccountInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final username = useState('');
    useEffect(() {
      Future.microtask(() async {
        username.value = await Core.auth.user.username;
      });
    }, const []);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informații despre cont'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'Nume: ' + Core.auth.user.name,
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            SelectableText(
              'Inițiale: ' + Core.auth.user.nameInitials,
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            SelectableText(
              'Identificator: ' + Core.auth.user.uid,
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            SelectableText(
              'Nume de utilizator: ' + username.value,
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            SelectableText(
              'Link poza profil: ' +
                  (Core.auth.user.profilePicture ?? 'Nu ai poză de profil'),
              style: const TextStyle(fontSize: 17),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
          ],
        ),
      ),
    );
  }
}
