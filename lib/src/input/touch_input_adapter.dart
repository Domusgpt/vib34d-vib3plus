/// Touch input adapter for mobile web and Flutter mobile applications.
///
/// Converts touch gestures (swipe, pinch, rotate) into quaternion rotations,
/// enabling 3D/4D interaction on touchscreen devices without AR.
///
/// **Usage Example**:
/// ```dart
/// final adapter = TouchInputAdapter(
///   bridge: sensoryBridge,
///   sensitivity: 0.008,
/// );
///
/// adapter.start();
///
/// // In your widget
/// GestureDetector(
///   onPanUpdate: (details) => adapter.handlePan(
///     details.delta.dx,
///     details.delta.dy,
///   ),
///   onScaleUpdate: (details) => adapter.handleScale(
///     details.scale,
///     details.rotation,
///   ),
/// )
/// ```

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../sensors/sensory_input_bridge.dart';
import '../core/quaternion.dart';

/// Configuration for touch input behavior
class TouchInputConfig {
  /// Sensitivity multiplier for touch movements (default: 0.008)
  final double sensitivity;

  /// Whether to invert Y-axis movement (default: true for touch)
  final bool invertY;

  /// Whether to invert X-axis movement (default: false)
  final bool invertX;

  /// Smoothing factor for movements (0.0 = no smoothing, 1.0 = max smoothing)
  final double smoothing;

  /// Enable momentum/inertia after touch release
  final bool enableMomentum;

  /// Momentum decay factor (higher = faster decay)
  final double momentumDecay;

  /// Maximum rotation speed in radians per pixel
  final double maxSpeed;

  const TouchInputConfig({
    this.sensitivity = 0.008,
    this.invertY = true,
    this.invertX = false,
    this.smoothing = 0.2,
    this.enableMomentum = true,
    this.momentumDecay = 0.95,
    this.maxSpeed = 0.08,
  });
}

/// Touch input adapter for quaternion control
class TouchInputAdapter {
  final SensoryInputBridge bridge;
  final TouchInputConfig config;

  // Current rotation state
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;

  // Momentum state
  double _velocityX = 0.0;
  double _velocityY = 0.0;
  double _velocityZ = 0.0;

  // Smoothing
  double _smoothedDeltaX = 0.0;
  double _smoothedDeltaY = 0.0;

  // State
  bool _isStarted = false;
  bool _isTouching = false;
  double _lastScale = 1.0;

  TouchInputAdapter({
    required this.bridge,
    TouchInputConfig? config,
  }) : config = config ?? const TouchInputConfig();

  /// Start publishing touch-based quaternions
  void start() {
    _isStarted = true;
    _publishCurrentRotation();
  }

  /// Stop publishing updates
  void stop() {
    _isStarted = false;
  }

  /// Handle pan gesture (swipe/drag)
  ///
  /// Call this from GestureDetector.onPanUpdate
  ///
  /// **Example**:
  /// ```dart
  /// GestureDetector(
  ///   onPanStart: (_) => adapter.handlePanStart(),
  ///   onPanUpdate: (details) => adapter.handlePan(
  ///     details.delta.dx,
  ///     details.delta.dy,
  ///   ),
  ///   onPanEnd: (_) => adapter.handlePanEnd(),
  /// )
  /// ```
  void handlePan(double deltaX, double deltaY) {
    if (!_isStarted) return;

    // Apply smoothing
    _smoothedDeltaX = _smoothedDeltaX * (1.0 - config.smoothing) +
                      deltaX * config.smoothing;
    _smoothedDeltaY = _smoothedDeltaY * (1.0 - config.smoothing) +
                      deltaY * config.smoothing;

    // Apply sensitivity and inversion
    double rotX = _smoothedDeltaY * config.sensitivity;
    double rotY = _smoothedDeltaX * config.sensitivity;

    if (config.invertY) rotX = -rotX;
    if (config.invertX) rotY = -rotY;

    // Clamp to max speed
    rotX = rotX.clamp(-config.maxSpeed, config.maxSpeed);
    rotY = rotY.clamp(-config.maxSpeed, config.maxSpeed);

    // Update rotation
    _rotationX += rotX;
    _rotationY += rotY;

    // Store velocity for momentum
    _velocityX = rotX;
    _velocityY = rotY;

    _publishCurrentRotation();
  }

  /// Handle pan start (touch down)
  void handlePanStart() {
    _isTouching = true;
    _velocityX = 0.0;
    _velocityY = 0.0;
    _velocityZ = 0.0;
    _smoothedDeltaX = 0.0;
    _smoothedDeltaY = 0.0;
  }

  /// Handle pan end (touch up)
  void handlePanEnd() {
    _isTouching = false;

    // Start momentum if enabled
    if (config.enableMomentum && _isStarted) {
      _applyMomentum();
    }
  }

  /// Handle scale gesture (pinch/zoom and rotation)
  ///
  /// Call this from GestureDetector.onScaleUpdate
  ///
  /// **Example**:
  /// ```dart
  /// GestureDetector(
  ///   onScaleStart: (_) => adapter.handleScaleStart(),
  ///   onScaleUpdate: (details) => adapter.handleScale(
  ///     details.scale,
  ///     details.rotation,
  ///   ),
  /// )
  /// ```
  void handleScale(double scale, double rotation) {
    if (!_isStarted) return;

    // Use rotation for Z-axis
    final deltaRotation = rotation - _lastScale;
    _rotationZ += deltaRotation * 0.5;
    _velocityZ = deltaRotation * 0.5;

    _lastScale = rotation;
    _publishCurrentRotation();
  }

  /// Handle scale start
  void handleScaleStart() {
    _isTouching = true;
    _lastScale = 0.0;
  }

  /// Handle two-finger rotation specifically
  void handleTwoFingerRotation(double rotation) {
    if (!_isStarted) return;

    _rotationZ += rotation * config.sensitivity;
    _velocityZ = rotation * config.sensitivity;
    _publishCurrentRotation();
  }

  /// Reset rotation to identity
  void reset() {
    _rotationX = 0.0;
    _rotationY = 0.0;
    _rotationZ = 0.0;
    _velocityX = 0.0;
    _velocityY = 0.0;
    _velocityZ = 0.0;
    _smoothedDeltaX = 0.0;
    _smoothedDeltaY = 0.0;
    _publishCurrentRotation();
  }

  /// Set absolute rotation values
  void setRotation(double x, double y, double z) {
    _rotationX = x;
    _rotationY = y;
    _rotationZ = z;
    _publishCurrentRotation();
  }

  /// Get current rotation as Euler angles
  EulerAngles getCurrentEuler() {
    return EulerAngles(
      roll: _rotationZ,
      pitch: _rotationX,
      yaw: _rotationY,
    );
  }

  /// Get current rotation as quaternion
  Quaternion getCurrentQuaternion() {
    return _eulerToQuaternion(_rotationZ, _rotationX, _rotationY);
  }

  void _applyMomentum() {
    if (!config.enableMomentum || _isTouching) return;
    if (_velocityX.abs() < 0.0001 &&
        _velocityY.abs() < 0.0001 &&
        _velocityZ.abs() < 0.0001) {
      return;
    }

    // Apply velocity
    _rotationX += _velocityX;
    _rotationY += _velocityY;
    _rotationZ += _velocityZ;

    // Decay velocity
    _velocityX *= config.momentumDecay;
    _velocityY *= config.momentumDecay;
    _velocityZ *= config.momentumDecay;

    _publishCurrentRotation();

    // Schedule next frame
    Future.delayed(const Duration(milliseconds: 16), _applyMomentum);
  }

  void _publishCurrentRotation() {
    final quaternion = _eulerToQuaternion(_rotationZ, _rotationX, _rotationY);

    bridge.publishPose(
      orientation: quaternion,
      confidence: 1.0,
      source: 'touch-input',
    );
  }

  Quaternion _eulerToQuaternion(double roll, double pitch, double yaw) {
    final cr = math.cos(roll * 0.5);
    final sr = math.sin(roll * 0.5);
    final cp = math.cos(pitch * 0.5);
    final sp = math.sin(pitch * 0.5);
    final cy = math.cos(yaw * 0.5);
    final sy = math.sin(yaw * 0.5);

    return Quaternion(
      sr * cp * cy - cr * sp * sy, // x
      cr * sp * cy + sr * cp * sy, // y
      cr * cp * sy - sr * sp * cy, // z
      cr * cp * cy + sr * sp * sy, // w
    );
  }
}
