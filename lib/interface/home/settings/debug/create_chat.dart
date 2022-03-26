import 'package:allo/components/builders.dart';
import 'package:allo/components/space.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CreateChat extends HookWidget {
  const CreateChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    final loading = useState(false);
    final error = useState<String?>(null);
    final usernameController = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.createNewChat),
      ),
      body: FutureView<Map<String, dynamic>?>(
        future: Core.general.user.getUsernamePairs(),
        success: (context, data) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Type below the username of the user you want to create a chat with.',
                ),
                const Space(2),
                TextFormField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    errorText: error.value,
                    errorStyle: const TextStyle(fontSize: 14),
                    labelText: locales.username,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  controller: usernameController,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.standard,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 100),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: loading.value
                            ? SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                'Search',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        error.value = null;
                        loading.value = true;
                        if (usernameController.text.isEmpty) {
                          error.value = context.locale.errorFieldEmpty;
                        }
                        if (!data!.containsKey(usernameController.text)) {
                          error.value = 'This username does not exist.';
                        } else {
                          showPlatformDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Success!'),
                                content: const Text('This username exists!'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  )
                                ],
                              );
                            },
                          );
                        }
                        loading.value = false;
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
