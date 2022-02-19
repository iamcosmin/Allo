import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/profile_picture.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AccountSettings extends HookWidget {
  const AccountSettings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    final firstNameError = useState('');
    final secondNameError = useState('');
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    final nameReg = RegExp(r'^[a-zA-Z]+$');
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.account),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              locales.name,
              style: const TextStyle(fontSize: 18),
            ),
            minLeadingWidth: 20,
            onTap: () {
              showPlatformDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    locales.changeName,
                    textAlign: TextAlign.center,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(locales.changeNameDescription),
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      TextFormField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          errorText: firstNameError.value == ''
                              ? null
                              : firstNameError.value,
                          errorStyle: const TextStyle(fontSize: 14),
                          labelText: locales.firstName,
                          border: const OutlineInputBorder(),
                        ),
                        controller: firstNameController,
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 10)),
                      TextFormField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          errorText: secondNameError.value == ''
                              ? null
                              : secondNameError.value,
                          errorStyle: const TextStyle(fontSize: 14),
                          labelText: locales.lastName +
                              ' (${locales.optional.toLowerCase()})',
                          border: const OutlineInputBorder(),
                        ),
                        controller: secondNameController,
                      ),
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  alignment: Alignment.center,
                  actionsPadding: EdgeInsets.only(left: 20, right: 20),
                  actions: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          firstNameError.value = '';
                          secondNameError.value = '';
                          if (firstNameController.text != '') {
                            if (nameReg.hasMatch(firstNameController.text)) {
                              if (secondNameController.text != '') {
                                if (nameReg
                                    .hasMatch(secondNameController.text)) {
                                  FirebaseAuth.instance.currentUser
                                      ?.updateDisplayName(
                                    firstNameController.text +
                                        ' ' +
                                        secondNameController.text,
                                  );
                                  Navigator.of(context).pop();
                                } else {
                                  secondNameError.value =
                                      locales.specialCharactersNotAllowed;
                                }
                              } else {
                                FirebaseAuth.instance.currentUser
                                    ?.updateDisplayName(
                                        firstNameController.text);
                                Navigator.of(context).pop();
                              }
                            } else {
                              firstNameError.value =
                                  locales.specialCharactersNotAllowed;
                            }
                          } else {
                            firstNameError.value = locales.errorFieldEmpty;
                          }
                        },
                        child: Text(locales.change),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(locales.cancel),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              locales.username,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ListTile(
            title: Text(
              locales.profilePicture,
              style: const TextStyle(fontSize: 18),
            ),
            onTap: () => Core.navigation
                .push(context: context, route: ProfilePictureSettings()),
          )
        ],
      ),
    );
  }
}
