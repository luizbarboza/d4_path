import 'dart:math';

import 'package:d4_path/d4_path.dart';
import 'package:test/test.dart';

import 'equals_path.dart';

void main() {
  test("path.moveTo(x, y) appends an M command", () {
    final p = Path();
    p.moveTo(150, 50);
    expect(p.toString(), EqualsPath("M150,50"));
    p.lineTo(200, 100);
    expect(p.toString(), EqualsPath("M150,50L200,100"));
    p.moveTo(100, 50);
    expect(p.toString(), EqualsPath("M150,50L200,100M100,50"));
  });

  test("path.closePath() appends a Z command", () {
    final p = Path();
    p.moveTo(150, 50);
    expect(p.toString(), EqualsPath("M150,50"));
    p.closePath();
    expect(p.toString(), EqualsPath("M150,50Z"));
    p.closePath();
    expect(p.toString(), EqualsPath("M150,50ZZ"));
  });

  test("path.closePath() does nothing if the path is empty", () {
    final p = Path();
    expect(p.toString(), EqualsPath(""));
    p.closePath();
    expect(p.toString(), EqualsPath(""));
  });

  test("path.lineTo(x, y) appends an L command", () {
    final p = Path();
    p.moveTo(150, 50);
    expect(p.toString(), EqualsPath("M150,50"));
    p.lineTo(200, 100);
    expect(p.toString(), EqualsPath("M150,50L200,100"));
    p.lineTo(100, 50);
    expect(p.toString(), EqualsPath("M150,50L200,100L100,50"));
  });

  test("path.quadraticCurveTo(x1, y1, x, y) appends a Q command", () {
    final p = Path();
    p.moveTo(150, 50);
    expect(p.toString(), EqualsPath("M150,50"));
    p.quadraticCurveTo(100, 50, 200, 100);
    expect(p.toString(), EqualsPath("M150,50Q100,50,200,100"));
  });

  test("path.bezierCurveTo(x1, y1, x, y) appends a C command", () {
    final p = Path();
    p.moveTo(150, 50);
    expect(p.toString(), EqualsPath("M150,50"));
    p.bezierCurveTo(100, 50, 0, 24, 200, 100);
    expect(p.toString(), EqualsPath("M150,50C100,50,0,24,200,100"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) throws an error if the radius is negative",
      () {
    final p = Path();
    p.moveTo(150, 100);
    expect(() {
      p.arc(100, 100, -50, 0, pi / 2);
    },
        throwsA(predicate((e) =>
            e is ArgumentError &&
            e.message == "Not greater than or equal to 0")));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) may append only an M command if the radius is zero",
      () {
    final p = Path();
    p.arc(100, 100, 0, 0, pi / 2);
    expect(p.toString(), EqualsPath("M100,100"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) may append only an L command if the radius is zero",
      () {
    final p = Path();
    p.moveTo(0, 0);
    p.arc(100, 100, 0, 0, pi / 2);
    expect(p.toString(), EqualsPath("M0,0L100,100"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) may append only an M command if the angle is zero",
      () {
    final p = Path();
    p.arc(100, 100, 0, 0, 0);
    expect(p.toString(), EqualsPath("M100,100"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) may append only an M command if the angle is near zero",
      () {
    final p = Path();
    p.arc(100, 100, 0, 0, 1e-16);
    expect(p.toString(), EqualsPath("M100,100"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) may append an M command if the path was empty",
      () {
    final p1 = Path();
    p1.arc(100, 100, 50, 0, pi * 2);
    expect(p1.toString(),
        EqualsPath("M150,100A50,50,0,1,1,50,100A50,50,0,1,1,150,100"));
    final p2 = Path();
    p2.arc(0, 50, 50, -pi / 2, 0);
    expect(p2.toString(), EqualsPath("M0,0A50,50,0,0,1,50,50"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) may append an L command if the arc doesn’t start at the current point",
      () {
    final p = Path();
    p.moveTo(100, 100);
    p.arc(100, 100, 50, 0, pi * 2);
    expect(p.toString(),
        EqualsPath("M100,100L150,100A50,50,0,1,1,50,100A50,50,0,1,1,150,100"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) appends a single A command if the angle is less than π",
      () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, pi / 2);
    expect(p.toString(), EqualsPath("M150,100A50,50,0,0,1,100,150"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) appends a single A command if the angle is less than τ",
      () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, pi * 1);
    expect(p.toString(), EqualsPath("M150,100A50,50,0,1,1,50,100"));
  });

  test(
      "path.arc(x, y, radius, startAngle, endAngle) appends two A commands if the angle is greater than τ",
      () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, pi * 2);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,1,50,100A50,50,0,1,1,150,100"));
  });

  test("path.arc(x, y, radius, 0, π/2, false) draws a small clockwise arc", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, pi / 2, false);
    expect(p.toString(), EqualsPath("M150,100A50,50,0,0,1,100,150"));
  });

  test("path.arc(x, y, radius, -π/2, 0, false) draws a small clockwise arc",
      () {
    final p = Path();
    p.moveTo(100, 50);
    p.arc(100, 100, 50, -pi / 2, 0, false);
    expect(p.toString(), EqualsPath("M100,50A50,50,0,0,1,150,100"));
  });

  test("path.arc(x, y, radius, 0, ε, true) draws an anticlockwise circle", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 1e-16, true);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,0,50,100A50,50,0,1,0,150,100"));
  });

  test("path.arc(x, y, radius, 0, ε, false) draws nothing", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 1e-16, false);
    expect(p.toString(), EqualsPath("M150,100"));
  });

  test("path.arc(x, y, radius, 0, -ε, true) draws nothing", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, -1e-16, true);
    expect(p.toString(), EqualsPath("M150,100"));
  });

  test("path.arc(x, y, radius, 0, -ε, false) draws a clockwise circle", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, -1e-16, false);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,1,50,100A50,50,0,1,1,150,100"));
  });

  test("path.arc(x, y, radius, 0, τ, true) draws an anticlockwise circle", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 2 * pi, true);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,0,50,100A50,50,0,1,0,150,100"));
  });

  test("path.arc(x, y, radius, 0, τ, false) draws a clockwise circle", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 2 * pi, false);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,1,50,100A50,50,0,1,1,150,100"));
  });

  test("path.arc(x, y, radius, 0, τ + ε, true) draws an anticlockwise circle",
      () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 2 * pi + 1e-13, true);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,0,50,100A50,50,0,1,0,150,100"));
  });

  test("path.arc(x, y, radius, 0, τ - ε, false) draws a clockwise circle", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 2 * pi - 1e-13, false);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,1,50,100A50,50,0,1,1,150,100"));
  });

  test("path.arc(x, y, radius, τ, 0, true) draws an anticlockwise circle", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 2 * pi, true);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,0,50,100A50,50,0,1,0,150,100"));
  });

  test("path.arc(x, y, radius, τ, 0, false) draws a clockwise circle", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 2 * pi, false);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,1,50,100A50,50,0,1,1,150,100"));
  });

  test("path.arc(x, y, radius, 0, 13π/2, false) draws a clockwise circle", () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 13 * pi / 2, false);
    expect(p.toString(),
        EqualsPath("M150,100A50,50,0,1,1,50,100A50,50,0,1,1,150,100"));
  });

  test("path.arc(x, y, radius, 13π/2, 0, false) draws a big clockwise arc", () {
    final p = Path();
    p.moveTo(100, 150);
    p.arc(100, 100, 50, 13 * pi / 2, 0, false);
    expect(p.toString(), EqualsPath("M100,150A50,50,0,1,1,150,100"));
  });

  test("path.arc(x, y, radius, π/2, 0, false) draws a big clockwise arc", () {
    final p = Path();
    p.moveTo(100, 150);
    p.arc(100, 100, 50, pi / 2, 0, false);
    expect(p.toString(), EqualsPath("M100,150A50,50,0,1,1,150,100"));
  });

  test("path.arc(x, y, radius, 3π/2, 0, false) draws a small clockwise arc",
      () {
    final p = Path();
    p.moveTo(100, 50);
    p.arc(100, 100, 50, 3 * pi / 2, 0, false);
    expect(p.toString(), EqualsPath("M100,50A50,50,0,0,1,150,100"));
  });

  test("path.arc(x, y, radius, 15π/2, 0, false) draws a small clockwise arc",
      () {
    final p = Path();
    p.moveTo(100, 50);
    p.arc(100, 100, 50, 15 * pi / 2, 0, false);
    expect(p.toString(), EqualsPath("M100,50A50,50,0,0,1,150,100"));
  });

  test("path.arc(x, y, radius, 0, π/2, true) draws a big anticlockwise arc",
      () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, pi / 2, true);
    expect(p.toString(), EqualsPath("M150,100A50,50,0,1,0,100,150"));
  });

  test("path.arc(x, y, radius, -π/2, 0, true) draws a big anticlockwise arc",
      () {
    final p = Path();
    p.moveTo(100, 50);
    p.arc(100, 100, 50, -pi / 2, 0, true);
    expect(p.toString(), EqualsPath("M100,50A50,50,0,1,0,150,100"));
  });

  test("path.arc(x, y, radius, -13π/2, 0, true) draws a big anticlockwise arc",
      () {
    final p = Path();
    p.moveTo(100, 50);
    p.arc(100, 100, 50, -13 * pi / 2, 0, true);
    expect(p.toString(), EqualsPath("M100,50A50,50,0,1,0,150,100"));
  });

  test("path.arc(x, y, radius, -13π/2, 0, false) draws a big clockwise arc",
      () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, -13 * pi / 2, false);
    expect(p.toString(), EqualsPath("M150,100A50,50,0,1,1,100,50"));
  });

  test("path.arc(x, y, radius, 0, 13π/2, true) draws a big anticlockwise arc",
      () {
    final p = Path();
    p.moveTo(150, 100);
    p.arc(100, 100, 50, 0, 13 * pi / 2, true);
    expect(p.toString(), EqualsPath("M150,100A50,50,0,1,0,100,150"));
  });

  test("path.arc(x, y, radius, π/2, 0, true) draws a small anticlockwise arc",
      () {
    final p = Path();
    p.moveTo(100, 150);
    p.arc(100, 100, 50, pi / 2, 0, true);
    expect(p.toString(), EqualsPath("M100,150A50,50,0,0,0,150,100"));
  });

  test("path.arc(x, y, radius, 3π/2, 0, true) draws a big anticlockwise arc",
      () {
    final p = Path();
    p.moveTo(100, 50);
    p.arc(100, 100, 50, 3 * pi / 2, 0, true);
    expect(p.toString(), EqualsPath("M100,50A50,50,0,1,0,150,100"));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) throws an error if the radius is negative",
      () {
    final p = Path();
    p.moveTo(150, 100);
    expect(() {
      p.arcTo(270, 39, 163, 100, -53);
    },
        throwsA(predicate((e) =>
            e is ArgumentError &&
            e.message == "Not greater than or equal to 0")));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) appends an M command if the path was empty",
      () {
    final p = Path();
    p.arcTo(270, 39, 163, 100, 53);
    expect(p.toString(), EqualsPath("M270,39"));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) does nothing if the previous point was ⟨x1,y1⟩",
      () {
    final p = Path();
    p.moveTo(270, 39);
    p.arcTo(270, 39, 163, 100, 53);
    expect(p.toString(), EqualsPath("M270,39"));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) appends an L command if the previous point, ⟨x1,y1⟩ and ⟨x2,y2⟩ are collinear",
      () {
    final p = Path();
    p.moveTo(100, 50);
    p.arcTo(101, 51, 102, 52, 10);
    expect(p.toString(), EqualsPath("M100,50L101,51"));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) appends an L command if ⟨x1,y1⟩ and ⟨x2,y2⟩ are coincident",
      () {
    final p = Path();
    p.moveTo(100, 50);
    p.arcTo(101, 51, 101, 51, 10);
    expect(p.toString(), EqualsPath("M100,50L101,51"));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) appends an L command if the radius is zero",
      () {
    final p = Path();
    p.moveTo(270, 182);
    p.arcTo(270, 39, 163, 100, 0);
    expect(p.toString(), EqualsPath("M270,182L270,39"));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) appends L and A commands if the arc does not start at the current point",
      () {
    final p1 = Path();
    p1.moveTo(270, 182);
    p1.arcTo(270, 39, 163, 100, 53);
    expect(p1.toString(),
        EqualsPath("M270,182L270,130.222686A53,53,0,0,0,190.750991,84.179342"));
    final p2 = Path();
    p2.moveTo(270, 182);
    p2.arcTo(270, 39, 363, 100, 53);
    expect(p2.toString(),
        EqualsPath("M270,182L270,137.147168A53,53,0,0,1,352.068382,92.829799"));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) appends only an A command if the arc starts at the current point",
      () {
    final p = Path();
    p.moveTo(100, 100);
    p.arcTo(200, 100, 200, 200, 100);
    expect(p.toString(), EqualsPath("M100,100A100,100,0,0,1,200,200"));
  });

  test(
      "path.arcTo(x1, y1, x2, y2, radius) sets the last point to be the end tangent of the arc",
      () {
    final p = Path();
    p.moveTo(100, 100);
    p.arcTo(200, 100, 200, 200, 50);
    p.arc(150, 150, 50, 0, pi);
    expect(p.toString(),
        EqualsPath("M100,100L150,100A50,50,0,0,1,200,150A50,50,0,1,1,100,150"));
  });

  test("path.rect(x, y, w, h) appends M, h, v, h, and Z commands", () {
    final p = Path();
    p.moveTo(150, 100);
    p.rect(100, 200, 50, 25);
    expect(p.toString(), "M150,100M100,200h50v25h-50Z");
  });
}
