/// Device motion adapter for mobile web and Flutter mobile applications.
///
/// Uses device orientation sensors (gyroscope, accelerometer) to create
/// quaternion rotations from phone/tablet movement, enabling motion-controlled
/// 3D/4D interaction without AR frameworks.
///
/// **Usage Example**:
/// ```dart
/// final adapter = DeviceMotionAdapter(
///   bridge: sensoryBridge,
///   smoothing: 0.3,
/// );
///
/// adapter.start();
///
/// // The adapter automatically listens to device sensors
/// // No manual updates needed!
/// ```

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../sensors/sensory_input_bridge.dart';
import '../core/quaternion.dart';

/// Configuration for device motion input
class DeviceMotionConfig {
  /// Smoothing factor for sensor data (0.0 = no smoothing, 1.0 = max smoothing)
  final double smoothing;

  /// Calibration offset for device orientation
  final EulerAngles calibrationOffset;

  /// Whether to automatically calibrate on start (use initial orientation as zero)
  final bool autoCalibrate;

  /// Sensitivity multiplier for motion (default: 1.0)
  final double sensitivity;

  /// Whether to invert pitch axis (default: false)
  final bool invertPitch;

  /// Whether to invert roll axis (default: false)
  final bool invertRoll;

  /// Whether to invert yaw axis (default: false)
  final bool invertYaw;

  const DeviceMotionConfig({
    this.smoothing = 0.3,
    this.calibrationOffset = const EulerAngles(roll: 0, pitch: 0, yaw: 0),
    this.autoCalibrate = true,
    this.sensitivity = 1.0,
    this.invertPitch = false,
    this.invertRoll = false,
    this.invertYaw = false,
  });
}

/// Device motion adapter for quaternion control
///
/// **Important**: This adapter requires platform-specific sensor access:
///
/// **For Flutter Mobile**:
/// - Add `sensors_plus` package to pubspec.yaml
/// - Use the provided helper methods with sensor streams
///
/// **For Web**:
/// - Use DeviceOrientation API via `dart:html`
/// - Requires HTTPS for sensor access
/// - User must grant permission on iOS 13+
class DeviceMotionAdapter {
  final SensoryInputBridge bridge;
  final DeviceMotionConfig config;

  // Current rotation state
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;

  // Smoothed values
  double _smoothedX = 0.0;
  double _smoothedY = 0.0;
  double _smoothedZ = 0.0;

  // Calibration
  EulerAngles? _calibrationAngles;

  // State
  bool _isStarted = false;
  bool _isCalibrated = false;

  DeviceMotionAdapter({required this.bridge, DeviceMotionConfig? config})
    : config = config ?? const DeviceMotionConfig();

  /// Start publishing device motion-based quaternions
  void start() {
    _isStarted = true;

    if (config.autoCalibrate) {
      _isCalibrated = false;
    }

    _publishCurrentRotation();
  }

  /// Stop publishing updates
  void stop() {
    _isStarted = false;
  }

  /// Update device orientation from sensor data
  ///
  /// **For Flutter with sensors_plus**:
  /// ```dart
  /// import 'package:sensors_plus/sensors_plus.dart';
  ///
  /// // Listen to gyroscope
  /// gyroscopeEvents.listen((GyroscopeEvent event) {
  ///   adapter.updateFromGyroscope(
  ///     event.x,
  ///     event.y,
  ///     event.z,
  ///     deltaTime: 0.016, // 60 FPS
  ///   );
  /// });
  /// ```
  void updateFromGyroscope(
    double x,
    double y,
    double z, {
    double deltaTime = 0.016,
  }) {
    if (!_isStarted) return;

    // Apply sensitivity
    x *= config.sensitivity;
    y *= config.sensitivity;
    z *= config.sensitivity;

    // Apply inversion
    if (config.invertPitch) x = -x;
    if (config.invertRoll) y = -y;
    if (config.invertYaw) z = -z;

    // Integrate angular velocity (gyroscope gives rate of change)
    _rotationX += x * deltaTime;
    _rotationY += y * deltaTime;
    _rotationZ += z * deltaTime;

    _applySmoothing();
    _publishCurrentRotation();
  }

