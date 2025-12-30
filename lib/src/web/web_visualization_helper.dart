/// Web-specific visualization helpers for Flutter Web and HTML5 Canvas.
///
/// Provides utilities for rendering 4D geometries in 2D canvas context,
/// animation frame management, and performance monitoring.
///
/// **Usage Example**:
/// ```dart
/// final helper = WebVisualizationHelper(
///   canvasWidth: 800,
///   canvasHeight: 600,
/// );
///
/// helper.startAnimationLoop((deltaTime) {
///   // Update your visualization
///   final rot4d = helper.get4DRotations();
///   // Render...
/// });
/// ```

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../core/quaternion.dart';

/// 2D Point for canvas rendering
class Point2D {
  final double x;
  final double y;

  const Point2D(this.x, this.y);

  Point2D operator +(Point2D other) => Point2D(x + other.x, y + other.y);
  Point2D operator -(Point2D other) => Point2D(x - other.x, y - other.y);
  Point2D operator *(double scalar) => Point2D(x * scalar, y * scalar);

  @override
  String toString() => 'Point2D($x, $y)';
}

/// 4D Point for 4D geometry calculations
class Point4D {
  final double x;
  final double y;
  final double z;
  final double w;

  const Point4D(this.x, this.y, this.z, this.w);

  /// Project 4D point to 3D using perspective projection
  Vector3 projectTo3D({double distance = 2.0}) {
    final factor = distance / (distance + w);
    return Vector3(x * factor, y * factor, z * factor);
  }

  /// Rotate in 4D space
  Point4D rotate4D(Map<String, double> rotations) {
    double newX = x, newY = y, newZ = z, newW = w;

    // XY rotation
    if (rotations.containsKey('rot4dXY')) {
      final angle = rotations['rot4dXY']!;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      final tmpX = newX * cos - newY * sin;
      final tmpY = newX * sin + newY * cos;
      newX = tmpX;
      newY = tmpY;
    }

    // XZ rotation
    if (rotations.containsKey('rot4dXZ')) {
      final angle = rotations['rot4dXZ']!;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      final tmpX = newX * cos - newZ * sin;
      final tmpZ = newX * sin + newZ * cos;
      newX = tmpX;
      newZ = tmpZ;
    }

    // XW rotation
    if (rotations.containsKey('rot4dXW')) {
      final angle = rotations['rot4dXW']!;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      final tmpX = newX * cos - newW * sin;
      final tmpW = newX * sin + newW * cos;
      newX = tmpX;
      newW = tmpW;
    }

    // YZ rotation
    if (rotations.containsKey('rot4dYZ')) {
      final angle = rotations['rot4dYZ']!;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      final tmpY = newY * cos - newZ * sin;
      final tmpZ = newY * sin + newZ * cos;
      newY = tmpY;
      newZ = tmpZ;
    }

    // YW rotation
    if (rotations.containsKey('rot4dYW')) {
      final angle = rotations['rot4dYW']!;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      final tmpY = newY * cos - newW * sin;
      final tmpW = newY * sin + newW * cos;
      newY = tmpY;
      newW = tmpW;
    }

    // ZW rotation
    if (rotations.containsKey('rot4dZW')) {
      final angle = rotations['rot4dZW']!;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      final tmpZ = newZ * cos - newW * sin;
      final tmpW = newZ * sin + newW * cos;
      newZ = tmpZ;
      newW = tmpW;
    }

    return Point4D(newX, newY, newZ, newW);
  }

  @override
  String toString() => 'Point4D($x, $y, $z, $w)';
}

/// Color with HSL support
class ColorHSL {
  final double hue; // 0-360
  final double saturation; // 0-100
  final double lightness; // 0-100
  final double alpha; // 0-1

  const ColorHSL({
    required this.hue,
    this.saturation = 70,
    this.lightness = 50,
    this.alpha = 1.0,
  });

  /// Convert to CSS color string
  String toCssString() {
    return 'hsla($hue, $saturation%, $lightness%, $alpha)';
  }

  /// Create from RGB (0-255)
  factory ColorHSL.fromRGB(int r, int g, int b, {double alpha = 1.0}) {
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;

    final max = math.max(rNorm, math.max(gNorm, bNorm));
    final min = math.min(rNorm, math.min(gNorm, bNorm));
    final delta = max - min;

    double h = 0, s = 0, l = (max + min) / 2;

    if (delta != 0) {
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      if (max == rNorm) {
        h = ((gNorm - bNorm) / delta + (gNorm < bNorm ? 6 : 0)) / 6;
      } else if (max == gNorm) {
        h = ((bNorm - rNorm) / delta + 2) / 6;
      } else {
        h = ((rNorm - gNorm) / delta + 4) / 6;
      }
    }

    return ColorHSL(
      hue: h * 360,
      saturation: s * 100,
      lightness: l * 100,
      alpha: alpha,
    );
  }
}

/// Performance metrics tracker
class PerformanceMetrics {
  final List<double> _frameTimes = [];
  int _frameCount = 0;
  double _totalTime = 0.0;
  double _lastFrameTime = 0.0;

  static const int _maxSamples = 60;

  /// Record a frame time in milliseconds
  void recordFrame(double frameTimeMs) {
    _frameTimes.add(frameTimeMs);
    if (_frameTimes.length > _maxSamples) {
      _frameTimes.removeAt(0);
    }

    _frameCount++;
    _totalTime += frameTimeMs;
    _lastFrameTime = frameTimeMs;
  }

  /// Get current FPS
  double get fps {
    if (_frameTimes.isEmpty) return 0.0;
    final avgFrameTime =
        _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    return avgFrameTime > 0 ? 1000.0 / avgFrameTime : 0.0;
  }

