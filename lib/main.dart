import 'package:allo/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interface/home/stack_navigator.dart';
import 'interface/login/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthRepository().initFirebase();
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
