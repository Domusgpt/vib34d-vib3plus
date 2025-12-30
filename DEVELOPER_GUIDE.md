# VIB34D XR Quaternion SDK - Complete Developer Guide

> **For Human and AI Agent Developers**

This guide provides a complete overview of the VIB34D XR Quaternion SDK for Flutter, including architecture, best practices, and development workflows.

## 📚 Documentation Index

### Quick Start
- **[QUICKSTART.md](QUICKSTART.md)** - Get running in 5 minutes
- **[FLUTTER_README.md](FLUTTER_README.md)** - Complete API reference
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

### Integration Guides
- **[ARCore Integration](docs/guides/ARCORE_INTEGRATION.md)** - Android AR implementation
- **[ARKit Integration](docs/guides/ARKIT_INTEGRATION.md)** - iOS AR implementation

### Architecture & Design
- **[Quaternion Flow](docs/architecture/QUATERNION_FLOW.md)** - Data flow and architecture
- **[Performance Guide](docs/PERFORMANCE.md)** - Optimization strategies

### Contributing
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[analysis_options.yaml](analysis_options.yaml)** - Linting configuration

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────┐
│         Application Layer                │
│  (Your Flutter App + AR Framework)       │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│    VIB34D XR Quaternion SDK              │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │  SensoryInputBridge                │ │
│  │  - Channel-based pub/sub           │ │
│  │  - spatial.pose, spatial.anchors   │ │
│  └────────────┬───────────────────────┘ │
│               │                          │
│  ┌────────────▼───────────────────────┐ │
│  │  QuaternionFieldService            │ │
│  │  - State management                │ │
│  │  - Motion energy tracking          │ │
│  └────────────┬───────────────────────┘ │
│               │                          │
│  ┌────────────▼───────────────────────┐ │
│  │  ShaderQuaternionSynchronizer      │ │
│  │  - Euler → 6D rotation mapping     │ │
│  │  - Parameter smoothing             │ │
│  └────────────┬───────────────────────┘ │
│               │                          │
└───────────────┼──────────────────────────┘
                │
                ▼
        Map<String, double>
        {
          rot4dXY: 0.523,
          rot4dXZ: -0.234,
          rot4dYZ: 0.891,
          rot4dXW: 0.123,
          rot4dYW: -0.456,
          rot4dZW: 0.789
        }
```

## 🔧 Module Structure

### Core Modules

#### 1. Quaternion Utilities (`lib/src/core/quaternion.dart`)
```dart
// Normalize quaternion
final q = QuaternionUtils.normalize(inputQ);

// Convert to Euler
final euler = QuaternionUtils.toEuler(q);

// Quaternion arithmetic
final product = QuaternionUtils.multiply(q1, q2);
final inverse = QuaternionUtils.conjugate(q);

// Interpolation
final lerped = QuaternionUtils.lerp(q1, q2, 0.5);
final slerped = QuaternionUtils.slerp(q1, q2, 0.5);
```

#### 2. QuaternionFieldService (`lib/src/core/quaternion_field_service.dart`)
```dart
final service = QuaternionFieldService(
  energySmoothing: 0.35,   // Motion smoothing (0-1)
  velocityReference: 8.0,  // Velocity for 100% energy (rad/s)
);

// Subscribe to updates
service.stream.listen((snapshot) {
  print('Quaternion: ${snapshot.primaryQuaternion}');
  print('Euler: ${snapshot.euler}');
  print('Motion Energy: ${snapshot.motionEnergy}');
  print('Confidence: ${snapshot.confidence}');
});

// Ingest AR tracking data
service.ingestPrimaryQuaternion(
  quaternion,
  timestamp: timestamp,
  confidence: confidence,
  position: position,
);
```

#### 3. Geometry Library (`lib/src/geometry/geometry_library.dart`)
```dart
// 24 geometries: 8 base × 3 cores
// Base: Tetrahedron, Hypercube, Sphere, Torus, Klein Bottle, Fractal, Wave, Crystal
// Cores: Hypercube, Hypersphere, Hypertetra

// Get metadata
final metadata = GeometryLibrary.describeGeometry(12);
print('${metadata.name}');          // "SPHERE • HYPERSPHERE CORE"
print('Base: ${metadata.baseName}'); // "SPHERE"
print('Core: ${metadata.coreName}'); // "HYPERSPHERE CORE"

// Get rendering parameters
final params = GeometryLibrary.getVariationParameters(12, level: 1);
print('Grid: ${params.gridDensity}');    // Procedurally generated
print('Morph: ${params.morphFactor}');
print('Chaos: ${params.chaos}');
print('Speed: ${params.speed}');
print('Hue: ${params.hue}');

// List all
for (final geo in GeometryLibrary.listGeometryMetadata()) {
  print('${geo.index}: ${geo.name}');
}
```

#### 4. Sensory Input Bridge (`lib/src/sensors/sensory_input_bridge.dart`)
```dart
final bridge = SensoryInputBridge(channelHistoryLimit: 12);

