/// Mock data generator for testing XR applications
///
/// Provides simulated AR/VR tracking data for development and testing
/// without requiring physical AR hardware.
library test_utils;

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../vib34d_xr_quaternion_sdk.dart';

/// Mock AR session for testing
class MockARSession {
  final SensoryInputBridge bridge;
  final double rotationSpeed;
  final double positionRadius;
  final math.Random _random;

  double _time = 0.0;

  MockARSession({
    required this.bridge,
    this.rotationSpeed = 1.0,
    this.positionRadius = 2.0,
    int? seed,
  }) : _random = math.Random(seed);

  /// Generate and publish a single AR frame
  void tick(Duration deltaTime) {
    _time += deltaTime.inMicroseconds / 1000000.0;

    // Generate smooth rotating orientation
    final roll = math.sin(_time * rotationSpeed * 0.5) * 0.3;
    final pitch = math.cos(_time * rotationSpeed * 0.7) * 0.4;
    final yaw = math.sin(_time * rotationSpeed * 0.3) * 0.5;

    final orientation = _eulerToQuaternion(roll, pitch, yaw);

    // Generate circular position movement
    final position = Vector3(
      math.cos(_time * rotationSpeed) * positionRadius,
      1.5 + math.sin(_time * rotationSpeed * 0.3) * 0.5,
      math.sin(_time * rotationSpeed) * positionRadius - 2.0,
    );

    // Simulate realistic confidence (0.7-0.95)
    final baseConfidence = 0.7;
    final confidenceVariation = 0.25;
    final confidence =
        baseConfidence +
        math.sin(_time * 2.3) * confidenceVariation * 0.5 +
        confidenceVariation * 0.5;

    bridge.publishPose(
      orientation: orientation,
      position: position,
      confidence: confidence.clamp(0.0, 1.0),
      source: 'mock-ar-session',
    );
  }

  /// Generate spatial anchors with random positions
  void publishAnchors(int count) {
    final anchors = <XRPose>[];

    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2;
      final radius = 1.0 + _random.nextDouble() * 2.0;

      final orientation = _randomQuaternion();
      final position = Vector3(
        math.cos(angle) * radius,
        _random.nextDouble() * 2.0,
        math.sin(angle) * radius,
      );

      anchors.add(
        XRPose(
          orientation: orientation,
          position: position,
          confidence: 0.6 + _random.nextDouble() * 0.3,
        ),
      );
    }

    bridge.publishSpatialAnchors(
      anchors: anchors,
      confidence: 0.8,
      source: 'mock-anchors',
    );
  }

  /// Convert Euler angles to quaternion
  Quaternion _eulerToQuaternion(double roll, double pitch, double yaw) {
    final cy = math.cos(yaw * 0.5);
    final sy = math.sin(yaw * 0.5);
    final cp = math.cos(pitch * 0.5);
    final sp = math.sin(pitch * 0.5);
    final cr = math.cos(roll * 0.5);
    final sr = math.sin(roll * 0.5);

    return Quaternion(
      sr * cp * cy - cr * sp * sy,
      cr * sp * cy + sr * cp * sy,
      cr * cp * sy - sr * sp * cy,
      cr * cp * cy + sr * sp * sy,
    );
  }

  /// Generate random quaternion
  Quaternion _randomQuaternion() {
    final u1 = _random.nextDouble();
    final u2 = _random.nextDouble();
    final u3 = _random.nextDouble();

    final sqrt1MinusU1 = math.sqrt(1 - u1);
    final sqrtU1 = math.sqrt(u1);

    return Quaternion(
      sqrt1MinusU1 * math.sin(2 * math.pi * u2),
      sqrt1MinusU1 * math.cos(2 * math.pi * u2),
      sqrtU1 * math.sin(2 * math.pi * u3),
      sqrtU1 * math.cos(2 * math.pi * u3),
    );
  }

  /// Reset simulation time
  void reset() {
    _time = 0.0;
  }
}

/// Test helper to create pre-configured SDK instances
class TestSDKFactory {
  /// Create SDK with mock AR session
  static ({
    SensoryInputBridge bridge,
    QuaternionFieldService quaternionService,
    ShaderQuaternionSynchronizer synchronizer,
    MockARSession mockSession,
  })
  createMockSDK({
    double energySmoothing = 0.35,
    double velocityReference = 8.0,
    double rotationScale = 2.0,
    void Function(String system, Map<String, double> parameters)?
    onSystemUpdate,
  }) {
    final bridge = SensoryInputBridge(channelHistoryLimit: 12);

    final quaternionService = QuaternionFieldService(
      energySmoothing: energySmoothing,
      velocityReference: velocityReference,
    );

    final synchronizer = ShaderQuaternionSynchronizer(
      bridge: bridge,
      quaternionService: quaternionService,
      rotationScale: rotationScale,
      onSystemUpdate: onSystemUpdate,
    );

    final mockSession = MockARSession(bridge: bridge);

    synchronizer.start();

    return (
      bridge: bridge,
      quaternionService: quaternionService,
      synchronizer: synchronizer,
      mockSession: mockSession,
    );
  }

  /// Dispose SDK instances
  static void dispose({
    required SensoryInputBridge bridge,
    required QuaternionFieldService quaternionService,
    required ShaderQuaternionSynchronizer synchronizer,
  }) {
    synchronizer.dispose();
    quaternionService.dispose();
    bridge.dispose();
  }
}

/// Assertion helpers for quaternion testing
class QuaternionAssertions {
  /// Assert quaternion is normalized
  static void assertNormalized(Quaternion q, {double epsilon = 0.0001}) {
    final length = q.length;
    if ((length - 1.0).abs() > epsilon) {
      throw AssertionError(
        'Quaternion not normalized: length = $length (expected 1.0 ± $epsilon)',
      );
    }
  }

  /// Assert quaternions are approximately equal
  static void assertQuaternionEquals(
    Quaternion actual,
    Quaternion expected, {
    double epsilon = 0.0001,
  }) {
    final dx = (actual.x - expected.x).abs();
    final dy = (actual.y - expected.y).abs();
    final dz = (actual.z - expected.z).abs();
    final dw = (actual.w - expected.w).abs();

    if (dx > epsilon || dy > epsilon || dz > epsilon || dw > epsilon) {
      throw AssertionError(
        'Quaternions not equal:\n'
        '  Actual:   (${actual.x}, ${actual.y}, ${actual.z}, ${actual.w})\n'
        '  Expected: (${expected.x}, ${expected.y}, ${expected.z}, ${expected.w})\n'
        '  Delta:    ($dx, $dy, $dz, $dw) (max epsilon: $epsilon)',
      );
    }
  }

  /// Assert Euler angles are approximately equal
  static void assertEulerEquals(
    EulerAngles actual,
    EulerAngles expected, {
    double epsilon = 0.0001,
  }) {
    final dRoll = (actual.roll - expected.roll).abs();
    final dPitch = (actual.pitch - expected.pitch).abs();
    final dYaw = (actual.yaw - expected.yaw).abs();

    if (dRoll > epsilon || dPitch > epsilon || dYaw > epsilon) {
      throw AssertionError(
        'Euler angles not equal:\n'
        '  Actual:   roll=${actual.roll}, pitch=${actual.pitch}, yaw=${actual.yaw}\n'
        '  Expected: roll=${expected.roll}, pitch=${expected.pitch}, yaw=${expected.yaw}\n'
        '  Delta:    roll=$dRoll, pitch=$dPitch, yaw=$dYaw (max epsilon: $epsilon)',
      );
    }
  }
}
