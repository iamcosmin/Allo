import 'dart:io';

import 'package:allo/components/builders.dart';
import 'package:allo/generated/l10n.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.about),
      ),
      body: FutureView<AppInfo>(
        future: getInfo(),
        success: (context, data) {
          final packageInfo = data.packageInfo;
          final deviceInfo = data.deviceInfo.toMap();
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'App Info',
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
                  'Device Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (kIsWeb) ...[
                ListTile(
                  title: const Text('Device memory'),
                  trailing: Text(
                    deviceInfo['deviceMemory'] ?? 'nul',
                  ),
                ),
                ListTile(
                  title: const Text('Language'),
                  trailing: Text(
                    deviceInfo['language'] ?? 'nul',
                  ),
                ),
                ListTile(
                  title: const Text('Browser'),
                  trailing: Text(
                    deviceInfo['vendor'] ?? 'nul',
                  ),
                ),
                ListTile(
                  title: const Text('Browser version'),
                  trailing: Text(
                    deviceInfo['vendorSub'] ?? 'nul',
                  ),
                ),
              ] else if (Platform.isAndroid) ...[
                ListTile(
                  title: const Text('Model'),
                  trailing: Text(
                    deviceInfo['model'] ?? 'nul',
                  ),
                ),
                ListTile(
                  title: const Text('Brand'),
                  trailing: Text(
                    deviceInfo['brand'] ?? 'nul',
                  ),
                ),
                ListTile(
                  title: const Text('Device'),
                  trailing: Text(
                    deviceInfo['device'] ?? 'nul',
                  ),
                ),
                ListTile(
                  title: const Text('Version'),
                  trailing: Text(
                    deviceInfo['version']['release'] ?? 'nul',
                  ),
                ),
                ListTile(
                  title: const Text('SDK'),
                  trailing: Text(
                    deviceInfo['version']['sdkInt'].toString(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
