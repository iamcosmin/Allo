import 'package:allo/generated/l10n.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
      body: FutureBuilder<AppInfo>(
        future: getInfo(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final packageInfo = snapshot.data!.packageInfo;
            final deviceInfo = snapshot.data!.deviceInfo;

            if (deviceInfo is AndroidDeviceInfo) {}
            return ListView(
              shrinkWrap: true,
              children: [
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
                ListTile(
                  title: Text(locales.packageName),
                  trailing: Text(packageInfo.packageName),
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                // TODO: Implement device info section
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Center(
                child: SelectableText(
                  snapshot.error.toString(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
