import 'package:test/expect.dart';

class EqualsPath extends CustomMatcher {
  EqualsPath(String path)
      : super("Path data that has a normalized representation equal to",
            "normalized representation", equals(path));

  @override
  Object? featureValueOf(actual) {
    return normalizePath(actual);
  }
}

final reNumber = RegExp(r'[-+]?(?:\d+\.\d+|\d+\.|\.\d+|\d+)(?:[eE][-]?\d+)?');

String normalizePath(String path) {
  return path.replaceAllMapped(reNumber, formatNumber);
}

String formatNumber(Match m) {
  var s = num.parse(m[0]!);
  return (s - s.round()).abs() < 1e-6
      ? s.round().toString()
      : s.toStringAsFixed(6);
}
