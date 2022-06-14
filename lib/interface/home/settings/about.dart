import 'dart:io';

import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/debug.dart';
import 'package:allo/logic/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../components/builders.dart';

class AppInfo {
  final BaseDeviceInfo deviceInfo;
  final PackageInfo packageInfo;

  const AppInfo({required this.deviceInfo, required this.packageInfo});
}

Future<AppInfo> getInfo() async {
  final deviceInfo = await DeviceInfoPlugin().deviceInfo;
  final packageInfo = await PackageInfo.fromPlatform();
  return AppInfo(deviceInfo: deviceInfo, packageInfo: packageInfo);
}

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    // DO NOT REMOVE
    final a = useState(0);
    void _b() {
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
        FutureWidget(
          future: getInfo(),
          loading: () {
            return const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          // ignore: avoid_types_on_closure_parameters
          success: (AppInfo data) {
            final packageInfo = data.packageInfo;
            final deviceInfo = data.deviceInfo.toMap();
            return SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 15, left: 15, right: 15),
                  child: Text(
                    locales.appInfo,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(locales.name),
                  trailing: Text(packageInfo.appName),
                ),
                ListTile(
                  title: Text(locales.version),
                  trailing: Text(packageInfo.version),
                ),
                ListTile(
                  title: Text(locales.buildNumber),
                  trailing: Text(packageInfo.buildNumber),
                  onTap: () => _b(),
                ),
                if (!kIsWeb) ...[
                  ListTile(
                    title: Text(locales.packageName),
                    trailing: Text(packageInfo.packageName),
                  ),
                ],
                const Padding(padding: EdgeInsets.only(top: 20)),
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
                  ListTile(
                    title: const Text('Browser'),
                    trailing: Text(
                      deviceInfo['browserName'].toString().split('.')[1],
                    ),
                  ),
                  ListTile(
                    title: const Text('Browser agent'),
                    subtitle: Text(
                      deviceInfo['userAgent'].toString(),
                    ),
                  ),
                  ListTile(
                    title: const Text('Platform'),
                    trailing: Text(
                      deviceInfo['platform'].toString(),
                    ),
                  )
                ] else if (Platform.isAndroid) ...[
                  ListTile(
                    title: const Text('Model'),
                    trailing: Text(
                      deviceInfo['model'].toString(),
                    ),
                  ),
                  ListTile(
                    title: const Text('Brand'),
                    trailing: Text(
                      deviceInfo['brand'].toString(),
                    ),
                  ),
                  ListTile(
                    title: const Text('Device'),
                    trailing: Text(
                      deviceInfo['device'].toString(),
                    ),
                  ),
                  ListTile(
                    title: const Text('Version'),
                    trailing: Text(
                      deviceInfo['version']['release'].toString(),
                    ),
                  ),
                  ListTile(
                    title: const Text('SDK'),
                    trailing: Text(
                      deviceInfo['version']['sdkInt'].toString(),
                    ),
                  ),
                ],
              ]),
            );
          },
          error: (error) {
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
