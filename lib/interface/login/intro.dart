import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../components/material3/filled_button.dart';
import '../../components/setup_view.dart';
import 'login.dart';

class IntroPage extends HookWidget {
  const IntroPage({super.key});
  @override
  Widget build(context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 200,
                      width: 200,
                      child: Image(
                        image: AssetImage('assets/images/Icon-512.png'),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 50)),
                    Text(
                      context.locale.setupWelcomeScreenTitle,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: setupButtonTheme.merge(filledButtonStyle(context)),
                      onPressed: () => Navigation.forward(const LoginPage()),
                      icon: const Icon(Icons.navigate_next_rounded),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
