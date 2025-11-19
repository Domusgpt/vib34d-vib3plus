# ARKit Integration Guide

Complete guide for integrating VIB34D XR Quaternion SDK with Apple ARKit on iOS.

## Prerequisites

- Flutter 3.10+
- Xcode 14+
- Physical iOS device (iOS 13.0+)
- `arkit_plugin` or `ar_flutter_plugin`

## Installation

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  vib34d_xr_quaternion_sdk:
    git:
      url: https://github.com/Domusgpt/vib34d-xr-quaternion-sdk.git
      ref: claude/add-flutter-dart-support-01WiDt1H7XB1FTsuQy3i2jZa
  arkit_plugin: ^1.0.6  # or ar_flutter_plugin
  vector_math: ^2.1.4
```

### 2. iOS Permissions

```xml
<!-- ios/Runner/Info.plist -->
<dict>
  <key>NSCameraUsageDescription</key>
  <string>This app needs camera access for AR features</string>

  <key>io.flutter.embedded_views_preview</key>
  <true/>
</dict>
```

### 3. Minimum iOS Version

```ruby
# ios/Podfile
platform :ios, '13.0'
```

## Basic Integration

### Complete Example with ARKit

```dart
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
import 'dart:math' as math;

class ARKitQuaternionView extends StatefulWidget {
  @override
  State<ARKitQuaternionView> createState() => _ARKitQuaternionViewState();
}

class _ARKitQuaternionViewState extends State<ARKitQuaternionView> {
  late ARKitController arkitController;

  // VIB34D SDK components
  late SensoryInputBridge _bridge;
  late QuaternionFieldService _quaternionService;
  late ShaderQuaternionSynchronizer _synchronizer;

  Map<String, double> _currentRotations = {};
  int _currentGeometry = 0;
  double _motionEnergy = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  void _initializeSDK() {
    _bridge = SensoryInputBridge(channelHistoryLimit: 12);

    _quaternionService = QuaternionFieldService(
      energySmoothing: 0.35,
      velocityReference: 8.0,
    );

    _synchronizer = ShaderQuaternionSynchronizer(
      bridge: _bridge,
      quaternionService: _quaternionService,
      rotationScale: 2.0,
      onSystemUpdate: _handleSystemUpdate,
    );

    _synchronizer.start();

    // Subscribe to quaternion updates
    _quaternionService.stream.listen((snapshot) {
      setState(() {
        _motionEnergy = snapshot.motionEnergy;
      });
    });
  }

  void _handleSystemUpdate(String system, Map<String, double> parameters) {
    setState(() {
      _currentRotations = parameters;
    });
    _updateVisualization(parameters);
  }

  void _updateVisualization(Map<String, double> parameters) {
    final metadata = GeometryLibrary.describeGeometry(_currentGeometry);
    final varParams = GeometryLibrary.getVariationParameters(_currentGeometry, 1);

    print('Updating ${metadata?.name} with rotations: $parameters');
    // Update your rendering here
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;

    // Configure ARKit session
    this.arkitController.onARKitReady = () {
      _setupARKitTracking();
    };
  }

  void _setupARKitTracking() {
    // Subscribe to camera transform updates (every frame)
    arkitController.onCameraDidChangeTrackingState = (camera, trackingState) {
      print('ARKit tracking state: $trackingState');
    };

    // Get camera updates
    arkitController.onUpdateFrame = (ARKitFrame frame) {
      _processARKitFrame(frame);
    };

    // Handle plane detection
    arkitController.onAddNodeForAnchor = (ARKitAnchor anchor) {
      if (anchor is ARKitPlaneAnchor) {
        _handlePlaneAnchor(anchor);
      }
    };

    arkitController.onUpdateNodeForAnchor = (ARKitAnchor anchor) {
      if (anchor is ARKitPlaneAnchor) {
        _handlePlaneAnchor(anchor);
      }
    };
  }

