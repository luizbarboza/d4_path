import 'dart:math';

import 'package:d4_path/d4_path.dart';
import 'package:test/test.dart';

void main() {
  test("pathRound() defaults to three digits of precision", () {
    final p = Path.round();
    p.moveTo(pi, e);
    expect(p.toString(), "M3.142,2.718");
  });

  test("pathRound(null) is equivalent to pathRound(0)", () {
    final p = Path.round(null);
    p.moveTo(pi, e);
    expect(p.toString(), "M3.0,3.0");
  });

  test("pathRound(digits) validates the specified digits", () {
    expect(
        () => Path.round(double.nan),
        throwsA(predicate((e) =>
            e is ArgumentError &&
            e.message == "Not greater than or equal to 0")));
    expect(
        () => Path.round(-1),
        throwsA(predicate((e) =>
            e is ArgumentError &&
            e.message == "Not greater than or equal to 0")));
  });

  test("pathRound(digits) ignores digits if greater than 15", () {
    final p = Path.round(40);
    p.moveTo(pi, e);
    expect(p.toString(), "M3.141592653589793,2.718281828459045");
  });

  test("pathRound.moveTo(x, y) limits the precision", () {
    final p = Path.round(1);
    p.moveTo(123.456, 789.012);
    expect(p.toString(), "M123.5,789.0");
  });

  test("pathRound.lineTo(x, y) limits the precision", () {
    final p = Path.round(1);
    p.moveTo(0, 0);
    p.lineTo(123.456, 789.012);
    expect(p.toString(), "M0.0,0.0L123.5,789.0");
  });

  test("pathRound.arc(x, y, r, a0, a1, ccw) limits the precision", () {
    final p0 = Path(), p = Path.round(1);
    p0.arc(10.0001, 10.0001, 123.456, 0, pi + 0.0001);
    p.arc(10.0001, 10.0001, 123.456, 0, pi + 0.0001);
    expect(p.toString(), precision(p0.toString(), 1));
    p0.arc(10.0001, 10.0001, 123.456, 0, pi - 0.0001);
    p.arc(10.0001, 10.0001, 123.456, 0, pi - 0.0001);
    expect(p.toString(), precision(p0.toString(), 1));
    p0.arc(10.0001, 10.0001, 123.456, 0, pi / 2, true);
    p.arc(10.0001, 10.0001, 123.456, 0, pi / 2, true);
    expect(p.toString(), precision(p0.toString(), 1));
  });

  test("pathRound.arcTo(x1, y1, x2, y2, r) limits the precision", () {
    final p0 = Path(), p = Path.round(1);
    p0.arcTo(10.0001, 10.0001, 123.456, 456.789, 12345.6789);
    p.arcTo(10.0001, 10.0001, 123.456, 456.789, 12345.6789);
    expect(p.toString(), precision(p0.toString(), 1));
  });

  test("pathRound.quadraticCurveTo(x1, y1, x, y) limits the precision", () {
    final p0 = Path(), p = Path.round(1);
    p0.quadraticCurveTo(10.0001, 10.0001, 123.456, 456.789);
    p.quadraticCurveTo(10.0001, 10.0001, 123.456, 456.789);
    expect(p.toString(), precision(p0.toString(), 1));
  });

  test("pathRound.bezierCurveTo(x1, y1, x2, y2, x, y) limits the precision",
      () {
    final p0 = Path(), p = Path.round(1);
    p0.bezierCurveTo(10.0001, 10.0001, 123.456, 456.789, 0.007, 0.006);
    p.bezierCurveTo(10.0001, 10.0001, 123.456, 456.789, 0.007, 0.006);
    expect(p.toString(), precision(p0.toString(), 1));
  });

  test("pathRound.rect(x, y, w, h) limits the precision", () {
    final p0 = Path(), p = Path.round(1);
    p0.rect(10.0001, 10.0001, 123.456, 456.789);
    p.rect(10.0001, 10.0001, 123.456, 456.789);
    expect(p.toString(), precision(p0.toString(), 1));
  });
}

String precision(String str, int precision) {
  return str.replaceAllMapped(RegExp(r'\d+(\.\d+)?'),
      (s) => (double.parse(s[0]!)).toStringAsFixed(precision));
}
