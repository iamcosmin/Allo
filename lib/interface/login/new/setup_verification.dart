import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/new/setup_pfp.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:allo/components/oobe_page.dart';

class SetupVerification extends HookWidget {
  const SetupVerification({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    final error = useState('');

    useEffect(() {
      Future.microtask(() async =>
          await FirebaseAuth.instance.currentUser!.sendEmailVerification());
    });
    return SetupPage(
        header: [
          Text(
            locales.setupVerificationScreenTitle,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: Text(
              locales.setupVerificationScreenDescription,
              style: const TextStyle(fontSize: 17, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: Text(
              error.value,
              style: const TextStyle(fontSize: 17, color: Colors.red),
              textAlign: TextAlign.left,
            ),
          )
        ],
        body: const [],
        onButtonPress: () async {
          await FirebaseAuth.instance.currentUser?.reload();
          final verified = FirebaseAuth.instance.currentUser!.emailVerified;
          if (verified) {
            await Core.navigation.push(
              context: context,
              route: const SetupProfilePicture(),
            );
          } else {
            error.value = locales.errorVerificationLinkNotAccessed;
          }
        },
        isAsync: true);
  }
}