  void _processARKitFrame(ARKitFrame frame) {
    // Extract camera pose
    final camera = frame.camera;

    // ARKit provides transform as 4x4 matrix
    final transform = camera.transform;

    // Convert to quaternion and position
    final quaternion = _matrix4ToQuaternion(transform);
    final position = Vector3(
      transform[12],
      transform[13],
      transform[14],
    );

    // Get tracking state confidence
    double confidence;
    switch (camera.trackingState) {
      case ARKitTrackingState.normal:
        confidence = 0.95;
        break;
      case ARKitTrackingState.limited:
        confidence = 0.6;
        break;
      case ARKitTrackingState.notAvailable:
        confidence = 0.2;
        break;
    }

    // Publish to VIB34D SDK
    _bridge.publishPose(
      orientation: quaternion,
      position: position,
      confidence: confidence,
      source: 'arkit-camera',
    );
  }

  void _handlePlaneAnchor(ARKitPlaneAnchor anchor) {
    final transform = anchor.transform;
    final quaternion = _matrix4ToQuaternion(transform);
    final position = Vector3(
      transform[12],
      transform[13],
      transform[14],
    );

    // Publish plane as spatial anchor
    _bridge.publishSpatialAnchors(
      anchors: [
        XRPose(
          orientation: quaternion,
          position: position,
          confidence: 0.9,
        ),
      ],
      confidence: 0.85,
      source: 'arkit-plane',
    );
  }

