import 'package:allo/components/setup_page.dart';
import 'package:allo/interface/login/new/setup_pfp.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const _kDebugBypassVerification = kDebugMode ? true : false;

class SetupVerification extends HookWidget {
  const SetupVerification({
    super.key,
  });
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
      title: Text(context.loc.setupVerificationScreenTitle),
      subtitle: Text(context.loc.setupVerificationScreenDescription),
      action: () async {
        await FirebaseAuth.instance.currentUser?.reload();
        final verified = FirebaseAuth.instance.currentUser!.emailVerified;
        if (verified || _kDebugBypassVerification) {
          /* TODO: Theoretically, this will not be executed, as the app will automatically redirect the user to the chats
          screen if the app detects that the email has been verified.*/

          // Awaiting test result for deleting supplimentary configuration.
          // Another option would be making some banners into the chats screen recommending the user to add a profile picture, etc.
          Navigation.forward(const SetupProfilePicture());
        } else {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(context.loc.error),
              content: Text(context.loc.errorVerificationLinkNotAccessed),
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
