import 'package:allo/repositories/preferences_repository.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final secretEntryProvider =
    StateNotifierProvider<SecretSettingsEntry, int>((ref) {
  return SecretSettingsEntry();
});

class SecretSettingsEntry extends StateNotifier<int> {
  SecretSettingsEntry() : super(0);

  void increment() => state++;
  void reset() => state = 0;
}

class SecretSettings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dark = useProvider(darkMode);
    final darkMethod = useProvider(darkMode.notifier);
    final eMessageOpt = useProvider(experimentalMessageOptions);
    final eMessageOptMethod = useProvider(experimentalMessageOptions.notifier);
    final eProfilePic = useProvider(experimentalProfilePicture);
    final eProfilePicMethod = useProvider(experimentalProfilePicture.notifier);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Opțiuni experimentale'),
        previousPageTitle: 'Setări',
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
              sliver: SliverList(
            delegate: SliverChildListDelegate([
              Padding(padding: EdgeInsets.only(top: 30)),
              CupertinoFormSection.insetGrouped(
                  header: Text(
                      'Aceste opțiuni sunt experimentale și sunt gândite doar pentru testarea internă. Vă rugăm să nu folosiți aceste setări dacă nu știți ce fac.'),
                  children: [
                    CupertinoFormRow(
                      prefix: Text('Mod Întunecat'),
                      child: CupertinoSwitch(
                          value: dark,
                          onChanged: (value) => darkMethod.switcher(context)),
                    ),
                    CupertinoFormRow(
                      prefix: Text('Opțiuni pentru mesajele primite'),
                      child: CupertinoSwitch(
                        value: eMessageOpt,
                        onChanged: (value) =>
                            eMessageOptMethod.switcher(context),
                      ),
                    ),
                    CupertinoFormRow(
                        prefix: Text('Încarcă fotografie de profil'),
                        child: CupertinoSwitch(
                          value: eProfilePic,
                          onChanged: (value) =>
                              eProfilePicMethod.switcher(context),
                        ))
                  ]),
            ]),
          ))
        ],
      ),
    );
  }
}
