import 'package:flutter_test/flutter_test.dart';
import 'package:flute_rc_v1/core/constants/app_info.dart';

void main() {
  test('release identity is consistent', () {
    expect(AppInfo.displayName, 'flute');
    expect(AppInfo.packageName, 'flute_rc_v1');
    expect(AppInfo.version, '1.0.0-rc.1');
    expect(AppInfo.owner, 'Amit Sharma');
    expect(AppInfo.legalese, contains('Amit Sharma'));
    expect(AppInfo.displayName, isNot(contains('™')));
  });
}
