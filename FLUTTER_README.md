# VIB34D XR Quaternion SDK for Flutter

**4D Geometric Processing with XR Quaternion Integration**

A Flutter/Dart port of the VIB34D XR Quaternion SDK, providing advanced quaternion mathematics and spatial computing capabilities for Flutter applications using ARCore, ARKit, and other XR frameworks.

## Features

### Core Quaternion & 4D Math
- **Quaternion Mathematics**: Full quaternion algebra for XR rotations and 4D transformations
- **Quaternion Field Service**: Observable quaternion state management with motion energy tracking
- **Euler Conversion**: Bidirectional conversion between quaternions and Euler angles
- **4D Rotation Support**: Six-plane rotation parameters (XY, XZ, YZ, XW, YW, ZW)

### Geometry Library
- **8 Base Geometries**: Tetrahedron, Hypercube, Sphere, Torus, Klein Bottle, Fractal, Wave, Crystal
- **3 Core Variants**: Hypercube Core, Hypersphere Core, Hypertetra Core
- **24 Total Combinations**: Each base geometry × each core variant
- **Variation Parameters**: Procedural parameter generation for different geometry levels

### XR Integration Layer
- **Sensory Input Bridge**: Normalizes AR/VR pose tracking data into semantic channels
- **Shader Quaternion Synchronizer**: Bridges XR sensor data to visualization parameters
- **Motion Energy Tracking**: Smoothed angular velocity computation for reactive visualizations
- **Channel-Based Architecture**: Subscribe to spatial.pose, spatial.anchors, spatial.hit-tests

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  vib34d_xr_quaternion_sdk:
    git:
      url: https://github.com/Domusgpt/vib34d-xr-quaternion-sdk.git
      ref: claude/add-flutter-dart-support-01WiDt1H7XB1FTsuQy3i2jZa
  vector_math: ^2.1.4
```

## Quick Start

### Basic Quaternion Usage

```dart
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

// Normalize a quaternion
final q = Quaternion(1.0, 2.0, 3.0, 4.0);
final normalized = QuaternionUtils.normalize(q);

// Convert to Euler angles
final euler = QuaternionUtils.toEuler(normalized);
print('Roll: ${euler.roll}, Pitch: ${euler.pitch}, Yaw: ${euler.yaw}');

// Multiply quaternions
final q1 = Quaternion(0.0, 0.1, 0.0, 1.0);
final q2 = Quaternion(0.1, 0.0, 0.0, 1.0);
final result = QuaternionUtils.multiply(q1, q2);
```

### Geometry Library

```dart
// Get geometry metadata
final metadata = GeometryLibrary.describeGeometry(5);
print('${metadata.name}: ${metadata.baseName} • ${metadata.coreName}');

// Resolve geometry by components
final sphereHypersphere = GeometryLibrary.resolveGeometryIndex(
  baseKey: 'sphere',
  coreKey: 'hypersphere-core',
);

// Get variation parameters
final params = GeometryLibrary.getVariationParameters(sphereHypersphere, 1);
print('Grid: ${params.gridDensity}, Morph: ${params.morphFactor}');

// List all 24 geometries
final allGeometries = GeometryLibrary.listGeometryMetadata();
for (final geo in allGeometries) {
  print('${geo.index}: ${geo.name}');
}
```

### XR Sensor Integration

```dart
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

// Create sensor bridge
final bridge = SensoryInputBridge(channelHistoryLimit: 12);

// Create quaternion field service
final quaternionService = QuaternionFieldService(
  energySmoothing: 0.35,
  velocityReference: 8.0,
);

// Subscribe to quaternion updates
quaternionService.stream.listen((snapshot) {
  print('Quaternion: ${snapshot.primaryQuaternion}');
  print('Motion Energy: ${snapshot.motionEnergy}');
  print('Euler: ${snapshot.euler}');
});

// Create synchronizer
final synchronizer = ShaderQuaternionSynchronizer(
  bridge: bridge,
  quaternionService: quaternionService,
  rotationScale: 2.0,
  onSystemUpdate: (system, parameters) {
    print('System $system updated: $parameters');
  },
);

// Start listening
synchronizer.start();

// Publish AR tracking data (from ARCore/ARKit)
bridge.publishPose(
  orientation: arPose.orientation,
  position: arPose.position,
  confidence: arPose.confidence,
  source: 'arcore',
);
```

### Complete Integration Example

```dart
class XRVisualizerWidget extends StatefulWidget {
  @override
  State<XRVisualizerWidget> createState() => _XRVisualizerWidgetState();
}

class _XRVisualizerWidgetState extends State<XRVisualizerWidget> {
  late SensoryInputBridge _bridge;
  late QuaternionFieldService _quaternionService;
  late ShaderQuaternionSynchronizer _synchronizer;

  Map<String, double> _rotationParameters = {};
  int _currentGeometry = 0;

