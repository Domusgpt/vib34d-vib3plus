import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

/// Core quaternion utilities for XR spatial computing
/// Provides quaternion normalization, conversion, and arithmetic operations

class QuaternionUtils {
  /// Identity quaternion (no rotation)
  static final Quaternion identity = Quaternion.identity();

  /// Normalize a quaternion to unit length
  static Quaternion normalize(Quaternion? q) {
    if (q == null) {
      return Quaternion.identity();
    }

    final length = q.length;
    if (length == 0) {
      return Quaternion.identity();
    }

    return Quaternion(q.x / length, q.y / length, q.z / length, q.w / length);
  }

  /// Convert quaternion to Euler angles (roll, pitch, yaw)
  static EulerAngles toEuler(Quaternion q) {
    // Roll (x-axis rotation)
    final sinr = 2.0 * (q.w * q.x + q.y * q.z);
    final cosr = 1.0 - 2.0 * (q.x * q.x + q.y * q.y);
    final roll = math.atan2(sinr, cosr);

    // Pitch (y-axis rotation)
    final sinp = 2.0 * (q.w * q.y - q.z * q.x);
    final pitch = sinp.abs() >= 1.0
        ? (sinp.sign * math.pi / 2.0)
        : math.asin(sinp);

    // Yaw (z-axis rotation)
    final siny = 2.0 * (q.w * q.z + q.x * q.y);
    final cosy = 1.0 - 2.0 * (q.y * q.y + q.z * q.z);
    final yaw = math.atan2(siny, cosy);

    return EulerAngles(roll: roll, pitch: pitch, yaw: yaw);
  }

  /// Multiply two quaternions
  static Quaternion multiply(Quaternion a, Quaternion b) {
    return Quaternion(
      a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
      a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
      a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
      a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
    );
  }

  /// Get conjugate of quaternion (inverse rotation)
  static Quaternion conjugate(Quaternion q) {
    return Quaternion(-q.x, -q.y, -q.z, q.w);
  }

  /// Compute angular velocity between two quaternions
  static double angularVelocity(
    Quaternion current,
    Quaternion previous,
    Duration deltaTime,
  ) {
    final deltaQuat = multiply(current, conjugate(previous));
    final angle =
        2.0 *
        math.atan2(
          math.sqrt(
            deltaQuat.x * deltaQuat.x +
                deltaQuat.y * deltaQuat.y +
                deltaQuat.z * deltaQuat.z,
          ),
          deltaQuat.w,
        );

    final deltaSeconds = deltaTime.inMicroseconds / 1000000.0;
    return angle.abs() / math.max(0.001, deltaSeconds);
  }

  /// Linear interpolation between two quaternions
  static Quaternion lerp(Quaternion start, Quaternion end, double alpha) {
    final t = alpha.clamp(0.0, 1.0);
    return Quaternion(
      start.x + (end.x - start.x) * t,
      start.y + (end.y - start.y) * t,
      start.z + (end.z - start.z) * t,
      start.w + (end.w - start.w) * t,
    );
  }

  /// Spherical linear interpolation (SLERP) between two quaternions
  static Quaternion slerp(Quaternion start, Quaternion end, double alpha) {
    final t = alpha.clamp(0.0, 1.0);
    final result = Quaternion.copy(start);
    result.slerp(end, t);
    return result;
  }
}

/// Euler angles representation (roll, pitch, yaw in radians)
class EulerAngles {
  final double roll;
  final double pitch;
  final double yaw;

  const EulerAngles({
    required this.roll,
    required this.pitch,
    required this.yaw,
  });

  /// Convert to degrees
  EulerAngles toDegrees() {
    return EulerAngles(
      roll: roll * 180.0 / math.pi,
      pitch: pitch * 180.0 / math.pi,
      yaw: yaw * 180.0 / math.pi,
    );
  }

  @override
  String toString() => 'EulerAngles(roll: $roll, pitch: $pitch, yaw: $yaw)';
}
