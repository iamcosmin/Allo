import 'package:allo/components/progress_rings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupPage extends HookWidget {
  const SetupPage(
      {required this.header,
      required this.body,
      required this.onButtonPress,
      required this.isAsync});
  final List<Widget> header;
  final List<Widget> body;
  final Function onButtonPress;
  final bool isAsync;

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
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
                padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CupertinoButton(
                      onPressed: () async {
                        if (isAsync) {
                          loading.value = true;
                          onButtonPress();
                          loading.value = false;
                        } else {
                          onButtonPress();
                        }
                      },
                      color: CupertinoColors.activeOrange,
                      child: loading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: ProgressRing(
                                activeColor: CupertinoColors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text('Continuare'),
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
