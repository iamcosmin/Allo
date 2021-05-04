import 'package:allo/core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:allo/core/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interface/home/stack_navigator.dart';
import 'interface/login/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Core.auth.initFirebase();
  final _kSharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_kSharedPreferences),
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
    final themeState = useProvider(appThemeStateProvider);
    return CupertinoApp(
        title: 'Allo',
        theme: theme.getAppThemeData(context, themeState),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot s) {
            if (s.hasData) {
              return StackNavigator();
            } else {
              return Welcome();
            }
          },
        ));
  }
}
