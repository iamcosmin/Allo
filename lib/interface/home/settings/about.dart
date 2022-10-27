import 'dart:io';

import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/components/tile_card.dart';
import 'package:allo/interface/home/settings/debug.dart';
import 'package:allo/logic/backend/info.dart';
import 'package:allo/logic/core.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/material3/tile.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoProvider = ref.watch(Info.infoProvider);
    // DO NOT REMOVE
    final a = useState(0);
    void b() {
      a.value++;
      if (a.value == 10) {
        // context.push('/settings/about/debug');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const DebugPage()));
        a.value = 0;
      }
    }

    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.loc.about),
      ),
      slivers: [
        infoProvider.when(
          loading: () {
            return const SliverFillRemaining(
              child: Center(
                child: ProgressBar(),
              ),
            );
          },
          // ignore: avoid_types_on_closure_parameters
          data: (data) {
            final packageInfo = data.packageInfo;
            final deviceInfo = data.deviceInfo.toMap();
            return SliverList(
              delegate: SliverChildListDelegate([
                TileHeading(context.loc.appInfo),
                TileCard(
                  [
                    Tile(
                      title: Text(context.loc.name),
                      trailing: Text(packageInfo.appName),
                    ),
                    Tile(
                      title: Text(context.loc.version),
                      trailing: Text(packageInfo.version),
                    ),
                    Tile(
                      title: Text(context.loc.buildNumber),
                      trailing: Text(packageInfo.buildNumber),
                      onTap: () => b(),
                    ),
                    if (!kIsWeb) ...[
                      Tile(
                        title: Text(context.loc.packageName),
                        subtitle: Text(packageInfo.packageName),
                      ),
                    ],
                  ],
                ),
                TileHeading(context.loc.deviceInfo),
                TileCard(
                  [
                    if (kIsWeb) ...[
                      Tile(
                        title: Text(context.loc.browser),
                        trailing: Text(
                          deviceInfo['browserName'].toString().split('.')[1],
                        ),
                      ),
                      Tile(
                        title: Text(context.loc.agent),
                        subtitle: Text(
                          deviceInfo['userAgent'].toString(),
                        ),
                      ),
                      Tile(
                        title: Text(context.loc.platform),
                        trailing: Text(
                          deviceInfo['platform'].toString(),
                        ),
                      )
                    ] else if (Platform.isAndroid) ...[
                      Tile(
                        title: Text(context.loc.model),
                        trailing: Text(
                          deviceInfo['model'].toString(),
                        ),
                      ),
                      Tile(
                        title: Text(context.loc.brand),
                        trailing: Text(
                          deviceInfo['brand'].toString(),
                        ),
                      ),
                      Tile(
                        title: Text(context.loc.device),
                        trailing: Text(
                          deviceInfo['device'].toString(),
                        ),
                      ),
                      Tile(
                        title: Text(context.loc.version),
                        trailing: Text(
                          deviceInfo['version']['release'].toString(),
                        ),
                      ),
                      Tile(
                        title: Text(context.loc.sdk),
                        trailing: Text(
                          deviceInfo['version']['sdkInt'].toString(),
                        ),
                      ),
                    ],
                  ],
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
