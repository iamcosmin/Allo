import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ThemeData, Colors;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interface/home/stack_navigator.dart';
import 'interface/login/welcome.dart';
import 'package:fluent_ui/fluent_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final _kSharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        Repositories.sharedPreferences.overrideWithValue(_kSharedPreferences),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends HookWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = useProvider(appThemeProvider);
    final darkState = useProvider(darkMode);
    return FluentApp(
      themeMode: darkState ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        accentColor: Colors.orange,
        activeColor: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        inactiveBackgroundColor: Color(0x00000000),
      ),
      home: CupertinoApp(
          title: 'Allo',
          theme: theme.getAppThemeData(context, darkState),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot s) {
              if (s.hasData) {
                return StackNavigator();
              } else {
                return Welcome();
              }
            },
          )),
    );
  }
}
