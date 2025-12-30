import 'dart:async';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../core/quaternion.dart';
import '../core/quaternion_field_service.dart';
import '../sensors/sensory_input_bridge.dart';

/// Parameter limits for 4D rotation and visualization
class ParameterLimits {
  final double min;
  final double max;

  const ParameterLimits(this.min, this.max);

  double clamp(double value) => value.clamp(min, max);
}

/// Shader quaternion synchronizer for Flutter
///
/// Bridges normalized spatial quaternions from XR sensors into visualization
/// parameters. Derives smoothed motion energy and applies orientation-driven
/// parameter updates for reactive 4D geometric visualizations.
class ShaderQuaternionSynchronizer {
  static const double rotationLimit = 6.28; // ±2π rad
  static const double degPerRad = 180.0 / math.pi;

  static const Map<String, ParameterLimits> paramLimits = {
    'rot4dXY': ParameterLimits(-rotationLimit, rotationLimit),
    'rot4dXZ': ParameterLimits(-rotationLimit, rotationLimit),
    'rot4dYZ': ParameterLimits(-rotationLimit, rotationLimit),
    'rot4dXW': ParameterLimits(-rotationLimit, rotationLimit),
    'rot4dYW': ParameterLimits(-rotationLimit, rotationLimit),
    'rot4dZW': ParameterLimits(-rotationLimit, rotationLimit),
    'chaos': ParameterLimits(0.0, 1.0),
    'intensity': ParameterLimits(0.0, 1.0),
    'speed': ParameterLimits(0.1, 4.0),
    'saturation': ParameterLimits(0.0, 1.0),
    'hue': ParameterLimits(0.0, 360.0),
  };

  static const List<String> channels = [
    'spatial.anchors',
    'spatial.hit-tests',
    'spatial.pose',
  ];

  final SensoryInputBridge bridge;
  final QuaternionFieldService? quaternionService;
  final double rotationScale;
  final double minConfidence;
  final double baseAlpha;

  bool _enabled = true;
  final List<StreamSubscription> _subscriptions = [];

  final Map<String, double> _rotationState = {
    'rot4dXY': 0.0,
    'rot4dXZ': 0.0,
    'rot4dYZ': 0.0,
    'rot4dXW': 0.0,
    'rot4dYW': 0.0,
    'rot4dZW': 0.0,
  };

  // Callbacks for system updates
  final void Function(String system, Map<String, double> parameters)?
  onSystemUpdate;

  ShaderQuaternionSynchronizer({
    required this.bridge,
    this.quaternionService,
    this.rotationScale = 2.0,
    this.minConfidence = 0.45,
    this.baseAlpha = 0.25,
    this.onSystemUpdate,
  });

  /// Start listening to sensor channels
  void start() {
    stop();

    for (final channel in channels) {
      final subscription = bridge.subscribe(channel).listen((event) {
        try {
          _handleEvent(channel, event);
        } catch (e) {
          print('[ShaderQuaternionSynchronizer] Error handling $channel: $e');
        }
      });
      _subscriptions.add(subscription);
    }

    // Subscribe to quaternion service if available
    if (quaternionService != null) {
      final subscription = quaternionService!.stream.listen((snapshot) {
        _applyQuaternionSnapshot(snapshot);
      });
      _subscriptions.add(subscription);
    }
  }

  /// Stop listening
  void stop() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Set enabled state
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Handle sensor event
  void _handleEvent(String channel, SensorEvent event) {
    if (!_enabled) return;

    final confidence = _normalizeConfidence(event.confidence);

    if (channel == 'spatial.pose') {
      final orientation = event.payload['orientation'] as Quaternion?;
      final position = event.payload['position'] as Vector3?;

      if (orientation != null) {
        _applyOrientation(
          orientation,
          confidence: confidence,
          timestamp: event.timestamp,
          position: position,
        );
      }
    } else if (channel == 'spatial.anchors') {
      final anchors = event.payload['anchors'] as List<XRPose>?;
      if (anchors != null && anchors.isNotEmpty) {
        // Use best anchor
        final best = _getBestAnchor(anchors);
        if (best != null) {
          _applyOrientation(
            best.orientation,
            confidence: best.confidence ?? confidence,
            timestamp: event.timestamp,
            position: best.position,
          );
        }
      }
    }
  }

