# VIB34D Quaternion Data Flow Architecture

Complete architectural overview of how quaternion data flows through the SDK from XR sensors to visualization systems.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    XR Platform Layer                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  ARCore  │  │  ARKit   │  │  WebXR   │  │ Simulated│   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                        ▼
        ┌───────────────────────────────────────┐
        │    SensoryInputBridge                 │
        │  ┌─────────────────────────────────┐  │
        │  │  Channel: spatial.pose         │  │
        │  │  Channel: spatial.anchors      │  │
        │  │  Channel: spatial.hit-tests    │  │
        │  └─────────────────────────────────┘  │
        └─────────────┬─────────────────────────┘
                      │ SensorEvent(payload, confidence, timestamp)
                      ▼
        ┌───────────────────────────────────────┐
        │   QuaternionFieldService              │
        │  ┌─────────────────────────────────┐  │
        │  │  • Normalize quaternion         │  │
        │  │  • Compute motion energy        │  │
        │  │  │  • Convert to Euler angles     │  │
        │  │  • Emit QuaternionSnapshot      │  │
        │  └─────────────────────────────────┘  │
        └─────────────┬─────────────────────────┘
                      │ Stream<QuaternionSnapshot>
                      ▼
        ┌───────────────────────────────────────┐
        │  ShaderQuaternionSynchronizer         │
        │  ┌─────────────────────────────────┐  │
        │  │  • Map Euler → 6D rotations     │  │
        │  │    - rot4dXY ← (pitch+yaw)/2    │  │
        │  │    - rot4dXZ ← (pitch+roll)/2   │  │
        │  │    - rot4dYZ ← (yaw+roll)/2     │  │
        │  │    - rot4dXW ← pitch            │  │
        │  │    - rot4dYW ← yaw              │  │
        │  │    - rot4dZW ← roll             │  │
        │  │  • Apply parameter limits       │  │
        │  │  • Smooth with confidence       │  │
        │  └─────────────────────────────────┘  │
        └─────────────┬─────────────────────────┘
                      │ onSystemUpdate(system, params)
                      ▼
        ┌───────────────────────────────────────┐
        │    Application Visualization Layer     │
        │  ┌──────────┐  ┌──────────┐           │
        │  │ Custom   │  │ Shader   │           │
        │  │ Painter  │  │ Uniforms │           │
        │  └──────────┘  └──────────┘           │
        └───────────────────────────────────────┘
```

## Component Breakdown

### 1. XR Platform Layer

**Responsibility**: Provide raw pose data from device sensors

**Data Format**:
- Orientation: 4×4 transformation matrix OR quaternion (x, y, z, w)
- Position: 3D vector (x, y, z)
- Confidence: Platform-specific tracking quality indicator

**Platform Variations**:

| Platform | Orientation Format | Confidence Source |
|----------|-------------------|-------------------|
| ARCore   | 4×4 Matrix (column-major) | Tracking state enum |
| ARKit    | 4×4 Matrix (column-major) | ARCamera.trackingState |
| WebXR    | Float32Array(16) | XRPose implicit |
| Simulated| Quaternion direct | Fixed or computed |

### 2. SensoryInputBridge

**Responsibility**: Normalize heterogeneous sensor inputs into semantic channels

**Architecture**:
```dart
class SensoryInputBridge {
  Map<String, StreamController<SensorEvent>> _channels;
  Map<String, List<SensorEvent>> _history;

  // Publish to channel
  void publish(String channel, SensorEvent event);

