/// Say you have some code that draws to a 2D canvas:
///
/// ```dart
/// drawCircle(context, radius) {
///   context.moveTo(radius, 0);
///   context.arc(0, 0, radius, 0, 2 * pi);
/// }
/// ```
///
/// The d4_path package lets you take this exact code and additionally render to
/// [SVG](http://www.w3.org/TR/SVG/paths.html). It works by
/// [serializing](https://pub.dev/documentation/d4_path/latest/d4_path/Path/toString.html)
/// [CanvasPathMethods](http://www.w3.org/TR/2dcontext/#canvaspathmethods) calls
/// to [SVG path data](http://www.w3.org/TR/SVG/paths.html#PathData). For
/// example:
///
/// ```dart
/// final path = Path();
/// drawCircle(path, 40);
/// path.toString(); // "M40,0A40,40,0,1,1,-40,0A40,40,0,1,1,40,0"
/// ```
///
/// Now code you write once can be used with both Canvas (for performance) and
/// SVG (for convenience). For a practical example, see
/// [d4_shape](https://pub.dev/documentation/d4_shape/latest/d4_shape/d4_shape-library.html).
export 'src/d4_path.dart';
