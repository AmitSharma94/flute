import 'package:flutter_test/flutter_test.dart';
import 'package:flute_rc_v1/core/constants/app_info.dart';

void main() {
  test('app information is correct', () {
    expect(AppInfo.displayName, 'flute');
    expect(AppInfo.packageName, 'flute_rc_v1');
    expect(AppInfo.version, isNotEmpty);
    expect(AppInfo.copyrightNotice, isNotEmpty);
    expect(AppInfo.thirdPartyNotice, isNotEmpty);
  });
}