  // Subscribe to channel
  Stream<SensorEvent> subscribe(String channel);
}
```

**Channel Semantics**:
- `spatial.pose`: Primary device pose (camera/headset)
- `spatial.anchors`: Spatial anchors with world-locked poses
- `spatial.hit-tests`: Raycast results with hit pose

**Event Structure**:
```dart
class SensorEvent {
  dynamic payload;        // Channel-specific data
  double confidence;      // 0.0-1.0 tracking quality
  int timestamp;          // Milliseconds since epoch
  String source;          // 'arcore', 'arkit', etc.
}
```

**History Management**:
- Configurable ring buffer per channel
- Default: 12 events
- Used for motion analysis and debugging

### 3. QuaternionFieldService

**Responsibility**: Manage quaternion state with motion energy tracking

**State Model**:
```dart
class QuaternionState {
  Quaternion primary;     // Main orientation
  Quaternion secondary;   // Optional second sensor
  Vector3 position;       // Spatial position
  int timestamp;          // Event time
  double confidence;      // Tracking quality
  double motionEnergy;    // 0.0-1.0 angular velocity
  String source;          // Event source
}
```

**Motion Energy Computation**:
```dart
// 1. Compute angular difference
deltaQuat = current * conjugate(previous)
angle = 2 * atan2(length(deltaQuat.xyz), deltaQuat.w)

// 2. Compute angular velocity (rad/s)
angularVelocity = angle / deltaTime

// 3. Normalize to reference velocity
instantEnergy = min(1.0, angularVelocity / velocityReference)

// 4. Smooth with exponential moving average
motionEnergy = lerp(prevEnergy, instantEnergy, energySmoothing)
```

**Parameters**:
- `energySmoothing`: 0.35 (default) - EMA alpha for smoothing
- `velocityReference`: 8.0 rad/s (default) - Velocity for energy=1.0

**Output Stream**:
```dart
class QuaternionSnapshot {
  Quaternion primaryQuaternion;
  Quaternion secondaryQuaternion;
  Vector3 position;
  int timestamp;
  double confidence;
  double motionEnergy;
  String source;
  EulerAngles euler;     // Pre-computed Euler angles
}
```

### 4. ShaderQuaternionSynchronizer

**Responsibility**: Convert quaternion snapshots to 4D rotation parameters

**Euler to 4D Rotation Mapping**:
```dart
// Extract Euler angles (radians)
euler = quaternionToEuler(quaternion)
// euler.roll:  rotation around X axis
// euler.pitch: rotation around Y axis
// euler.yaw:   rotation around Z axis

// Map to 6-plane 4D rotations
rot4dXY = (pitch + yaw) / 2 * rotationScale
rot4dXZ = (pitch + roll) / 2 * rotationScale
rot4dYZ = (yaw + roll) / 2 * rotationScale
rot4dXW = pitch * rotationScale
rot4dYW = yaw * rotationScale
rot4dZW = roll * rotationScale

// Clamp to ±2π
each parameter clamped to [-6.28, 6.28]
```

**Parameter Smoothing**:
```dart
// Compute alpha based on confidence
if (confidence < minConfidence):
  alpha = baseAlpha * (confidence / minConfidence)
else:
  alpha = max(baseAlpha, min(1.0, confidence))

// Lerp to target
newValue = currentValue + (targetValue - currentValue) * alpha
```

**Default Parameters**:
- `rotationScale`: 2.0 - Amplification factor for rotations
- `minConfidence`: 0.45 - Threshold for reduced smoothing
- `baseAlpha`: 0.25 - Minimum interpolation factor

**Output Callback**:
```dart
void onSystemUpdate(
  String system,              // 'quaternion', 'quantum', etc.
  Map<String, double> params  // Parameter updates
);
```

## Data Flow Timing

### Typical Frame Processing (60 FPS)

```
T=0ms    ARCore/ARKit produces frame
T=1ms    Platform callback invoked
T=2ms    Matrix → Quaternion conversion
T=3ms    SensoryInputBridge.publish()
T=4ms    QuaternionFieldService.ingestPrimaryQuaternion()
         - Normalize quaternion
         - Compute motion energy (1-2ms)
         - Convert to Euler
T=6ms    Emit QuaternionSnapshot
T=7ms    ShaderQuaternionSynchronizer receives
         - Map Euler → 6D rotations
         - Apply smoothing
         - Invoke onSystemUpdate callback
