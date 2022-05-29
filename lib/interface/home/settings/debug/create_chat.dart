import 'package:allo/components/builders.dart';
import 'package:allo/components/space.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CreateChat extends HookWidget {
  const CreateChat({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    final loading = useState(false);
    final error = useState<String?>(null);
    final usernameController = useTextEditingController();
    final found = useState(<String>[]);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.createNewChat),
      ),
      body: FutureView<Map<String, String>?>(
        future: Core.general.user.getUsernamePairs(),
        success: (context, data) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    errorText: error.value,
                    errorStyle: const TextStyle(fontSize: 14),
                    labelText: locales.username,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final prov = <String>[];
                    for (final element in data!.keys) {
                      if (element.toString().contains(value)) {
                        prov.add(element);
                      }
                    }
                    found.value = prov;
                  },
                  controller: usernameController,
                ),
                const Space(2),
                if (found.value.isEmpty) ...[
                  const Expanded(
                    flex: 5,
                    child: Align(
                      child: Text(
                        'No items found.',
                      ),
                    ),
                  )
                ] else ...[
                  Expanded(
                    flex: 10,
                    child: ListView.builder(
                      itemCount: found.value.length,
                      itemBuilder: (_, i) {
                        return ListTile(
                          title: Text(found.value[i]),
                        );
                      },
                    ),
                  ),
                ],
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
                          showDialog(
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