  /// Get average frame time in milliseconds
  double get averageFrameTime {
    if (_frameTimes.isEmpty) return 0.0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  /// Get last frame time
  double get lastFrameTime => _lastFrameTime;

  /// Get total frames processed
  int get frameCount => _frameCount;

  /// Reset metrics
  void reset() {
    _frameTimes.clear();
    _frameCount = 0;
    _totalTime = 0.0;
    _lastFrameTime = 0.0;
  }
}

/// Web visualization helper
class WebVisualizationHelper {
  final double canvasWidth;
  final double canvasHeight;

  // Animation state
  bool _isAnimating = false;
  DateTime? _lastFrameTime;
  double _animationTime = 0.0;

  // Performance tracking
  final PerformanceMetrics metrics = PerformanceMetrics();

  // Rotation state
  Map<String, double> _current4DRotations = {
    'rot4dXY': 0.0,
    'rot4dXZ': 0.0,
    'rot4dYZ': 0.0,
    'rot4dXW': 0.0,
    'rot4dYW': 0.0,
    'rot4dZW': 0.0,
  };

  WebVisualizationHelper({
    required this.canvasWidth,
    required this.canvasHeight,
  });

  /// Start animation loop
  ///
  /// **callback** receives deltaTime in seconds
  void startAnimationLoop(void Function(double deltaTime) callback) {
    _isAnimating = true;
    _lastFrameTime = DateTime.now();
    _animate(callback);
  }

  /// Stop animation loop
  void stopAnimationLoop() {
    _isAnimating = false;
  }

  void _animate(void Function(double deltaTime) callback) {
    if (!_isAnimating) return;

    final now = DateTime.now();
    final deltaTime = _lastFrameTime != null
        ? now.difference(_lastFrameTime!).inMicroseconds / 1000000.0
        : 0.016;
    _lastFrameTime = now;

    final frameStartTime = DateTime.now();

    _animationTime += deltaTime;

    // Call user callback
    callback(deltaTime);

    // Record performance
    final frameTime =
        DateTime.now().difference(frameStartTime).inMicroseconds / 1000.0;
    metrics.recordFrame(frameTime);

    // Schedule next frame
    Future.delayed(const Duration(milliseconds: 16), () => _animate(callback));
  }

  /// Update 4D rotations from quaternion
  void update4DRotationsFromQuaternion(Quaternion quaternion) {
    final euler = QuaternionUtils.toEuler(quaternion);
    update4DRotationsFromEuler(euler);
  }

  /// Update 4D rotations from Euler angles
  void update4DRotationsFromEuler(EulerAngles euler) {
    const rotationScale = 1.0;

    _current4DRotations = {
      'rot4dXY': (euler.pitch + euler.yaw) * 0.5 * rotationScale,
      'rot4dXZ': (euler.pitch + euler.roll) * 0.5 * rotationScale,
      'rot4dYZ': (euler.yaw + euler.roll) * 0.5 * rotationScale,
      'rot4dXW': euler.pitch * rotationScale,
      'rot4dYW': euler.yaw * rotationScale,
      'rot4dZW': euler.roll * rotationScale,
    };
  }

  /// Get current 4D rotations
  Map<String, double> get4DRotations() => Map.from(_current4DRotations);

  /// Get animation time in seconds
  double get animationTime => _animationTime;

  /// Get center point of canvas
  Point2D get center => Point2D(canvasWidth / 2, canvasHeight / 2);

  /// Project 3D point to 2D canvas coordinates
  Point2D project3DTo2D(
    Vector3 point3d, {
    double scale = 200.0,
    double perspective = 500.0,
  }) {
    final factor = perspective / (perspective + point3d.z);
    final x = point3d.x * factor * scale + canvasWidth / 2;
    final y = point3d.y * factor * scale + canvasHeight / 2;
    return Point2D(x, y);
  }

  /// Generate tesseract (4D hypercube) vertices
  List<Point4D> generateTesseractVertices({double size = 1.0}) {
    final vertices = <Point4D>[];
    for (int i = 0; i < 16; i++) {
      final x = ((i & 1) * 2 - 1) * size;
      final y = (((i >> 1) & 1) * 2 - 1) * size;
      final z = (((i >> 2) & 1) * 2 - 1) * size;
      final w = (((i >> 3) & 1) * 2 - 1) * size;
      vertices.add(Point4D(x, y, z, w));
    }
    return vertices;
  }

  /// Generate sphere vertices
  List<Point4D> generateSphereVertices({
    double radius = 1.0,
    int segments = 20,
    int rings = 10,
  }) {
    final vertices = <Point4D>[];

    for (int ring = 0; ring <= rings; ring++) {
      final theta = (ring / rings) * math.pi;
      final sinTheta = math.sin(theta);
      final cosTheta = math.cos(theta);

      for (int segment = 0; segment <= segments; segment++) {
        final phi = (segment / segments) * 2 * math.pi;
        final x = radius * sinTheta * math.cos(phi);
        final y = radius * sinTheta * math.sin(phi);
        final z = radius * cosTheta;

        vertices.add(Point4D(x, y, z, 0));
      }
    }

    return vertices;
  }

  /// Create gradient color based on W coordinate
  ColorHSL getColorFromW(double w, {double baseHue = 200}) {
    final normalizedW = (w + 2.0) / 4.0; // Assuming w is in range -2 to 2
    final hue = (baseHue + normalizedW * 60) % 360;
    return ColorHSL(hue: hue, saturation: 70, lightness: 50);
  }

  /// Calculate distance from camera (for depth sorting)
  double getDepth(Point4D point) {
    return math.sqrt(
      point.x * point.x +
          point.y * point.y +
          point.z * point.z +
          point.w * point.w,
    );
  }
}
