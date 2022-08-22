import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../components/setup_page.dart';

class EmailNotVerifiedPage extends HookConsumerWidget {
  const EmailNotVerifiedPage({
    required this.nextRoute,
    super.key,
  });
  final Widget nextRoute;

  @override
  Widget build(context, ref) {
    Future<void> onSubmit() async {
      await FirebaseAuth.instance.currentUser?.reload();
      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (verified) {
        Navigation.forward(nextRoute);
      } else {
        Core.stub.showInfoBar(
          icon: Icons.info,
          text:
              '''It seems like you have not verified your email. Please try again. 
              \nHaven't received an email? Try checking the spam folder.''',
        );
      }
    }

    useEffect(
      () {
        FirebaseAuth.instance.currentUser?.sendEmailVerification();
        return;
      },
      const [],
    );

    return SetupPage(
      icon: Icons.verified_user_rounded,
      title: const Text('Verify your Email'),
      subtitle: const Text(
        'We have sent you an email. Access the link, then come back and click continue.',
      ),
      actions: SetupActions(
        actions: [
          SetupAction(label: context.locale.setupNext, onTap: onSubmit),
          SetupAction(
            label: 'Log off',
            onTap: () async => await Core.auth.signOut(context, ref),
            fill: ActionFill.empty,
          )
        ],
      ),
      action: () {},
    );
  }
}
