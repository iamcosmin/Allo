import 'dart:io';

import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/debug.dart';
import 'package:allo/logic/backend/info.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/material3/tile.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final infoProvider = ref.watch(Info.infoProvider);
    // DO NOT REMOVE
    final a = useState(0);
    void b() {
      if (Core.auth.user.email == 'i.am.cosmin.bicc@gmail.com') {
        a.value++;
        if (a.value == 10) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const C()));
          a.value = 0;
        }
      }
    }

    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(locales.about),
      ),
      slivers: [
        infoProvider.when(
          loading: () {
            return const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          // ignore: avoid_types_on_closure_parameters
          data: (data) {
            final packageInfo = data.packageInfo;
            final deviceInfo = data.deviceInfo.toMap();
            return SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Text(
                          locales.appInfo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Tile(
                        title: Text(locales.name),
                        trailing: Text(packageInfo.appName),
                      ),
                      Tile(
                        title: Text(locales.version),
                        trailing: Text(packageInfo.version),
                      ),
                      Tile(
                        title: Text(locales.buildNumber),
                        trailing: Text(packageInfo.buildNumber),
                        onTap: () => b(),
                      ),
                      if (!kIsWeb) ...[
                        Tile(
                          title: Text(locales.packageName),
                          trailing: Text(packageInfo.packageName),
                        ),
                      ],
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          locales.deviceInfo,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (kIsWeb) ...[
                        Tile(
                          title: const Text('Browser'),
                          trailing: Text(
                            deviceInfo['browserName'].toString().split('.')[1],
                          ),
                        ),
                        Tile(
                          title: const Text('Browser agent'),
                          subtitle: Text(
                            deviceInfo['userAgent'].toString(),
                          ),
                        ),
                        Tile(
                          title: const Text('Platform'),
                          trailing: Text(
                            deviceInfo['platform'].toString(),
                          ),
                        )
                      ] else if (Platform.isAndroid) ...[
                        Tile(
                          title: const Text('Model'),
                          trailing: Text(
                            deviceInfo['model'].toString(),
                          ),
                        ),
                        Tile(
                          title: const Text('Brand'),
                          trailing: Text(
                            deviceInfo['brand'].toString(),
                          ),
                        ),
                        Tile(
                          title: const Text('Device'),
                          trailing: Text(
                            deviceInfo['device'].toString(),
                          ),
                        ),
                        Tile(
                          title: const Text('Version'),
                          trailing: Text(
                            deviceInfo['version']['release'].toString(),
                          ),
                        ),
                        Tile(
                          title: const Text('SDK'),
                          trailing: Text(
                            deviceInfo['version']['sdkInt'].toString(),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              ]),
            );
          },
          error: (error, stackTrace) {
            return SliverFillRemaining(
              child: Center(
                child: Text(error.toString()),
              ),
            );
          },
        ),
      ],
    );
  }
}
