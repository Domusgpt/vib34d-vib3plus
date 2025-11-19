import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
import 'dart:math' as math;

void main() {
  group('QuaternionUtils', () {
    test('normalize returns identity for null quaternion', () {
      final result = QuaternionUtils.normalize(null);
      expect(result.x, equals(0.0));
      expect(result.y, equals(0.0));
      expect(result.z, equals(0.0));
      expect(result.w, equals(1.0));
    });

    test('normalize returns unit quaternion', () {
      final q = Quaternion(1.0, 2.0, 3.0, 4.0);
      final result = QuaternionUtils.normalize(q);
      final length = math.sqrt(
        result.x * result.x +
            result.y * result.y +
            result.z * result.z +
            result.w * result.w,
      );
      expect(length, closeTo(1.0, 0.0001));
    });

    test('toEuler converts quaternion to Euler angles', () {
      // Identity quaternion should give zero angles
      final identity = Quaternion.identity();
      final euler = QuaternionUtils.toEuler(identity);
      expect(euler.roll, closeTo(0.0, 0.0001));
      expect(euler.pitch, closeTo(0.0, 0.0001));
      expect(euler.yaw, closeTo(0.0, 0.0001));
    });

    test('multiply combines quaternions correctly', () {
      final q1 = Quaternion(1.0, 0.0, 0.0, 1.0);
      final q2 = Quaternion(0.0, 1.0, 0.0, 1.0);
      final result = QuaternionUtils.multiply(q1, q2);
      expect(result, isNotNull);
      // Result should be a valid quaternion
      expect(result.storage.length, equals(4));
    });

    test('conjugate inverts rotation', () {
      final q = Quaternion(1.0, 2.0, 3.0, 4.0);
      final conj = QuaternionUtils.conjugate(q);
      expect(conj.x, equals(-1.0));
      expect(conj.y, equals(-2.0));
      expect(conj.z, equals(-3.0));
      expect(conj.w, equals(4.0));
    });

    test('lerp interpolates correctly', () {
      final start = Quaternion(0.0, 0.0, 0.0, 1.0);
      final end = Quaternion(1.0, 0.0, 0.0, 0.0);

      final mid = QuaternionUtils.lerp(start, end, 0.5);
      expect(mid.x, closeTo(0.5, 0.0001));
      expect(mid.w, closeTo(0.5, 0.0001));

      final atStart = QuaternionUtils.lerp(start, end, 0.0);
      expect(atStart.x, closeTo(start.x, 0.0001));
      expect(atStart.w, closeTo(start.w, 0.0001));

      final atEnd = QuaternionUtils.lerp(start, end, 1.0);
      expect(atEnd.x, closeTo(end.x, 0.0001));
      expect(atEnd.w, closeTo(end.w, 0.0001));
    });
  });

  group('EulerAngles', () {
    test('toDegrees converts radians to degrees', () {
      final radians = EulerAngles(
        roll: math.pi,
        pitch: math.pi / 2,
        yaw: math.pi / 4,
      );

      final degrees = radians.toDegrees();
      expect(degrees.roll, closeTo(180.0, 0.0001));
      expect(degrees.pitch, closeTo(90.0, 0.0001));
      expect(degrees.yaw, closeTo(45.0, 0.0001));
    });

    test('toString provides readable output', () {
      final euler = EulerAngles(roll: 1.0, pitch: 2.0, yaw: 3.0);
      expect(euler.toString(), contains('roll'));
      expect(euler.toString(), contains('pitch'));
      expect(euler.toString(), contains('yaw'));
    });
  });
}
