import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/new/setup_pfp.dart';
import 'package:allo/logic/client/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:allo/components/oobe_page.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SetupVerification extends HookWidget {
  const SetupVerification({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);

    useEffect(() {
      Future.microtask(() async =>
          await FirebaseAuth.instance.currentUser!.sendEmailVerification());
      return;
    });
    return SetupPage(
      icon: Icons.email,
      title: context.locale.setupVerificationScreenTitle,
      subtitle: context.locale.setupVerificationScreenDescription,
      body: const [],
      action: () async {
        await FirebaseAuth.instance.currentUser?.reload();
        final verified = FirebaseAuth.instance.currentUser!.emailVerified;
        if (verified) {
          return true;
        } else {
          showPlatformDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(context.locale.error),
              content: Text(locales.errorVerificationLinkNotAccessed),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return false;
        }
      },
      nextRoute: const SetupProfilePicture(),
    );
  }
}
