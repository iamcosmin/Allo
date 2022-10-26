import 'package:allo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPage extends HookConsumerWidget {
  const SetupPage(
      {required this.header,
      required this.body,
      required this.onButtonPress,
      required this.isAsync,
      this.alignment = CrossAxisAlignment.center,
      Key? key})
      : super(key: key);
  final List<Widget> header;
  final List<Widget> body;
  final Function onButtonPress;
  final bool isAsync;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final loading = useState(false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                crossAxisAlignment: alignment,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      child: loading.value
                          ? SizedBox(
                              height: 23,
                              width: 23,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(locales.setupNext),
                      onPressed: () async {
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
              ),
            ),
          )
        ],
      ),
    );
  }
}
