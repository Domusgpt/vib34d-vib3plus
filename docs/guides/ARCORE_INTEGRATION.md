# ARCore Integration Guide

Complete guide for integrating VIB34D XR Quaternion SDK with Google ARCore on Android.

## Prerequisites

- Flutter 3.10+
- Android Studio
- Physical Android device with ARCore support
- `ar_flutter_plugin` or `arcore_flutter_plugin`

## Installation

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  vib34d_xr_quaternion_sdk:
    git:
      url: https://github.com/Domusgpt/vib34d-xr-quaternion-sdk.git
      ref: claude/add-flutter-dart-support-01WiDt1H7XB1FTsuQy3i2jZa
  ar_flutter_plugin: ^1.0.0  # or arcore_flutter_plugin
  vector_math: ^2.1.4
```

### 2. Android Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-feature android:name="android.hardware.camera.ar" android:required="true" />

  <application>
    <meta-data
      android:name="com.google.ar.core"
      android:value="required" />
  </application>
</manifest>
```

### 3. Minimum SDK Version

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 24  // ARCore requires API 24+
    }
}
```

## Basic Integration

### Complete Example with ARCore

```dart
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

class ARCoreQuaternionView extends StatefulWidget {
  @override
  State<ARCoreQuaternionView> createState() => _ARCoreQuaternionViewState();
}

