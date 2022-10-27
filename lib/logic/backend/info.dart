import 'package:device_info_plus/device_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Info {
  /// [Info] provides information about the app: version, name, package, what it's run on, etc.
  Info();

  static final infoProvider = FutureProvider<AppInfo>((ref) {
    return _getInfo();
  });

  static Future<AppInfo> _getInfo() async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    final packageInfo = await PackageInfo.fromPlatform();
    return AppInfo(deviceInfo: deviceInfo, packageInfo: packageInfo);
  }
}

class AppInfo {
  final BaseDeviceInfo deviceInfo;
  final PackageInfo packageInfo;

  const AppInfo({required this.deviceInfo, required this.packageInfo});
}