  Quaternion _matrix4ToQuaternion(List<double> m) {
    // ARKit provides column-major 4x4 matrix
    // Extract rotation quaternion
    final m00 = m[0], m01 = m[4], m02 = m[8];
    final m10 = m[1], m11 = m[5], m12 = m[9];
    final m20 = m[2], m21 = m[6], m22 = m[10];

    final trace = m00 + m11 + m22;
    double x, y, z, w;

    if (trace > 0) {
      final s = 0.5 / math.sqrt(trace + 1.0);
      w = 0.25 / s;
      x = (m21 - m12) * s;
      y = (m02 - m20) * s;
      z = (m10 - m01) * s;
    } else if (m00 > m11 && m00 > m22) {
      final s = 2.0 * math.sqrt(1.0 + m00 - m11 - m22);
      w = (m21 - m12) / s;
      x = 0.25 * s;
      y = (m01 + m10) / s;
      z = (m02 + m20) / s;
    } else if (m11 > m22) {
      final s = 2.0 * math.sqrt(1.0 + m11 - m00 - m22);
      w = (m02 - m20) / s;
      x = (m01 + m10) / s;
      y = 0.25 * s;
      z = (m12 + m21) / s;
    } else {
      final s = 2.0 * math.sqrt(1.0 + m22 - m00 - m11);
      w = (m10 - m01) / s;
      x = (m02 + m20) / s;
      y = (m12 + m21) / s;
      z = 0.25 * s;
    }

    return Quaternion(x, y, z, w);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ARKit + VIB34D'),
      ),
      body: Stack(
        children: [
          ARKitSceneView(
            onARKitViewCreated: onARKitViewCreated,
            planeDetection: ARPlaneDetection.horizontal,
            enableTapRecognizer: true,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.black87,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GeometryLibrary.getGeometryName(_currentGeometry),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4D Rotation Parameters:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    ...['rot4dXY', 'rot4dXZ', 'rot4dYZ', 'rot4dXW', 'rot4dYW', 'rot4dZW']
                        .map((param) => Text(
                              '$param: ${_currentRotations[param]?.toStringAsFixed(3) ?? '0.000'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            )),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _motionEnergy,
                      backgroundColor: Colors.white30,
                    ),
                    Text(
                      'Motion Energy: ${(_motionEnergy * 100).toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  onPressed: () {
                    setState(() {
                      _currentGeometry = (_currentGeometry - 1 + 24) % 24;
                    });
                  },
                  child: Icon(Icons.arrow_back),
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'next',
                  onPressed: () {
                    setState(() {
                      _currentGeometry = (_currentGeometry + 1) % 24;
                    });
                  },
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    arkitController.dispose();
    _synchronizer.dispose();
    _quaternionService.dispose();
    _bridge.dispose();
    super.dispose();
  }
}
```

## Advanced Features

### Face Tracking

```dart
void _setupFaceTracking() {
  arkitController.onFaceGeometryUpdate = (ARKitFaceGeometry faceGeometry) {
    // Get face orientation
    final quaternion = _matrix4ToQuaternion(faceGeometry.transform);

    _bridge.publishPose(
      orientation: quaternion,
      position: Vector3.zero(),
      confidence: 0.95,
      source: 'arkit-face',
    );
  };
}
```

### Image Tracking

```dart
void _setupImageTracking() {
  arkitController.onAddNodeForAnchor = (ARKitAnchor anchor) {
    if (anchor is ARKitImageAnchor) {
      final quaternion = _matrix4ToQuaternion(anchor.transform);
      final position = Vector3(
        anchor.transform[12],
        anchor.transform[13],
        anchor.transform[14],
      );

      _bridge.publishPose(
        orientation: quaternion,
        position: position,
        confidence: 0.9,
        source: 'arkit-image-${anchor.referenceImageName}',
      );
    }
  };
}
```

### World Mapping

```dart
void _saveWorldMap() async {
  final worldMap = await arkitController.getCurrentWorldMap();
  // Save worldMap for later sessions
}

void _loadWorldMap(ARWorldMap worldMap) async {
  await arkitController.loadWorldMap(worldMap);
}
```

## Performance Tips

1. **Limit Frame Rate**
```dart
// Process every 3rd frame for better performance
int _frameCount = 0;

void _processARKitFrame(ARKitFrame frame) {
  _frameCount++;
  if (_frameCount % 3 != 0) return;

  // Process frame...
}
```

2. **Use Appropriate Tracking Configuration**
```dart
// For face tracking only
arkitController.configuration = ARKitWorldTrackingConfiguration.faceTracking;

// For world tracking with planes
arkitController.configuration = ARKitWorldTrackingConfiguration.worldTracking(
  planeDetection: ARPlaneDetection.horizontal,
);
```

3. **Optimize Geometry Level**
```dart
// Use lower geometry level on older devices
final deviceGeneration = await getDeviceGeneration();
final level = deviceGeneration > 12 ? 1 : 0;  // iPhone 12+ can handle level 1

final params = GeometryLibrary.getVariationParameters(_currentGeometry, level);
```

## Troubleshooting

### ARKit Not Supported
```dart
bool isARKitSupported = await arkitController.checkDeviceSupport();
if (!isARKitSupported) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('ARKit Not Supported'),
      content: Text('This device does not support ARKit.'),
    ),
  );
}
```

### Camera Permission
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (!status.isGranted) {
    // Handle permission denied
    throw Exception('Camera permission required for AR');
  }
}
```

### Tracking Quality
```dart
void _monitorTrackingQuality(ARKitCamera camera) {
  switch (camera.trackingStateReason) {
    case ARKitTrackingStateReason.excessiveMotion:
      print('Warning: Move device more slowly');
      break;
    case ARKitTrackingStateReason.insufficientFeatures:
      print('Warning: Point camera at textured surface');
      break;
    case ARKitTrackingStateReason.initializing:
      print('ARKit initializing...');
      break;
    case ARKitTrackingStateReason.none:
      // All good!
      break;
  }
}
```

## Platform-Specific Considerations

### Coordinate System
ARKit uses a right-handed coordinate system:
- X: Right
- Y: Up
- Z: Backward (toward user)

The SDK automatically handles coordinate transformations.

### Frame of Reference
- **World**: Fixed to where ARKit session started
- **Camera**: Moves with device camera
- **Local**: Relative to anchors

Choose appropriate reference for your use case.

## Next Steps

- See [Performance Guidelines](../PERFORMANCE.md) for optimization
- See [ARCore Integration](ARCORE_INTEGRATION.md) for cross-platform support
- See [Examples](../examples/arkit_face_tracking.dart) for advanced examples