  @override
  void initState() {
    super.initState();

    // Initialize SDK
    _bridge = SensoryInputBridge();
    _quaternionService = QuaternionFieldService();
    _synchronizer = ShaderQuaternionSynchronizer(
      bridge: _bridge,
      quaternionService: _quaternionService,
      onSystemUpdate: _handleSystemUpdate,
    );

    _synchronizer.start();

    // Subscribe to AR tracking updates
    _subscribeToARTracking();
  }

  void _handleSystemUpdate(String system, Map<String, double> parameters) {
    setState(() {
      _rotationParameters = parameters;
    });
    // Update your custom renderer with new rotation parameters
  }

  void _subscribeToARTracking() {
    // Example: Connect to ARCore/ARKit and forward poses
    // arSession.poseStream.listen((pose) {
    //   _bridge.publishPose(
    //     orientation: pose.orientation,
    //     position: pose.position,
    //     confidence: pose.trackingConfidence,
    //   );
    // });
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
    final metadata = GeometryLibrary.describeGeometry(_currentGeometry);
    final params = GeometryLibrary.getVariationParameters(_currentGeometry, 1);

    return Column(
      children: [
        Text('Current Geometry: ${metadata?.name}'),
        Text('4D Rotation XY: ${_rotationParameters['rot4dXY']?.toStringAsFixed(3)}'),
        // Render your 4D geometry using the parameters
      ],
    );
  }
}
```

## API Reference

### QuaternionUtils

- `normalize(Quaternion? q)` - Normalize quaternion to unit length
- `toEuler(Quaternion q)` - Convert quaternion to Euler angles
- `multiply(Quaternion a, Quaternion b)` - Multiply two quaternions
- `conjugate(Quaternion q)` - Get conjugate (inverse rotation)
- `lerp(Quaternion start, Quaternion end, double alpha)` - Linear interpolation
- `slerp(Quaternion start, Quaternion end, double alpha)` - Spherical linear interpolation

### QuaternionFieldService

- `ingestPrimaryQuaternion(...)` - Ingest primary orientation from XR sensor
- `ingestSecondaryQuaternion(...)` - Ingest secondary sensor data
- `ingestPose(...)` - Ingest complete pose (orientation + position)
- `stream` - Stream of `QuaternionSnapshot` updates
- `snapshot` - Get current state snapshot

### GeometryLibrary

- `baseGeometries` - List of 8 base geometries
- `coreVariants` - List of 3 core variants
- `resolveGeometryIndex(...)` - Resolve geometry index from criteria
- `describeGeometry(int index)` - Get metadata for geometry
- `getVariationParameters(int geometryType, int level)` - Get rendering parameters
- `listGeometryMetadata()` - List all 24 geometry metadata entries

### SensoryInputBridge

- `subscribe(String channel)` - Subscribe to sensor channel stream
- `publishPose(...)` - Publish spatial pose data
- `publishSpatialAnchors(...)` - Publish spatial anchor data
- `publishHitTests(...)` - Publish hit test results

### ShaderQuaternionSynchronizer

- `start()` - Start listening to sensor channels
- `stop()` - Stop listening
- `setEnabled(bool enabled)` - Enable/disable synchronization
- `rotationState` - Get current 4D rotation parameters

## Sensor Channels

The SDK provides three main sensor channels:

- **`spatial.pose`** - Primary XR device pose (orientation + position)
- **`spatial.anchors`** - Spatial anchors with pose and confidence
- **`spatial.hit-tests`** - Raycast hit test results

## Testing

Run tests:

```bash
flutter test
```

The SDK includes comprehensive tests for:
- Quaternion operations and conversions
- Geometry library functionality
- Quaternion field service state management
- Sensor bridge channel routing

## Example App

See `example/` directory for a complete Flutter app demonstrating:
- SDK initialization and configuration
- Simulated AR tracking data
- Real-time quaternion-to-rotation conversion
- Geometry selection and parameter display
- Motion energy visualization

Run the example:

```bash
cd example
flutter run
```

## Platform Support

- **Android**: ARCore integration ready
- **iOS**: ARKit integration ready
- **Desktop/Web**: Simulated sensor data supported

## Architecture

```
lib/
├── src/
│   ├── core/
│   │   ├── quaternion.dart                 # Quaternion utilities
│   │   └── quaternion_field_service.dart   # State management
│   ├── geometry/
│   │   └── geometry_library.dart           # 4D geometry definitions
│   ├── sensors/
│   │   └── sensory_input_bridge.dart       # XR sensor integration
│   └── visualization/
│       └── shader_quaternion_synchronizer.dart  # Sensor-to-shader bridge
└── vib34d_xr_quaternion_sdk.dart          # Main export
```

## License

See `DOCS/LICENSE_ATTESTATION_PROFILE_CATALOG.md` for licensing options.

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**
**All Rights Reserved - Proprietary Technology**

**Pioneering 4D Geometric Processing & XR Spatial Intelligence**