// Publish XR pose
bridge.publishPose(
  orientation: Quaternion(x, y, z, w),
  position: Vector3(x, y, z),
  confidence: 0.95,
  source: 'arcore',
);

// Subscribe to channel
bridge.subscribe('spatial.pose').listen((event) {
  print('Received: ${event.payload}');
  print('Confidence: ${event.confidence}');
  print('Source: ${event.source}');
});

// Get history
final history = bridge.getHistory('spatial.pose');
```

#### 5. Shader Synchronizer (`lib/src/visualization/shader_quaternion_synchronizer.dart`)
```dart
final synchronizer = ShaderQuaternionSynchronizer(
  bridge: bridge,
  quaternionService: quaternionService,
  rotationScale: 2.0,      // Amplification factor
  minConfidence: 0.45,     // Threshold for smoothing
  baseAlpha: 0.25,         // Min interpolation factor
  onSystemUpdate: (system, params) {
    // Receive 4D rotation parameters
    updateVisualization(params);
  },
);

synchronizer.start();

// Get current state
final rotations = synchronizer.rotationState;
```

### Test Utilities (`lib/src/test_utils/test_utils.dart`)

```dart
import 'package:vib34d_xr_quaternion_sdk/src/test_utils/test_utils.dart';

// Create mock AR session
final mockSession = MockARSession(
  bridge: bridge,
  rotationSpeed: 1.0,
  positionRadius: 2.0,
);

// Simulate frames
mockSession.tick(Duration(milliseconds: 16));

// Create full SDK for testing
final sdk = TestSDKFactory.createMockSDK(
  energySmoothing: 0.35,
  onSystemUpdate: (system, params) {
    print('Update: $params');
  },
);

// Use SDK
sdk.mockSession.tick(Duration(milliseconds: 16));

// Cleanup
TestSDKFactory.dispose(
  bridge: sdk.bridge,
  quaternionService: sdk.quaternionService,
  synchronizer: sdk.synchronizer,
);

// Assertions
QuaternionAssertions.assertNormalized(quaternion);
QuaternionAssertions.assertQuaternionEquals(actual, expected);
QuaternionAssertions.assertEulerEquals(actual, expected);
```

## 🎯 Common Use Cases

### 1. Basic AR Tracking Integration

```dart
class ARTrackingWidget extends StatefulWidget {
  @override
  State createState() => _ARTrackingWidgetState();
}

class _ARTrackingWidgetState extends State<ARTrackingWidget> {
  late SensoryInputBridge _bridge;
  late QuaternionFieldService _quaternionService;
  late ShaderQuaternionSynchronizer _synchronizer;

  @override
  void initState() {
    super.initState();

    _bridge = SensoryInputBridge();
    _quaternionService = QuaternionFieldService();
    _synchronizer = ShaderQuaternionSynchronizer(
      bridge: _bridge,
      quaternionService: _quaternionService,
      onSystemUpdate: _handleUpdate,
    );

    _synchronizer.start();
  }

  void _handleUpdate(String system, Map<String, double> params) {
    setState(() {
      // Update your visualization
    });
  }

  @override
  void dispose() {
    _synchronizer.dispose();
    _quaternionService.dispose();
    _bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Your UI
  }
}
```

### 2. Custom Geometry Renderer

```dart
class GeometryRenderer extends StatefulWidget {
  final int geometryIndex;

  GeometryRenderer({required this.geometryIndex});

  @override
  State createState() => _GeometryRendererState();
}

class _GeometryRendererState extends State<GeometryRenderer> {
  late Map<String, double> _rotations;

  @override
  Widget build(BuildContext context) {
    final metadata = GeometryLibrary.describeGeometry(widget.geometryIndex);
    final params = GeometryLibrary.getVariationParameters(widget.geometryIndex, 1);

    return CustomPaint(
      painter: FourDGeometryPainter(
        rotations: _rotations,
        gridDensity: params.gridDensity,
        morphFactor: params.morphFactor,
        hue: params.hue,
      ),
    );
  }
}
```

### 3. Performance Monitoring

```dart
class PerformanceMonitor {
  final Stopwatch _stopwatch = Stopwatch();

  void onFrameStart() => _stopwatch.start();

