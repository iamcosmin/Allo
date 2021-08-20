import 'package:allo/components/person_picture.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ProfilePictureSettings extends HookWidget {
  bool loaded = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var loaded = useState(false);
    var percentage = useState(0.0);
    final auth = useProvider(Repositories.auth);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fotografie de profil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 30)),
            CupertinoFormSection.insetGrouped(
              children: [
                CupertinoFormRow(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 110,
                          width: 110,
                          child: ProgressRing(
                            value: percentage.value,
                          ),
                        ),
                        PersonPicture.determine(
                            radius: 100,
                            profilePicture: auth.returnProfilePicture(),
                            initials: auth.returnAuthenticatedNameInitials()),
                      ],
                    ),
                  ),
                )
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: Text('Gestionează imaginea de profil'),
              children: [
                GestureDetector(
                  onTap: () async => await auth.updateProfilePicture(
                      loaded: loaded, percentage: percentage, context: context),
                  child: CupertinoFormRow(
                    prefix: Text('Încarcă imagine'),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                      child: Icon(
                        CupertinoIcons.right_chevron,
                        color: CupertinoColors.systemGrey,
                        size: 15,
                      ),
                    ),
                  ),
                ),
                CupertinoFormRow(
                  prefix: Text('Șterge imaginea'),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                    child: Icon(CupertinoIcons.right_chevron,
                        color: CupertinoColors.systemGrey, size: 15),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