T=9ms    Application CustomPainter.paint()
T=16ms   Frame complete
```

### Performance Budget (60 FPS = 16.67ms/frame)

| Component | Typical Time | Budget |
|-----------|--------------|--------|
| Platform overhead | 1-2ms | 3ms |
| Matrix conversion | 0.5-1ms | 2ms |
| Bridge routing | <0.1ms | 0.5ms |
| QuaternionFieldService | 1-2ms | 3ms |
| Synchronizer | 0.5-1ms | 2ms |
| Application rendering | 5-10ms | 8ms |
| **Total** | **8-16ms** | **18.5ms** |

Remaining 2.5ms buffer for GC, platform jitter, etc.

## Extension Points

### Custom Channels

```dart
// Define new channel
bridge.publish('custom.gesture', SensorEvent(
  payload: {'gesture': 'swipe', 'direction': 'left'},
  confidence: 0.9,
  timestamp: DateTime.now().millisecondsSinceEpoch,
  source: 'gesture-recognizer',
));

// Subscribe to custom channel
bridge.subscribe('custom.gesture').listen((event) {
  // Handle custom event
});
```

### Custom QuaternionFieldService

```dart
class CustomQuaternionService extends QuaternionFieldService {
  @override
  double computeMotionEnergy(Quaternion quaternion, int timestamp) {
    // Custom motion energy computation
    return super.computeMotionEnergy(quaternion, timestamp) * 1.5;
  }
}
```

### Custom Synchronizer Mapping

```dart
class CustomSynchronizer extends ShaderQuaternionSynchronizer {
  void _applyNormalizedOrientation(...) {
    // Custom Euler → rotation mapping
    final customMapping = {
      'rot4dXY': euler.yaw * 3.0,  // Different scale
      'rot4dXW': euler.pitch + euler.roll,  // Combined
      // ...
    };

    onSystemUpdate?.call('custom', customMapping);
  }
}
```

## Testing Architecture

### Unit Testing Flow
```dart
// 1. Create mock session
final mockSession = MockARSession(bridge: bridge);

// 2. Subscribe to output
final snapshots = <QuaternionSnapshot>[];
quaternionService.stream.listen(snapshots.add);

// 3. Inject test data
mockSession.tick(Duration(milliseconds: 16));

// 4. Assert output
expect(snapshots.last.motionEnergy, greaterThan(0.0));
```

### Integration Testing
```dart
// Full pipeline test
final sdk = TestSDKFactory.createMockSDK();

sdk.mockSession.tick(Duration(milliseconds: 16));

final rotations = sdk.synchronizer.rotationState;
expect(rotations['rot4dXY'], isNotNull);
```

## Performance Monitoring

### Key Metrics

1. **Frame Processing Time**
   - Measure: Start of platform callback → onSystemUpdate invoked
   - Target: <10ms (60% of frame budget)

2. **Motion Energy Latency**
   - Measure: Quaternion change → motionEnergy update
   - Target: <2 frames (33ms)

3. **Memory Allocation**
   - Quaternion objects: Pool and reuse
   - Event history: Fixed ring buffer
   - Stream subscriptions: Properly disposed

### Monitoring Code

```dart
final stopwatch = Stopwatch()..start();

bridge.subscribe('spatial.pose').listen((event) {
  final t1 = stopwatch.elapsedMicroseconds;

  quaternionService.stream.listen((snapshot) {
    final t2 = stopwatch.elapsedMicroseconds;
    print('Pipeline latency: ${t2 - t1}μs');
  });
});
```

## Next Steps

- See [Performance Guidelines](../PERFORMANCE.md) for optimization strategies
- See [ARCore Integration](../guides/ARCORE_INTEGRATION.md) for platform specifics
- See [Testing Guide](../TESTING.md) for comprehensive testing approaches
