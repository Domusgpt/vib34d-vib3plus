# VIB34D XR Quaternion SDK - Quick Start

Get up and running with the VIB34D XR Quaternion SDK in 5 minutes.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  vib34d_xr_quaternion_sdk:
    git:
      url: https://github.com/Domusgpt/vib34d-vib3plus.git
      ref: claude/add-flutter-dart-support-01WiDt1H7XB1FTsuQy3i2jZa
  vector_math: ^2.1.4
```

Then run:

```bash
flutter pub get
```

## Basic Usage (3 Steps)

### Step 1: Import the SDK

```dart
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
```

### Step 2: Create SDK Components

```dart
// Sensor bridge for XR data
final bridge = SensoryInputBridge();

// Quaternion service for state management
final quaternionService = QuaternionFieldService(
  energySmoothing: 0.35,
  velocityReference: 8.0,
);

// Synchronizer to convert quaternions to 4D rotations
final synchronizer = ShaderQuaternionSynchronizer(
  bridge: bridge,
  quaternionService: quaternionService,
  onSystemUpdate: (system, parameters) {
    print('4D Rotations: $parameters');
  },
);

// Start listening
synchronizer.start();
```

### Step 3: Feed AR Tracking Data

```dart
// From ARCore/ARKit or simulated
bridge.publishPose(
  orientation: Quaternion(x, y, z, w),
  position: Vector3(x, y, z),
  confidence: 0.95,
  source: 'arcore',
);
```

That's it! You'll receive 4D rotation parameters in the `onSystemUpdate` callback.

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
import 'dart:math' as math;

void main() => runApp(QuaternionApp());

class QuaternionApp extends StatefulWidget {
  @override
  State<QuaternionApp> createState() => _QuaternionAppState();
}

class _QuaternionAppState extends State<QuaternionApp> {
  late SensoryInputBridge _bridge;
  late QuaternionFieldService _quaternionService;
  late ShaderQuaternionSynchronizer _synchronizer;

  Map<String, double> _rotations = {};
  double _motionEnergy = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize SDK
    _bridge = SensoryInputBridge();
    _quaternionService = QuaternionFieldService();
    _synchronizer = ShaderQuaternionSynchronizer(
      bridge: _bridge,
      quaternionService: _quaternionService,
      onSystemUpdate: (_, params) {
        setState(() => _rotations = params);
      },
    );

    _synchronizer.start();

    // Subscribe to motion energy
    _quaternionService.stream.listen((snapshot) {
      setState(() => _motionEnergy = snapshot.motionEnergy);
    });

    // Simulate AR tracking (replace with real AR in production)
    _simulateAR();
  }

  void _simulateAR() {
    var time = 0.0;
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 16));

      // Simulate rotating device
      final roll = math.sin(time * 0.5) * 0.3;
      final pitch = math.cos(time * 0.7) * 0.4;
      final yaw = math.sin(time * 0.3) * 0.5;

      // Convert to quaternion
      final q = _eulerToQuaternion(roll, pitch, yaw);

      // Publish to SDK
      _bridge.publishPose(
        orientation: q,
        position: Vector3(0, 1.5, -2),
        confidence: 0.85,
      );

      time += 0.016;
      return mounted;
    });
  }

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

  @override
  void dispose() {
    _synchronizer.dispose();
    _quaternionService.dispose();
    _bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('VIB34D Quick Start')),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('4D Rotation Parameters:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ..._rotations.entries.map((e) => Text(
                    '${e.key}: ${e.value.toStringAsFixed(3)}',
                    style: TextStyle(fontFamily: 'monospace'),
                  )),
              SizedBox(height: 16),
              Text('Motion Energy:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              LinearProgressIndicator(value: _motionEnergy),
              Text('${(_motionEnergy * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Using with Real AR

### ARCore (Android)

```dart
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';

arCoreController.onPoseReceived = (Matrix4 pose) {
  final quaternion = _matrixToQuaternion(pose);
  final position = Vector3(pose[12], pose[13], pose[14]);

  bridge.publishPose(
    orientation: quaternion,
    position: position,
    confidence: 0.9,
    source: 'arcore',
  );
};
```

See [ARCore Integration Guide](docs/guides/ARCORE_INTEGRATION.md) for complete example.

### ARKit (iOS)

```dart
import 'package:arkit_plugin/arkit_plugin.dart';

arkitController.onUpdateFrame = (ARKitFrame frame) {
  final transform = frame.camera.transform;
  final quaternion = _matrix4ToQuaternion(transform);
  final position = Vector3(transform[12], transform[13], transform[14]);

  bridge.publishPose(
    orientation: quaternion,
    position: position,
    confidence: 0.95,
    source: 'arkit',
  );
};
```

See [ARKit Integration Guide](docs/guides/ARKIT_INTEGRATION.md) for complete example.

## Geometry Library

Access 24 predefined 4D geometries:

```dart
// Get geometry metadata
final metadata = GeometryLibrary.describeGeometry(5);
print('${metadata.name}');  // "TORUS"

// Get rendering parameters
final params = GeometryLibrary.getVariationParameters(5, level: 1);
print('Grid density: ${params.gridDensity}');
print('Morph factor: ${params.morphFactor}');
print('Hue: ${params.hue}');

// List all geometries
final allGeometries = GeometryLibrary.listGeometryMetadata();
for (final geo in allGeometries) {
  print('${geo.index}: ${geo.name}');
}
```

## Testing Your Integration

Use mock AR session for testing:

```dart
import 'package:vib34d_xr_quaternion_sdk/src/test_utils/test_utils.dart';

void main() {
  test('quaternion pipeline works', () {
    final sdk = TestSDKFactory.createMockSDK();

    // Simulate AR frame
    sdk.mockSession.tick(Duration(milliseconds: 16));

    // Verify quaternion propagation
    expect(sdk.synchronizer.rotationState, isNotEmpty);
    expect(sdk.synchronizer.rotationState['rot4dXY'], isNotNull);

    // Cleanup
    TestSDKFactory.dispose(
      bridge: sdk.bridge,
      quaternionService: sdk.quaternionService,
      synchronizer: sdk.synchronizer,
    );
  });
}
```

## Next Steps

### Learn More
- [Flutter README](FLUTTER_README.md) - Complete API reference
- [ARCore Integration](docs/guides/ARCORE_INTEGRATION.md) - Android AR setup
- [ARKit Integration](docs/guides/ARKIT_INTEGRATION.md) - iOS AR setup
- [Architecture](docs/architecture/QUATERNION_FLOW.md) - Data flow details
- [Performance](docs/PERFORMANCE.md) - Optimization strategies

### Run Example App
```bash
cd example
flutter run
```

### Get Help
- Issues: https://github.com/Domusgpt/vib34d-vib3plus/issues
- Email: Paul@clearseassolutions.com

---

**You're ready to build amazing XR experiences!** 🚀
