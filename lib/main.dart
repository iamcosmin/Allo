import 'package:allo/logic/backend/firebase_options.dart';
import 'package:allo/logic/client/navigation/routing.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/theme.dart';
import 'package:allo/logic/core.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

import 'components/space.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Notifications.setupNotifications();
  await FirebaseRemoteConfig.instance.fetchAndActivate();
  // Temporary, once framework fixes SystemUiMode.edgeToEdge, we can return to it.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(
    ProviderScope(
      overrides: await Keys.getOverrides(),
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(context, ref) {
    Notifications.ensureListenersActive();
    final darkState = useSetting(ref, darkMode);
    ref.watch(Core.auth.stateProvider);
    FlutterError.demangleStackTrace = (stack) {
      if (stack is stack_trace.Trace) return stack.vmTrace;
      if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
      return stack;
    };
    return MaterialApp.router(
      title: 'Allo',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: Keys.scaffoldMessengerKey,
      color: kDefaultBrandingColor,
      themeMode:
          ThemeMode.values.firstWhere((_) => _.toString() == darkState.setting),
      theme: theme(Brightness.light, ref),
      darkTheme: theme(Brightness.dark, ref),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      /// ROUTER
      routerConfig: ref.read(routing),
      builder: (context, child) {
        return ref.watch(Core.auth.stateProvider).when(
          data: (data) {
            return child!;
          },
          error: (error, stack) {
            return Center(
              child: Text(error.toString()),
            );
          },
          loading: () {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.loc.startingApp,
                      style: context.textTheme.titleMedium!.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const Space(0.5),
                    const ProgressBar(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// TODO: Prepare for removal.
// class InnerApp extends HookConsumerWidget {
//   const InnerApp({super.key});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final darkState = useSetting(ref, darkMode);
//     final authState = ref.watch(Core.auth.stateProvider);
//     if (!kIsWeb) {
//       useEffect(
//         () {
//           Notifications.ensureListenersActive();
//           return;
//         },
//         const [],
//       );
//     }
//     return MaterialApp(
//       title: 'Allo',
//       debugShowCheckedModeBanner: false,
//       navigatorKey: rootNavigatorKey,
//       scaffoldMessengerKey: Keys.scaffoldMessengerKey,
//       themeMode: ThemeMode.values.firstWhere(
//         (element) => darkState.setting == element.toString(),
//       ),
//       theme: theme(Brightness.light, ref),
//       darkTheme: theme(Brightness.dark, ref),
//       localizationsDelegates: AppLocalizations.localizationsDelegates,
//       supportedLocales: AppLocalizations.supportedLocales,
//       home: authState.when(
//         data: (data) {
//           return PageTransitionSwitcher(
//             transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
//               return child;
//             },
//             child: Builder(
//               builder: (context) {
//                 switch (data) {
//                   case AuthState.emailNotVerified:
//                     return const EmailNotVerifiedPage();
//                   case AuthState.signedOut:
//                     return const IntroPage();
//                   case AuthState.signedIn:
//                     return const TabbedNavigator(Home());
//                 }
//               },
//             ),
//           );
//         },
//         error: (_, __) => const Center(
//           child: Text('Error!'),
//         ),
//         loading: () {
//           return const Scaffold(
//             body: Center(
//               child: SizedBox(
//                 height: 60,
//                 width: 60,
//                 child: ProgressRing(),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }