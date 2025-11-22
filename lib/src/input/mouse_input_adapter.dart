/// Mouse input adapter for web and desktop applications.
///
/// Converts mouse movements and clicks into quaternion rotations,
/// enabling 3D/4D interaction without AR hardware.
///
/// **Usage Example**:
/// ```dart
/// final adapter = MouseInputAdapter(
///   bridge: sensoryBridge,
///   sensitivity: 0.005,
///   invertY: false,
/// );
///
/// adapter.start();
///
/// // In your widget
/// MouseRegion(
///   onHover: (event) => adapter.handleMouseMove(
///     event.localPosition.dx,
///     event.localPosition.dy,
///   ),
/// )
/// ```

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../sensors/sensory_input_bridge.dart';
import '../core/quaternion.dart';

/// Configuration for mouse input behavior
class MouseInputConfig {
  /// Sensitivity multiplier for mouse movements (default: 0.005)
  final double sensitivity;

  /// Whether to invert Y-axis movement (default: false)
  final bool invertY;

  /// Whether to invert X-axis movement (default: false)
  final bool invertX;

  /// Enable mouse button to control rotation (default: true)
  /// When true, rotation only happens when mouse button is pressed
  final bool requireMouseDown;

  /// Smoothing factor for movements (0.0 = no smoothing, 1.0 = max smoothing)
  final double smoothing;

  /// Maximum rotation speed in radians per pixel
  final double maxSpeed;

  const MouseInputConfig({
    this.sensitivity = 0.005,
    this.invertY = false,
    this.invertX = false,
    this.requireMouseDown = true,
    this.smoothing = 0.15,
    this.maxSpeed = 0.05,
  });
}

/// Mouse input adapter for quaternion control
class MouseInputAdapter {
  final SensoryInputBridge bridge;
  final MouseInputConfig config;

  // Current rotation state
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;

  // Mouse state
  double _lastMouseX = 0.0;
  double _lastMouseY = 0.0;
  bool _isMouseDown = false;
  bool _isStarted = false;

  // Smoothing
  double _smoothedDeltaX = 0.0;
  double _smoothedDeltaY = 0.0;

  MouseInputAdapter({required this.bridge, MouseInputConfig? config})
    : config = config ?? const MouseInputConfig();

  /// Start publishing mouse-based quaternions
  void start() {
    _isStarted = true;
    _publishCurrentRotation();
  }

  /// Stop publishing updates
  void stop() {
    _isStarted = false;
  }

  /// Handle mouse movement
  ///
  /// Call this from MouseRegion.onHover or similar mouse tracking widgets.
  ///
  /// **Example**:
  /// ```dart
  /// MouseRegion(
  ///   onHover: (event) {
  ///     adapter.handleMouseMove(
  ///       event.localPosition.dx,
  ///       event.localPosition.dy,
  ///     );
  ///   },
  /// )
  /// ```
  void handleMouseMove(double x, double y) {
    if (!_isStarted) return;
    if (config.requireMouseDown && !_isMouseDown) return;

    // Calculate delta
    double deltaX = x - _lastMouseX;
    double deltaY = y - _lastMouseY;

    // Apply smoothing using exponential moving average
    _smoothedDeltaX =
        _smoothedDeltaX * (1.0 - config.smoothing) + deltaX * config.smoothing;
    _smoothedDeltaY =
        _smoothedDeltaY * (1.0 - config.smoothing) + deltaY * config.smoothing;

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

    // Update last position
    _lastMouseX = x;
    _lastMouseY = y;

    _publishCurrentRotation();
  }

  /// Handle mouse button press
  void handleMouseDown(double x, double y) {
    _isMouseDown = true;
    _lastMouseX = x;
    _lastMouseY = y;
    _smoothedDeltaX = 0.0;
    _smoothedDeltaY = 0.0;
  }

  /// Handle mouse button release
  void handleMouseUp() {
    _isMouseDown = false;
  }

  /// Handle mouse wheel for Z-axis rotation
  ///
  /// **Example**:
  /// ```dart
  /// Listener(
  ///   onPointerSignal: (event) {
  ///     if (event is PointerScrollEvent) {
  ///       adapter.handleMouseWheel(event.scrollDelta.dy);
  ///     }
  ///   },
  /// )
  /// ```
  void handleMouseWheel(double delta) {
    if (!_isStarted) return;

    _rotationZ += delta * config.sensitivity * 0.1;
    _publishCurrentRotation();
  }

  /// Reset rotation to identity
  void reset() {
    _rotationX = 0.0;
    _rotationY = 0.0;
    _rotationZ = 0.0;
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
    return EulerAngles(roll: _rotationZ, pitch: _rotationX, yaw: _rotationY);
  }

  /// Get current rotation as quaternion
  Quaternion getCurrentQuaternion() {
    return _eulerToQuaternion(_rotationZ, _rotationX, _rotationY);
  }

  void _publishCurrentRotation() {
    final quaternion = _eulerToQuaternion(_rotationZ, _rotationX, _rotationY);

    bridge.publishPose(
      orientation: quaternion,
      confidence: 1.0,
      source: 'mouse-input',
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
