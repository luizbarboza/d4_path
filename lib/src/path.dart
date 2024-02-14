import 'dart:math';

const _tau = 2 * pi,
    _epsilon = 1e-6,
    _tauEpsilon = _tau - _epsilon,
    emptyList = <num>[];

void Function(String command, [List<num> arguments]) _appendRound(Path path,
    [num? digits]) {
  void append(String command, [List<num> arguments = emptyList]) {
    path._ += command + arguments.join(",");
  }

  if (digits == null) return append;
  var d = digits.floorToDouble();
  if (!(d >= 0)) {
    throw ArgumentError.value(
        digits, "digits", "Not greater than or equal to 0");
  }
  if (d > 15) return append;
  final k = pow(10, d);
  return (command, [arguments = emptyList]) {
    path._ +=
        command + arguments.map((x) => (x * k).roundToDouble() / k).join(",");
  };
}

/// A path serializer that implements
/// [CanvasPathMethods](http://www.w3.org/TR/2dcontext/#canvaspathmethods).
class Path {
  num? _x0,
      _y0, // start of current subpath
      _x1,
      _y1; // end of current subpath
  String _ = "";
  late void Function(String, [List<num>]) _append;

  Path() {
    _append = _appendRound(this, null);
  }

  /// Like [Path.new], except limits the digits after the decimal to the
  /// specified number of [digits]. Useful for reducing the size of generated
  /// SVG path data.
  ///
  /// ```dart
  /// final path = Path.round(3);
  /// ```
  Path.round([num? digits = 3]) {
    _append = _appendRound(this, digits ?? 0);
  }

  /// Move to the specified point ⟨[x], [y]⟩.
  ///
  /// ```dart
  /// path.moveTo(100, 100);
  /// ```
  ///
  /// Equivalent to
  /// [*context*.moveTo](http://www.w3.org/TR/2dcontext/#dom-context-2d-moveto)
  /// and SVG’s
  /// [“moveto” command](http://www.w3.org/TR/SVG/paths.html#PathDataMovetoCommands).
  void moveTo(num x, num y) {
    _append("M", [_x0 = _x1 = x, _y0 = _y1 = y]);
  }

  /// Ends the current subpath and causes an automatic straight line to be drawn
  /// from the current point to the initial point of the current subpath.
  ///
  /// ```dart
  /// path.closePath();
  /// ```
  ///
  /// Equivalent to
  /// [*context*.closePath](http://www.w3.org/TR/2dcontext/#dom-context-2d-closepath)
  /// and SVG’s
  /// [“closepath” command](http://www.w3.org/TR/SVG/paths.html#PathDataClosePathCommand).
  void closePath() {
    if (_x1 != null) {
      _x1 = _x0;
      _y1 = _y0;
      _append("Z");
    }
  }

  /// Draws a straight line from the current point to the specified point ⟨[x],
  /// [y]⟩.
  ///
  /// ```dart
  /// path.lineTo(200, 200);
  /// ```
  ///
  /// Equivalent to
  /// [*context*.lineTo](http://www.w3.org/TR/2dcontext/#dom-context-2d-lineto)
  /// and SVG’s
  /// [“lineto” command](http://www.w3.org/TR/SVG/paths.html#PathDataLinetoCommands).
  void lineTo(num x, num y) {
    _append("L", [_x1 = x, _y1 = y]);
  }

  /// Draws a quadratic Bézier segment from the current point to the specified
  /// point ⟨[x], [y]⟩, with the specified control point ⟨[cpx], [cpy]⟩.
  ///
  /// ```dart
  /// path.quadraticCurveTo(200, 0, 200, 200);
  /// ```
  ///
  /// Equivalent to
  /// [*context*.quadraticCurveTo](http://www.w3.org/TR/2dcontext/#dom-context-2d-quadraticcurveto)
  /// and SVG’s
  /// [quadratic Bézier curve commands](http://www.w3.org/TR/SVG/paths.html#PathDataQuadraticBezierCommands).
  void quadraticCurveTo(num cpx, num cpy, num x, num y) {
    _append("Q", [cpx, cpy, _x1 = x, _y1 = y]);
  }