  /// Update device orientation from accelerometer + magnetometer (orientation angles)
  ///
  /// **For Flutter with sensors_plus**:
  /// ```dart
  /// import 'package:sensors_plus/sensors_plus.dart';
  ///
  /// // Combine accelerometer and magnetometer for orientation
  /// // (This is a simplified example - real implementation needs sensor fusion)
  /// accelerometerEvents.listen((AccelerometerEvent event) {
  ///   final pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z));
  ///   final roll = atan2(-event.x, event.z);
  ///
  ///   adapter.updateFromOrientation(roll, pitch, 0.0);
  /// });
  /// ```
  void updateFromOrientation(double roll, double pitch, double yaw) {
    if (!_isStarted) return;

    // Handle auto-calibration
    if (config.autoCalibrate && !_isCalibrated) {
      _calibrationAngles = EulerAngles(roll: roll, pitch: pitch, yaw: yaw);
      _isCalibrated = true;
    }

    // Apply calibration offset
    final calibration = _calibrationAngles ?? config.calibrationOffset;
    roll -= calibration.roll;
    pitch -= calibration.pitch;
    yaw -= calibration.yaw;

    // Apply sensitivity
    roll *= config.sensitivity;
    pitch *= config.sensitivity;
    yaw *= config.sensitivity;

    // Apply inversion
    if (config.invertRoll) roll = -roll;
    if (config.invertPitch) pitch = -pitch;
    if (config.invertYaw) yaw = -yaw;

    // Update rotation (these are absolute values, not deltas)
    _rotationX = pitch;
    _rotationY = yaw;
    _rotationZ = roll;

    _applySmoothing();
    _publishCurrentRotation();
  }

  /// Update from quaternion directly (if platform provides it)
  ///
  /// Some platforms (iOS, newer Android) provide quaternion directly
  /// from sensor fusion algorithms.
  ///
  /// **Example**:
  /// ```dart
  /// // If your platform provides quaternion directly
  /// adapter.updateFromQuaternion(Quaternion(x, y, z, w));
  /// ```
  void updateFromQuaternion(Quaternion quaternion) {
    if (!_isStarted) return;

    // Convert to Euler for smoothing and calibration
    final euler = QuaternionUtils.toEuler(quaternion);

    updateFromOrientation(euler.roll, euler.pitch, euler.yaw);
  }

  /// Manually calibrate to current orientation as zero
  void calibrate() {
    _calibrationAngles = EulerAngles(
      roll: _rotationZ,
      pitch: _rotationX,
      yaw: _rotationY,
    );
    _isCalibrated = true;
  }

  /// Reset calibration
  void resetCalibration() {
    _calibrationAngles = null;
    _isCalibrated = false;
  }

  /// Reset rotation to identity
  void reset() {
    _rotationX = 0.0;
    _rotationY = 0.0;
    _rotationZ = 0.0;
    _smoothedX = 0.0;
    _smoothedY = 0.0;
    _smoothedZ = 0.0;
    _publishCurrentRotation();
  }

  /// Set absolute rotation values
  void setRotation(double x, double y, double z) {
    _rotationX = x;
    _rotationY = y;
    _rotationZ = z;
    _smoothedX = x;
    _smoothedY = y;
    _smoothedZ = z;
    _publishCurrentRotation();
  }

  /// Get current rotation as Euler angles
  EulerAngles getCurrentEuler() {
    return EulerAngles(roll: _smoothedZ, pitch: _smoothedX, yaw: _smoothedY);
  }

  /// Get current rotation as quaternion
  Quaternion getCurrentQuaternion() {
    return _eulerToQuaternion(_smoothedZ, _smoothedX, _smoothedY);
  }

  void _applySmoothing() {
    // Exponential moving average
    final smoothingFactor = config.smoothing;
    _smoothedX =
        _smoothedX * (1.0 - smoothingFactor) + _rotationX * smoothingFactor;
    _smoothedY =
        _smoothedY * (1.0 - smoothingFactor) + _rotationY * smoothingFactor;
    _smoothedZ =
        _smoothedZ * (1.0 - smoothingFactor) + _rotationZ * smoothingFactor;
  }

  void _publishCurrentRotation() {
    final quaternion = _eulerToQuaternion(_smoothedZ, _smoothedX, _smoothedY);

    bridge.publishPose(
      orientation: quaternion,
      confidence: 1.0,
      source: 'device-motion',
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
