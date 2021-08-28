import 'package:allo/components/appbar.dart';
import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/home/typingbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class C extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(
        title: Text('Opțiuni experimentale'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SettingsListHeader(
              'Aceste opțiuni sunt experimentale și sunt gândite doar pentru testarea internă. Vă rugăm să nu folosiți aceste setări dacă nu știți ce fac.'),
          SettingsListTile(
            title: 'Typing bubble',
            type: RadiusType.BOTH,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ExampleIsTyping(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