  /// Draws a cubic Bézier segment from the current point to the specified point
  /// ⟨[x], [y]⟩, with the specified control points ⟨[cpx1], [cpy1]⟩ and
  /// ⟨[cpx2], [cpy2]⟩.
  ///
  /// ```dart
  /// path.bezierCurveTo(200, 0, 0, 200, 200, 200);
  /// ```
  ///
  /// Equivalent to
  /// [*context*.bezierCurveTo](http://www.w3.org/TR/2dcontext/#dom-context-2d-beziercurveto)
  /// and SVG’s
  /// [cubic Bézier curve commands](http://www.w3.org/TR/SVG/paths.html#PathDataCubicBezierCommands).
  void bezierCurveTo(num cpx1, num cpy1, num cpx2, num cpy2, num x, num y) {
    _append("C", [cpx1, cpy1, cpx2, cpy2, _x1 = x, _y1 = y]);
  }

  /// Draws a circular arc segment with the specified [radius] that starts
  /// tangent to the line between the current point and the specified point
  /// ⟨[x1], [y1]⟩ and ends tangent to the line between the specified points
  /// ⟨[x1], [y1]⟩ and ⟨[x2], [y2]⟩. If the first tangent point is not equal to
  /// the current point, a straight line is drawn between the current point and
  /// the first tangent point.
  ///
  /// ```dart
  /// path.arcTo(150, 150, 300, 10, 40);
  /// ```
  ///
  /// Equivalent to
  /// [*context*.arcTo](http://www.w3.org/TR/2dcontext/#dom-context-2d-arcto)
  /// and uses SVG’s
  /// [elliptical arc curve commands](http://www.w3.org/TR/SVG/paths.html#PathDataEllipticalArcCommands).
  void arcTo(num x1, num y1, num x2, num y2, num radius) {
    // Is the radius negative? Error.
    if (radius < 0) {
      throw ArgumentError.value(
          radius, "radius", "Not greater than or equal to 0");
    }

    num x0 = _x1 ?? double.nan,
        y0 = _y1 ?? double.nan,
        x21 = x2 - x1,
        y21 = y2 - y1,
        x01 = x0 - x1,
        y01 = y0 - y1,
        l01_2 = x01 * x01 + y01 * y01;

    // Is this path empty? Move to (x1,y1).
    if (_x1 == null) {
      _append("M", [_x1 = x1, _y1 = y1]);
    }

    // Or, is (x1,y1) coincident with (x0,y0)? Do nothing.
    else if (!(l01_2 > _epsilon)) {
    }

    // Or, are (x0,y0), (x1,y1) and (x2,y2) collinear?
    // Equivalently, is (x1,y1) coincident with (x2,y2)?
    // Or, is the radius zero? Line to (x1,y1).
    else if (!((y01 * x21 - y21 * x01).abs() > _epsilon) || radius == 0) {
      _append("L", [_x1 = x1, _y1 = y1]);
    }

    // Otherwise, draw an arc!
    else {
      var x20 = x2 - x0,
          y20 = y2 - y0,
          l21_2 = x21 * x21 + y21 * y21,
          l20_2 = x20 * x20 + y20 * y20,
          l21 = sqrt(l21_2),
          l01 = sqrt(l01_2),
          l = radius *
              tan((pi - acos((l21_2 + l01_2 - l20_2) / (2 * l21 * l01))) / 2),
          t01 = l / l01,
          t21 = l / l21;

      // If the start tangent is not coincident with (x0,y0), line to.
      if ((t01 - 1).abs() > _epsilon) {
        _append("L", [x1 + t01 * x01, y1 + t01 * y01]);
      }

      _append("A", [
        radius,
        radius,
        0,
        0,
        y01 * x20 > x01 * y20 ? 1 : 0,
        _x1 = x1 + t21 * x21,
        _y1 = y1 + t21 * y21
      ]);
    }
  }

