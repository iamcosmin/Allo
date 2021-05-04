import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/refresh.dart';
import 'package:allo/core/main.dart';
import 'package:allo/interface/home/chat/chat.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return CupertinoPageScaffold(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(100.0),
              child: Text(
                'Ne bucuram ca vrei sa incerci versiunea de desktop, insa aceasta nu este gata. Revino mai tarziu!',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      } else {
        return DefaultTextStyle(
          style: TextStyle(fontFamily: '.SF UI Text'),
          child: CupertinoPageScaffold(
              child: Material(
            color: CupertinoTheme.of(context).scaffoldBackgroundColor,
            child: CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  largeTitle: Text(
                    'Conversații',
                  ),
                ),
                FluentSliverRefreshControl(
                  onRefresh: () => Future.delayed(Duration(seconds: 3), null),
                  // ignore: unnecessary_null_comparison
                ),
                SliverSafeArea(
                    sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(padding: EdgeInsets.only(top: 20)),
                    ListTile(
                      isThreeLine: true,
                      title: Text(
                        'Allo',
                        style: TextStyle(
                            color: CupertinoTheme.of(context)
                                .primaryContrastingColor),
                      ),
                      subtitle: Text(
                        '\nconversatie principala',
                        style: TextStyle(
                            color: CupertinoTheme.of(context)
                                .primaryContrastingColor),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                            'https://hosty.xxx/i/06eefb21055d293d34baec1da27312c49e76adaa.jpg'),
                      ),
                      onTap: () => Core.navigate.to(
                          context,
                          Chat(
                            title: 'stricoii',
                          )),
                    ),
                    CupertinoButton(
                      child: Text('Deconectare'),
                      onPressed: () async => await Core.auth.signOut(),
                    )
                  ]),
                ))
              ],
            ),
          )),
        );
      }
    });
  }
}
