import 'dart:async';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'quaternion.dart';

/// Service for managing quaternion field state and motion energy
/// Provides observable quaternion updates for XR sensor integration
class QuaternionFieldService {
  final double energySmoothing;
  final double velocityReference;

  QuaternionState _state;
  Quaternion _lastPrimary;
  int _lastTimestamp;

  final _controller = StreamController<QuaternionSnapshot>.broadcast();

  QuaternionFieldService({
    this.energySmoothing = 0.35,
    this.velocityReference = 8.0,
  }) : _state = QuaternionState.initial(),
       _lastPrimary = Quaternion.identity(),
       _lastTimestamp = 0;

  /// Subscribe to quaternion field updates
  Stream<QuaternionSnapshot> get stream => _controller.stream;

  /// Get current state snapshot
  QuaternionSnapshot get snapshot => _createSnapshot();

  /// Ingest primary quaternion from XR sensor
  void ingestPrimaryQuaternion(
    Quaternion quaternion, {
    int? timestamp,
    double? confidence,
    String? source,
    Vector3? position,
  }) {
    final normalized = QuaternionUtils.normalize(quaternion);
    final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final conf = _normalizeConfidence(confidence);
    final motionEnergy = _computeMotionEnergy(normalized, ts);

    _state = QuaternionState(
      primary: normalized,
      secondary: _state.secondary,
      position: position ?? _state.position,
      timestamp: ts,
      confidence: conf,
      motionEnergy: motionEnergy,
      source: source ?? 'primary',
    );

    _emit();
  }

  /// Ingest secondary quaternion (e.g., from secondary sensor)
  void ingestSecondaryQuaternion(Quaternion quaternion, {String? source}) {
    final normalized = QuaternionUtils.normalize(quaternion);

    _state = QuaternionState(
      primary: _state.primary,
      secondary: normalized,
      position: _state.position,
      timestamp: _state.timestamp,
      confidence: _state.confidence,
      motionEnergy: _state.motionEnergy,
      source: source ?? 'secondary',
    );

    _emit();
  }

  /// Ingest complete pose (orientation + position)
  void ingestPose({
    Quaternion? orientation,
    Vector3? position,
    int? timestamp,
    double? confidence,
    String? source,
  }) {
    bool shouldUpdate = false;
    var updatedState = _state;

    if (orientation != null) {
      final normalizedPrimary = QuaternionUtils.normalize(orientation);
      final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch;
      final conf = _normalizeConfidence(confidence);
      final motionEnergy = _computeMotionEnergy(normalizedPrimary, ts);

      updatedState = QuaternionState(
        primary: normalizedPrimary,
        secondary: updatedState.secondary,
        position: position ?? updatedState.position,
        timestamp: ts,
        confidence: conf,
        motionEnergy: motionEnergy,
        source: source ?? 'pose',
      );
      shouldUpdate = true;
    } else if (position != null) {
      updatedState = QuaternionState(
        primary: updatedState.primary,
        secondary: updatedState.secondary,
        position: position,
        timestamp: updatedState.timestamp,
        confidence: updatedState.confidence,
        motionEnergy: updatedState.motionEnergy,
        source: source ?? 'position',
      );
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      _state = updatedState;
      _emit();
    }
  }

  /// Normalize confidence value to [0, 1]
  double _normalizeConfidence(double? value) {
    if (value == null || !value.isFinite) return 1.0;
    return value.clamp(0.0, 1.0);
  }

  /// Compute motion energy from quaternion change over time
  double _computeMotionEnergy(Quaternion quaternion, int timestamp) {
    if (_lastTimestamp == 0) {
      _lastPrimary = quaternion;
      _lastTimestamp = timestamp;
      return 0.0;
    }

    final deltaQuat = QuaternionUtils.multiply(
      quaternion,
      QuaternionUtils.conjugate(_lastPrimary),
    );
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

    final deltaTimeSeconds = (timestamp - _lastTimestamp) / 1000.0;
    final angularVelocity = angle.abs() / math.max(0.001, deltaTimeSeconds);
    final instantaneousEnergy = math.min(
      1.0,
      angularVelocity / velocityReference,
    );

    final smoothedEnergy =
        _state.motionEnergy +
        (instantaneousEnergy - _state.motionEnergy) * energySmoothing;

    _lastPrimary = quaternion;
    _lastTimestamp = timestamp;

    return smoothedEnergy;
  }

  /// Create snapshot of current state
  QuaternionSnapshot _createSnapshot() {
    final euler = QuaternionUtils.toEuler(_state.primary);
    return QuaternionSnapshot(
      primaryQuaternion: _state.primary,
      secondaryQuaternion: _state.secondary,
      position: _state.position,
      timestamp: _state.timestamp,
      confidence: _state.confidence,
      motionEnergy: _state.motionEnergy,
      source: _state.source,
      euler: euler,
    );
  }

  /// Emit current state to observers
  void _emit() {
    _controller.add(_createSnapshot());
  }

  /// Dispose of resources
  void dispose() {
    _controller.close();
  }
}

/// Internal state representation
class QuaternionState {
  final Quaternion primary;
  final Quaternion secondary;
  final Vector3 position;
  final int timestamp;
  final double confidence;
  final double motionEnergy;
  final String source;

  const QuaternionState({
    required this.primary,
    required this.secondary,
    required this.position,
    required this.timestamp,
    required this.confidence,
    required this.motionEnergy,
    required this.source,
  });

  factory QuaternionState.initial() {
    return QuaternionState(
      primary: Quaternion.identity(),
      secondary: Quaternion.identity(),
      position: Vector3.zero(),
      timestamp: 0,
      confidence: 1.0,
      motionEnergy: 0.0,
      source: 'init',
    );
  }
}

/// Observable snapshot of quaternion field
class QuaternionSnapshot {
  final Quaternion primaryQuaternion;
  final Quaternion secondaryQuaternion;
  final Vector3 position;
  final int timestamp;
  final double confidence;
  final double motionEnergy;
  final String source;
  final EulerAngles euler;

  const QuaternionSnapshot({
    required this.primaryQuaternion,
    required this.secondaryQuaternion,
    required this.position,
    required this.timestamp,
    required this.confidence,
    required this.motionEnergy,
    required this.source,
    required this.euler,
  });

  @override
  String toString() =>
      'QuaternionSnapshot(source: $source, confidence: $confidence, motionEnergy: $motionEnergy)';
}
