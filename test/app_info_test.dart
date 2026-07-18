import 'package:flutter_test/flutter_test.dart';
import 'package:flute_rc_v1/core/constants/app_info.dart';

void main() {
  test('app information is correct', () {
    expect(AppInfo.name, 'flute');
    expect(AppInfo.copyrightNotice, isNotEmpty);
    expect(AppInfo.thirdPartyRightsNotice, isNotEmpty);
  });
}