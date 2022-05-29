import 'package:allo/components/setup_page.dart';
import 'package:allo/interface/login/new/setup_pfp.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const _kDebugBypassVerification = kDebugMode ? true : false;

class SetupVerification extends HookWidget {
  const SetupVerification({super.key});
  @override
  Widget build(BuildContext context) {
    useEffect(() {
      Future.microtask(
        () async =>
            await FirebaseAuth.instance.currentUser!.sendEmailVerification(),
      );
      return;
    });
    return SetupPage(
      icon: Icons.email,
      title: Text(context.locale.setupVerificationScreenTitle),
      subtitle: Text(context.locale.setupVerificationScreenDescription),
      action: () async {
        await FirebaseAuth.instance.currentUser?.reload();
        final verified = FirebaseAuth.instance.currentUser!.emailVerified;
        if (verified || _kDebugBypassVerification) {
          Core.navigation.push(route: const SetupProfilePicture());
        } else {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(context.locale.error),
              content: Text(context.locale.errorVerificationLinkNotAccessed),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
