import 'package:allo/components/builders.dart';
import 'package:allo/components/info.dart';
import 'package:allo/components/slivers/sliver_center.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../components/person_picture.dart';
import '../../../../components/slivers/sliver_scaffold.dart';
import '../../../../components/slivers/top_app_bar.dart';

class _User {
  const _User(this.username, this.uid);
  final String username;
  final String uid;
}

class CreateChat extends HookWidget {
  const CreateChat({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    final error = useState<String?>(null);
    final usernameController = useTextEditingController();
    final found = useState(<_User>[]);
    return Scaffold(
      body: FutureWidget<Map<String, dynamic>?>(
        future: Core.general.user.getUsernamePairs(),
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        success: (data) {
          return SScaffold(
            topAppBar: LargeTopAppBar(
              title: Text(locales.createNewChat),
            ),
            pinnedSlivers: [
              SliverPinnedHeader(
                child: Container(
                  color: context.theme.colorScheme.surface,
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      errorText: error.value,
                      errorStyle: const TextStyle(fontSize: 14),
                      labelText: locales.username,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final prov = <_User>[];
                      for (final key in data!.keys) {
                        if (key.contains(value)) {
                          final uid = data.entries
                              .firstWhere((element) => element.key == key)
                              .value;
                          prov.add(_User(key, uid));
                        }
                      }
                      found.value = prov;
                    },
                    controller: usernameController,
                  ),
                ),
              )
            ],
            slivers: [
              if (found.value.isNotEmpty) ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ListTile(
                        leading: PersonPicture(
                          initials:
                              found.value[index].username.characters.first,
                          profilePicture: Core.auth
                              .getProfilePicture(found.value[index].uid),
                          radius: 50,
                        ),
                        title: Text(found.value[index].username),
                      );
                    },
                    childCount: found.value.length,
                  ),
                ),
              ] else ...[
                const SliverCenter(
                  child: InfoWidget(
                    text: 'No results.',
                  ),
                )
              ]

              // SliverFillRemaining(
              //   child: Padding(
              //     padding: const EdgeInsets.all(20),
              //     child: Column(
              //       children: [
              //         const Space(2),
              //         if (found.value.isEmpty) ...[
              //           const Expanded(
              //             flex: 5,
              //             child: Align(
              //               child: Text(
              //                 'No items found.',
              //               ),
              //             ),
              //           )
              //         ] else ...[
              //           Expanded(
              //             flex: 10,
              //             child: ListView.builder(
              //               itemCount: found.value.length,
              //               itemBuilder: (_, i) {
              //                 return ListTile(
              //                   title: Text(found.value[i]),
              //                 );
              //               },
              //             ),
              //           ),
              //         ],
              //         Expanded(
              //           child: Align(
              //             alignment: Alignment.bottomCenter,
              //             child: ElevatedButton(
              //               style: const ButtonStyle(
              //                 visualDensity: VisualDensity.standard,
              //               ),
              //               child: AnimatedSwitcher(
              //                 duration: const Duration(milliseconds: 100),
              //                 transitionBuilder: (child, animation) {
              //                   return ScaleTransition(
              //                     scale: animation,
              //                     child: child,
              //                   );
              //                 },
              //                 child: loading.value
              //                     ? SizedBox(
              //                         height: 23,
              //                         width: 23,
              //                         child: CircularProgressIndicator(
              //                           color: Theme.of(context)
              //                               .colorScheme
              //                               .onPrimary,
              //                           strokeWidth: 3,
              //                         ),
              //                       )
              //                     : Text(
              //                         'Search',
              //                         style: TextStyle(
              //                           color: Theme.of(context)
              //                               .colorScheme
              //                               .onPrimary,
              //                           backgroundColor: Colors.transparent,
              //                         ),
              //                       ),
              //               ),
              //               onPressed: () {
              //                 FocusScope.of(context).unfocus();
              //                 error.value = null;
              //                 loading.value = true;
              //                 if (usernameController.text.isEmpty) {
              //                   error.value = context.locale.errorFieldEmpty;
              //                 }
              //                 if (!data!.containsKey(usernameController.text)) {
              //                   error.value = 'This username does not exist.';
              //                 } else {
              //                   showDialog(
              //                     context: context,
              //                     builder: (context) {
              //                       return AlertDialog(
              //                         title: const Text('Success!'),
              //                         content: const Text(
              //                           'This username exists!',
              //                         ),
              //                         actions: [
              //                           TextButton(
              //                             onPressed: () =>
              //                                 Navigator.of(context).pop(),
              //                             child: const Text('OK'),
              //                           )
              //                         ],
              //                       );
              //                     },
              //                   );
              //                 }
              //                 loading.value = false;
              //               },
              //             ),
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // ),
            ],
          );
        },
        error: (error) {
          return Center(
            child: Text(error.toString()),
          );
        },
      ),
    );
  }
}
