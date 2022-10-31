import 'package:allo/components/builders.dart';
import 'package:allo/components/info.dart';
import 'package:allo/logic/backend/chat/chats.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/types.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../../components/material3/tile.dart';
import '../../../../../components/slivers/sliver_scaffold.dart';
import '../../../../../components/slivers/top_app_bar.dart';

class CreateChat extends HookWidget {
  const CreateChat({super.key});

  @override
  Widget build(context) {
    final query = useState('');

    /// Have ABSOLUTELY no idea how this works, but implementation can be found here:
    /// https://stackoverflow.com/questions/46573804/firestore-query-documents-startswith-a-string
    String getLimit(String query) {
      return query.substring(0, query.length - 1) +
          String.fromCharCode(query.characters.last.codeUnitAt(0) + 1);
    }

    final usernameController = useTextEditingController();
    return SScaffold(
      topAppBar: MediumTopAppBar(
        title: Text(context.loc.createNewChat),
      ),
      pinnedSlivers: [
        SliverPinnedHeader(
          child: ColoredBox(
            color: context.colorScheme.surface,
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(5),
              decoration: ShapeDecoration(
                color: context.theme.colorScheme.secondaryContainer,
                shape: const StadiumBorder(),
              ),
              child: TextFormField(
                autofocus: true,
                style: TextStyle(
                  color: context.colorScheme.onSecondaryContainer,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: context.colorScheme.onSecondaryContainer,
                  ),
                  // errorText: error.value,
                  hintText: context.loc.search,
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  query.value = value;
                  // final prov = <_User>[];
                  // for (final key in data!.keys) {
                  //   if (key.contains(value)) {
                  //     final uid = data.entries
                  //         .firstWhere((element) => element.key == key)
                  //         .value;
                  //     prov.add(_User(key, uid));
                  //   }
                  // }
                  // found.value = prov;
                },
                controller: usernameController,
              ),
            ),
          ),
        )
      ],
      slivers: [
        if (query.value != '') ...[
          FutureView<QuerySnapshot>(
            FirebaseFirestore.instance
                .collection('users')
                .where(
                  FieldPath.documentId,
                  isGreaterThanOrEqualTo: query.value,
                )
                .where(
                  FieldPath.documentId,
                  isLessThan: getLimit(
                    query.value,
                  ),
                )
                .limit(5)
                .get(),
            loading: () => const SliverFillRemaining(
              child: Center(child: ProgressRing()),
            ),
            data: (value) {
              if (value.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: InfoWidget(
                      icon: const Icon(Icons.group_off_outlined),
                      text: context.loc.noResult,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = value.docs[index];
                    final userParams = user.data()! as Map<String, dynamic>;
                    return Tile(
                      title: Text(userParams['name']),
                      onTap: () async {
                        final existingChat = await FirebaseFirestore.instance
                            .collection('chats')
                            .where(
                              'participants',
                              isEqualTo: [
                                FirebaseAuth.instance.currentUser?.uid,
                                userParams['uid']
                              ],
                            )
                            .limit(1)
                            .get();
                        if (userParams['uid'] ==
                            FirebaseAuth.instance.currentUser?.uid) {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                icon: const Icon(Icons.person_off_outlined),
                                title: Text(context.loc.cannotCreateChat),
                                content: Text(
                                  context.loc.cannotCreateSelfChat,
                                ),
                                actions: [
                                  FilledButton(
                                    child: const Text('OK'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  )
                                ],
                              );
                            },
                          );
                        } else if (existingChat.docs.isNotEmpty) {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                icon: const Icon(Icons.person_off_outlined),
                                title: Text(context.loc.cannotCreateChat),
                                content: Text(
                                  context.loc.existingChatConflict,
                                ),
                                actions: [
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                icon: const Icon(Icons.person_add_outlined),
                                title: Text(
                                  context.loc
                                      .createChatWith(userParams['name']),
                                ),
                                content: Text(
                                  context.loc.createChatWithDescription(
                                    userParams['name'],
                                  ),
                                ),
                                actions: [
                                  OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(context.loc.cancel),
                                  ),
                                  FilledButton(
                                    child: Text(context.loc.createChat),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      context.pop();
                                      try {
                                        await Core.chats.createNewChat(
                                          chatType: ChatType.private,
                                          participants: [
                                            Participant(
                                              name: userParams['name'],
                                              uid: userParams['uid'],
                                            )
                                          ],
                                        );
                                        Core.stub.showInfoBar(
                                          icon: Icons.person_outline,
                                          text: context
                                              .loc.chatCreatedSuccessfully,
                                        );
                                      } catch (e) {
                                        Core.stub.showInfoBar(
                                          icon: Icons.person_off_outlined,
                                          text:
                                              '${context.loc.cannotCreateChat}.\n${context.loc.reason}: $e',
                                        );
                                      }
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        }
                      },
                      leading: CircleAvatar(
                        foregroundImage: FirebaseImage(
                          'gs://allo-ms.appspot.com/profilePictures/${userParams['uid']}.png',
                        ),
                        backgroundColor: context.colorScheme.surfaceVariant,
                        foregroundColor: context.colorScheme.surfaceVariant,
                        radius: 25,
                        child: Text(
                          Core.auth.returnNameInitials(userParams['name']),
                        ),
                      ),
                      subtitle: Text(user.id),
                    );
                  },
                  childCount: value.docs.length,
                ),
              );
            },
            error: (error, stackTrace) => SliverFillRemaining(
              child: Center(
                child: Text(
                  error.toString(),
                ),
              ),
            ),
          )
        ] else ...[
          SliverFillRemaining(
            child: Center(
              child: InfoWidget(
                text: context.loc.typeToShowResults,
                icon: const Icon(
                  Icons.people_outlined,
                  size: 50,
                ),
              ),
            ),
          )
        ]
      ],
    );
  }
}