class _ARCoreQuaternionViewState extends State<ARCoreQuaternionView> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;

  // VIB34D SDK components
  late SensoryInputBridge _bridge;
  late QuaternionFieldService _quaternionService;
  late ShaderQuaternionSynchronizer _synchronizer;

  Map<String, double> _currentRotations = {};
  int _currentGeometry = 0;

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
  }

  void _handleSystemUpdate(String system, Map<String, double> parameters) {
    setState(() {
      _currentRotations = parameters;
    });
    // Update your 4D visualization with new rotation parameters
    _updateVisualization(parameters);
  }

  void _updateVisualization(Map<String, double> parameters) {
    // Use parameters to drive your 4D geometry rendering
    final metadata = GeometryLibrary.describeGeometry(_currentGeometry);
    final varParams = GeometryLibrary.getVariationParameters(_currentGeometry, 1);

    print('Updating ${metadata?.name} with rotations: $parameters');
    // TODO: Update your CustomPainter or 3D renderer here
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
    );

    // Subscribe to ARCore frame updates
    this.arSessionManager.onPlaneOrPointTap = _onPlaneTap;
  }

  void _onPlaneTap(List<ARHitTestResult> hitTestResults) {
    if (hitTestResults.isEmpty) return;

    final hit = hitTestResults.first;

    // Extract pose from ARCore
    final transform = hit.worldTransform;

    // Convert ARCore transform to quaternion
    final quaternion = _extractQuaternionFromMatrix(transform);
    final position = _extractPositionFromMatrix(transform);

    // Publish to VIB34D SDK
    _bridge.publishPose(
      orientation: quaternion,
      position: position,
      confidence: 0.9,  // ARCore provides high confidence on plane taps
      source: 'arcore-plane-tap',
    );

    // Cycle to next geometry on tap
    setState(() {
      _currentGeometry = (_currentGeometry + 1) % 24;
    });
  }

  Quaternion _extractQuaternionFromMatrix(Matrix4 matrix) {
    // Extract rotation from ARCore 4x4 transform matrix
    final m11 = matrix.entry(0, 0);
    final m12 = matrix.entry(0, 1);
    final m13 = matrix.entry(0, 2);
    final m21 = matrix.entry(1, 0);
    final m22 = matrix.entry(1, 1);
    final m23 = matrix.entry(1, 2);
    final m31 = matrix.entry(2, 0);
    final m32 = matrix.entry(2, 1);
    final m33 = matrix.entry(2, 2);

    final trace = m11 + m22 + m33;
    double x, y, z, w;

    if (trace > 0) {
      final s = 0.5 / math.sqrt(trace + 1.0);
      w = 0.25 / s;
      x = (m32 - m23) * s;
      y = (m13 - m31) * s;
      z = (m21 - m12) * s;
    } else if (m11 > m22 && m11 > m33) {
      final s = 2.0 * math.sqrt(1.0 + m11 - m22 - m33);
      w = (m32 - m23) / s;
      x = 0.25 * s;
      y = (m12 + m21) / s;
      z = (m13 + m31) / s;
    } else if (m22 > m33) {
      final s = 2.0 * math.sqrt(1.0 + m22 - m11 - m33);
      w = (m13 - m31) / s;
      x = (m12 + m21) / s;
      y = 0.25 * s;
      z = (m23 + m32) / s;
    } else {
      final s = 2.0 * math.sqrt(1.0 + m33 - m11 - m22);
      w = (m21 - m12) / s;
      x = (m13 + m31) / s;
      y = (m23 + m32) / s;
      z = 0.25 * s;
    }

    return Quaternion(x, y, z, w);
  }

  Vector3 _extractPositionFromMatrix(Matrix4 matrix) {
    return Vector3(
      matrix.entry(0, 3),
      matrix.entry(1, 3),
      matrix.entry(2, 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ARCore + VIB34D'),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontal,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GeometryLibrary.getGeometryName(_currentGeometry),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('XY: ${_currentRotations['rot4dXY']?.toStringAsFixed(3) ?? '0.000'}'),
                    Text('XW: ${_currentRotations['rot4dXW']?.toStringAsFixed(3) ?? '0.000'}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    arSessionManager.dispose();
    _synchronizer.dispose();
    _quaternionService.dispose();
    _bridge.dispose();
    super.dispose();
  }
}
```

## Continuous Tracking

For continuous camera pose tracking:

```dart
// In your ARSessionManager setup
arSessionManager.onCameraTransformReceived = (Matrix4 cameraTransform) {
  final quaternion = _extractQuaternionFromMatrix(cameraTransform);
  final position = _extractPositionFromMatrix(cameraTransform);

  _bridge.publishPose(
    orientation: quaternion,
    position: position,
    confidence: 0.85,
    source: 'arcore-camera',
  );
};
```

## Anchor Tracking

```dart
void _trackAnchors() {
  arAnchorManager.onAnchorUpdated = (List<ARAnchor> anchors) {
    final xrPoses = anchors.map((anchor) {
      return XRPose(
        orientation: _extractQuaternionFromMatrix(anchor.transform),
        position: _extractPositionFromMatrix(anchor.transform),
        confidence: 0.9,
      );
    }).toList();

    _bridge.publishSpatialAnchors(
      anchors: xrPoses,
      confidence: 0.85,
      source: 'arcore-anchors',
    );
  };
}
```

## Performance Tips

1. **Throttle Updates**: Don't update on every frame if not needed
```dart
DateTime? _lastUpdate;

void _throttledUpdate(Matrix4 transform) {
  final now = DateTime.now();
  if (_lastUpdate != null && now.difference(_lastUpdate!).inMilliseconds < 33) {
    return;  // Skip if < 33ms (30fps)
  }
  _lastUpdate = now;

  // Process update...
}
```

2. **Use ARCore Tracking State**
```dart
arSessionManager.onTrackingStateChanged = (TrackingState state) {
  if (state == TrackingState.tracking) {
    // High confidence tracking
    _synchronizer.setEnabled(true);
  } else {
    // Lost tracking or limited
    _synchronizer.setEnabled(false);
  }
};
```

3. **Optimize Geometry Complexity**
```dart
final params = GeometryLibrary.getVariationParameters(_currentGeometry, 0);
// Use level 0 for mobile devices for better performance
```

## Troubleshooting

### ARCore Not Available
```dart
bool isARCoreAvailable = await arSessionManager.checkARCoreAvailability();
if (!isARCoreAvailable) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('ARCore Required'),
      content: Text('This app requires ARCore to function.'),
    ),
  );
}
```

### Permissions
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (!status.isGranted) {
    // Handle permission denied
  }
}
```

## Next Steps

- See [Performance Guidelines](../PERFORMANCE.md) for optimization tips
- See [Architecture](../architecture/QUATERNION_FLOW.md) for data flow details
- See [Examples](../examples/arcore_custom_renderer.dart) for rendering examples