  void onFrameEnd() {
    _stopwatch.stop();
    final ms = _stopwatch.elapsedMicroseconds / 1000.0;

    if (ms > 16.67) {
      print('⚠️  Slow frame: ${ms.toStringAsFixed(2)}ms');
    }

    _stopwatch.reset();
  }
}
```

## 🧪 Testing Strategies

### Unit Tests

```dart
test('quaternion normalization', () {
  final q = Quaternion(1.0, 2.0, 3.0, 4.0);
  final normalized = QuaternionUtils.normalize(q);

  expect(normalized.length, closeTo(1.0, 0.0001));
});
```

### Integration Tests

```dart
test('full pipeline', () async {
  final sdk = TestSDKFactory.createMockSDK();

  final snapshots = <QuaternionSnapshot>[];
  sdk.quaternionService.stream.listen(snapshots.add);

  sdk.mockSession.tick(Duration(milliseconds: 16));

  await Future.delayed(Duration(milliseconds: 50));

  expect(snapshots, isNotEmpty);
  expect(snapshots.last.motionEnergy, greaterThanOrEqualTo(0.0));

  TestSDKFactory.dispose(
    bridge: sdk.bridge,
    quaternionService: sdk.quaternionService,
    synchronizer: sdk.synchronizer,
  );
});
```

### Widget Tests

```dart
testWidgets('AR widget displays rotations', (tester) async {
  await tester.pumpWidget(MyARWidget());

  // Simulate AR update
  final widget = tester.widget<MyARWidget>(find.byType(MyARWidget));
  widget.updateRotations({'rot4dXY': 1.23});

  await tester.pump();

  expect(find.text('1.230'), findsOneWidget);
});
```

## 📊 Performance Best Practices

### 1. Throttle Updates

```dart
// Process every 2nd frame for 30 FPS instead of 60 FPS
int _frameCount = 0;

void onARFrame(Quaternion q) {
  _frameCount++;
  if (_frameCount % 2 != 0) return;

  _bridge.publishPose(orientation: q);
}
```

### 2. Object Pooling

```dart
final _quaternionPool = QuaternionPool(maxSize: 100);

void processFrame() {
  final q = _quaternionPool.acquire();
  try {
    // Use quaternion
  } finally {
    _quaternionPool.release(q);
  }
}
```

### 3. Lazy Loading

```dart
// Only load geometry when needed
final metadata = LazyGeometryLibrary.describe(index);
```

### 4. Disable Features You Don't Need

```dart
// No history in production
final bridge = SensoryInputBridge(
  channelHistoryLimit: kDebugMode ? 12 : 0,
);
```

## 🤖 For AI Agent Developers

### Clear Module Boundaries

Each module has a single responsibility:
- `core/` - Pure quaternion mathematics
- `geometry/` - Geometry definitions only
- `sensors/` - XR sensor integration
- `visualization/` - Visualization adapters

### Type Contracts

All public APIs are strongly typed:

```dart
// ✅ Type-safe
Quaternion normalize(Quaternion? q);

// ❌ Avoid dynamic
dynamic process(dynamic input);
```

### Extension Points

```dart
// Extend base classes for custom behavior
class CustomQuaternionService extends QuaternionFieldService {
  @override
  double computeMotionEnergy(Quaternion q, int timestamp) {
    return super.computeMotionEnergy(q, timestamp) * customFactor;
  }
}
```

### Test Helpers

```dart
// Use provided test utilities
final sdk = TestSDKFactory.createMockSDK();
sdk.mockSession.publishAnchors(5);  // 5 random anchors
```

### Documentation Templates

Follow the template in CONTRIBUTING.md for consistent documentation.

## 🚀 CI/CD Pipeline

The project includes comprehensive CI/CD:

```yaml
# .github/workflows/flutter_ci.yml

✅ Analyze and Lint
✅ Run Tests with Coverage
✅ Test Example App
✅ Integration Tests
✅ Build Android APK
✅ Build iOS (no codesign)
✅ Performance Benchmarks
✅ Publish Dry Run
✅ Generate Documentation
```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android (ARCore) | ✅ Ready | API 24+ |
| iOS (ARKit) | ✅ Ready | iOS 13.0+ |
| Desktop | ✅ Simulation | No AR hardware |
| Web | ✅ Simulation | No AR hardware |

## 🔜 Roadmap

### Short Term
- [ ] Add CustomPainter examples for 4D rendering
- [ ] Create video tutorials
- [ ] Add more geometry presets
- [ ] Benchmark on low-end devices

### Medium Term
- [ ] WebXR integration guide
- [ ] Unity plugin bridge
- [ ] VR headset support (Quest, Vive)
- [ ] Multiplayer synchronization

### Long Term
- [ ] Machine learning integration
- [ ] Cloud anchors support
- [ ] Advanced physics simulation
- [ ] Commercial licensing tiers

## 📞 Support

- **Issues**: https://github.com/Domusgpt/vib34d-vib3plus/issues
- **Discussions**: https://github.com/Domusgpt/vib34d-vib3plus/discussions
- **Email**: Paul@clearseassolutions.com
- **Website**: https://parserator.com

## 📄 License

See [LICENSE_ATTESTATION_PROFILE_CATALOG.md](DOCS/LICENSE_ATTESTATION_PROFILE_CATALOG.md)

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**
**Pioneering 4D Geometric Processing & XR Spatial Intelligence**

🌟 **Happy Building!** 🌟
