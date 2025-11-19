import 'dart:async';
import 'package:vector_math/vector_math.dart';

/// Sensor event payload
class SensorEvent {
  final dynamic payload;
  final double confidence;
  final int timestamp;
  final String source;

  const SensorEvent({
    required this.payload,
    this.confidence = 1.0,
    required this.timestamp,
    required this.source,
  });
}

/// XR pose data for spatial tracking
class XRPose {
  final Quaternion orientation;
  final Vector3? position;
  final double? confidence;

  const XRPose({
    required this.orientation,
    this.position,
    this.confidence,
  });
}

/// Sensory input bridge for XR sensor data
///
/// Normalizes heterogeneous sensor signals (ARCore/ARKit pose tracking,
/// spatial anchors, hit tests) into semantic channels that visualization
/// systems can subscribe to.
class SensoryInputBridge {
  final Map<String, StreamController<SensorEvent>> _channels = {};
  final Map<String, List<SensorEvent>> _history = {};
  final int channelHistoryLimit;

  SensoryInputBridge({
    this.channelHistoryLimit = 12,
  });

  /// Subscribe to a sensor channel
  Stream<SensorEvent> subscribe(String channel) {
    _ensureChannel(channel);
    return _channels[channel]!.stream;
  }

  /// Publish sensor event to channel
  void publish(String channel, SensorEvent event) {
    _ensureChannel(channel);

    // Add to history
    if (channelHistoryLimit > 0) {
      final history = _history[channel]!;
      history.add(event);
      if (history.length > channelHistoryLimit) {
        history.removeAt(0);
      }
    }

    // Emit to subscribers
    if (!_channels[channel]!.isClosed) {
      _channels[channel]!.add(event);
    }
  }

  /// Publish spatial pose data (AR/VR tracking)
  void publishPose({
    required Quaternion orientation,
    Vector3? position,
    double? confidence,
    String source = 'ar-tracking',
  }) {
    final event = SensorEvent(
      payload: {
        'orientation': orientation,
        if (position != null) 'position': position,
        if (confidence != null) 'confidence': confidence,
      },
      confidence: confidence ?? 1.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      source: source,
    );

    publish('spatial.pose', event);
  }

  /// Publish spatial anchor data
  void publishSpatialAnchors({
    required List<XRPose> anchors,
    double? confidence,
    String source = 'ar-anchors',
  }) {
    final event = SensorEvent(
      payload: {
        'anchors': anchors,
      },
      confidence: confidence ?? 1.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      source: source,
    );

    publish('spatial.anchors', event);
  }

  /// Publish hit test results (raycasting)
  void publishHitTests({
    required List<Map<String, dynamic>> results,
    double? confidence,
    String source = 'ar-hittest',
  }) {
    final event = SensorEvent(
      payload: {
        'results': results,
      },
      confidence: confidence ?? 1.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      source: source,
    );

    publish('spatial.hit-tests', event);
  }

  /// Get channel history
  List<SensorEvent> getHistory(String channel) {
    return _history[channel] ?? [];
  }

  /// Clear channel history
  void clearHistory(String channel) {
    _history[channel]?.clear();
  }

  /// Clear all history
  void clearAllHistory() {
    _history.forEach((_, history) => history.clear());
  }

  /// Ensure channel exists
  void _ensureChannel(String channel) {
    if (!_channels.containsKey(channel)) {
      _channels[channel] = StreamController<SensorEvent>.broadcast();
      _history[channel] = [];
    }
  }

  /// Dispose all channels
  void dispose() {
    for (final controller in _channels.values) {
      controller.close();
    }
    _channels.clear();
    _history.clear();
  }
}
