import 'package:allo/components/settings_list.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPage extends HookWidget {
  const SetupPage(
      {required this.header,
      required this.body,
      required this.onButtonPress,
      required this.isAsync,
      Key? key})
      : super(key: key);
  final List<Widget> header;
  final List<Widget> body;
  final Function onButtonPress;
  final bool isAsync;

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    final colors = useProvider(Repositories.colors);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.nonColors,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: header),
                ),
              ],
            ),
          ),
          if (body != []) ...[
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: body,
              ),
            ),
          ],
          Expanded(
            flex: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SettingsListTile(
                          title: 'Continuare',
                          color: Colors.blue,
                          type: RadiusType.BOTH,
                          center: true,
                          trailing: loading.value
                              ? const SizedBox(
                                  height: 23,
                                  width: 23,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : null,
                          onTap: () async {
                            if (isAsync) {
                              loading.value = true;
                              await onButtonPress();
                              loading.value = false;
                            } else {
                              onButtonPress();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
