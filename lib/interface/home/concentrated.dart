import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/home/typingbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class C extends HookWidget {
  const C({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opțiuni experimentale'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SettingsListHeader(
              'Aceste opțiuni sunt experimentale și sunt gândite doar pentru testarea internă. Vă rugăm să nu folosiți aceste setări dacă nu știți ce fac.'),
          SettingsListTile(
            title: 'Typing bubble',
            type: RadiusType.BOTH,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ExampleIsTyping(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