  /// Get anchor with highest confidence
  XRPose? _getBestAnchor(List<XRPose> anchors) {
    if (anchors.isEmpty) return null;

    XRPose? best;
    double bestConfidence = -1.0;

    for (final anchor in anchors) {
      final conf = anchor.confidence ?? 0.5;
      if (conf > bestConfidence) {
        best = anchor;
        bestConfidence = conf;
      }
    }

    return best;
  }

  /// Apply orientation update
  void _applyOrientation(
    Quaternion orientation, {
    required double confidence,
    required int timestamp,
    Vector3? position,
  }) {
    final normalized = QuaternionUtils.normalize(orientation);

    // If quaternion service exists, ingest there
    if (quaternionService != null) {
      quaternionService!.ingestPrimaryQuaternion(
        normalized,
        timestamp: timestamp,
        confidence: confidence,
        position: position,
      );
      return;
    }

    // Otherwise apply directly
    _applyNormalizedOrientation(
      normalized,
      confidence: confidence,
      timestamp: timestamp,
      position: position,
    );
  }

  /// Apply quaternion snapshot from service
  void _applyQuaternionSnapshot(QuaternionSnapshot snapshot) {
    _applyNormalizedOrientation(
      snapshot.primaryQuaternion,
      confidence: snapshot.confidence,
      timestamp: snapshot.timestamp,
      euler: snapshot.euler,
      motionEnergy: snapshot.motionEnergy,
    );
  }

  /// Apply normalized orientation to systems
  void _applyNormalizedOrientation(
    Quaternion quaternion, {
    required double confidence,
    required int timestamp,
    Vector3? position,
    EulerAngles? euler,
    double? motionEnergy,
  }) {
    // Convert to Euler if not provided
    final angles = euler ?? QuaternionUtils.toEuler(quaternion);

    // Compute 4D rotation targets
    final combinedPitchYaw = (angles.pitch + angles.yaw) * 0.5;
    final combinedPitchRoll = (angles.pitch + angles.roll) * 0.5;
    final combinedYawRoll = (angles.yaw + angles.roll) * 0.5;

    final rotationTarget = {
      'rot4dXY': _clamp(combinedPitchYaw * rotationScale, 'rot4dXY'),
      'rot4dXZ': _clamp(combinedPitchRoll * rotationScale, 'rot4dXZ'),
      'rot4dYZ': _clamp(combinedYawRoll * rotationScale, 'rot4dYZ'),
      'rot4dXW': _clamp(angles.pitch * rotationScale, 'rot4dXW'),
      'rot4dYW': _clamp(angles.yaw * rotationScale, 'rot4dYW'),
      'rot4dZW': _clamp(angles.roll * rotationScale, 'rot4dZW'),
    };

    // Update rotation state
    _rotationState.addAll(rotationTarget);

    // Notify system updates
    if (onSystemUpdate != null) {
      onSystemUpdate!('quaternion', Map.from(rotationTarget));
    }
  }

  /// Get current rotation state
  Map<String, double> get rotationState => Map.from(_rotationState);

  /// Normalize confidence to [0, 1]
  double _normalizeConfidence(double? value) {
    if (value == null || !value.isFinite) return baseAlpha;
    return value.clamp(0.0, 1.0);
  }

  /// Clamp value to parameter limits
  double _clamp(double value, String param) {
    final limits = paramLimits[param];
    if (limits == null) return value;
    return limits.clamp(value);
  }

  /// Dispose resources
  void dispose() {
    stop();
  }
}