  /// Draws a circular arc segment with the specified center ⟨[x], [y]⟩,
  /// [radius], [startAngle] and [endAngle]. If [anticlockwise] is true, the arc
  /// is drawn in the anticlockwise direction; otherwise, it is drawn in the
  /// clockwise direction. If the current point is not equal to the starting
  /// point of the arc, a straight line is drawn from the current point to the
  /// start of the arc.
  ///
  /// ```dart
  /// path.arc(80, 80, 70, 0, pi * 2);
  /// ```
  ///
  /// Equivalent to
  /// [*context*.arc](http://www.w3.org/TR/2dcontext/#dom-context-2d-arc)
  /// and uses SVG’s
  /// [elliptical arc curve commands](http://www.w3.org/TR/SVG/paths.html#PathDataEllipticalArcCommands).
  void arc(num x, num y, num radius, num startAngle, num endAngle,
      [bool anticlockwise = false]) {
    // Is the radius negative? Error.
    if (radius < 0) {
      throw ArgumentError.value(
          radius, "radius", "Not greater than or equal to 0");
    }

    var dx = radius * cos(startAngle),
        dy = radius * sin(startAngle),
        x0 = x + dx,
        y0 = y + dy,
        cw = anticlockwise ? 0 : 1,
        da = anticlockwise ? startAngle - endAngle : endAngle - startAngle;

    // Is this path empty? Move to (x0,y0).
    if (_x1 == null) {
      _append("M", [x0, y0]);
    }

    // Or, is (x0,y0) not coincident with the previous point? Line to (x0,y0).
    else if ((_x1! - x0).abs() > _epsilon || (_y1! - y0).abs() > _epsilon) {
      _append("L", [x0, y0]);
    }

    // Is this arc empty? We’re done.
    if (radius == 0) return;

    // Does the angle go the wrong way? Flip the direction.
    if (da < 0) da = da.remainder(_tau) + _tau;

    // Is this a complete circle? Draw two arcs to complete the circle.
    if (da > _tauEpsilon) {
      _append("A", [radius, radius, 0, 1, cw, x - dx, y - dy]);
      _append("A", [radius, radius, 0, 1, cw, _x1 = x0, _y1 = y0]);
    }

    // Is this arc non-empty? Draw an arc!
    else if (da > _epsilon) {
      _append("A", [
        radius,
        radius,
        0,
        da >= pi ? 1 : 0,
        cw,
        _x1 = x + radius * cos(endAngle),
        _y1 = y + radius * sin(endAngle)
      ]);
    }
  }

  /// Creates a new subpath containing just the four points ⟨[x], [y]⟩, ⟨[x] +
  /// [w], [y]⟩, ⟨[x] + [w], [y] + [h]⟩, ⟨[x], [y] + [h]⟩, with those four
  /// points connected by straight lines, and then marks the subpath as closed.
  ///
  /// ```dart
  /// path.rect(10, 10, 140, 140);
  /// ```
  ///
  /// Equivalent to
  /// [*context*.rect](http://www.w3.org/TR/2dcontext/#dom-context-2d-rect)
  /// and uses SVG’s
  /// [“lineto” commands](http://www.w3.org/TR/SVG/paths.html#PathDataLinetoCommands).
  void rect(num x, num y, num w, num h) {
    _append("M", [_x0 = _x1 = x, _y0 = _y1 = y]);
    _append("h", [w = w]);
    _append("v", [h]);
    _append("h", [-w]);
    _append("Z");
  }

  /// Returns the string representation of this *path* according to SVG’s
  /// [path data specification](http://www.w3.org/TR/SVG/paths.html#PathData).
  ///
  /// ```dart
  /// path.toString() // "M40,0A40,40,0,1,1,-40,0A40,40,0,1,1,40,0"
  /// ```
  @override
  String toString() {
    return _;
  }
}
