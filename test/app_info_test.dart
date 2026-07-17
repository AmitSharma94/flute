import 'package:flutter_test/flutter_test.dart';
import 'package:flute_rc_v1/core/constants/app_info.dart';

void main() {
  test('release identity is consistent', () {
    expect(AppInfo.displayName, 'flute_rc_V1');
    expect(AppInfo.owner, 'Amit Sharma');
    expect(AppInfo.legalese, isNotEmpty);
    expect(AppInfo.displayName, isNot(contains('™')));
  });
}
