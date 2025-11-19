/// VIB34D XR Quaternion SDK for Flutter
///
/// 4D Geometric Processing with XR Quaternion Integration
/// Advanced quaternion mathematics and spatial computing for Flutter/ARCore/ARKit
///
/// This SDK provides:
/// - Core quaternion mathematics for XR rotations and 4D transformations
/// - 4D polytope systems (tesseracts, 120-cells, etc.)
/// - XR sensor integration layer (ARCore/ARKit compatible)
/// - Shader quaternion synchronization for GPU rendering
/// - Geometry library with 24 base + core combinations
///
/// Example usage:
/// ```dart
/// import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
///
/// // Create sensor bridge
/// final bridge = SensoryInputBridge();
///
/// // Create quaternion service
/// final quaternionService = QuaternionFieldService(
///   energySmoothing: 0.35,
///   velocityReference: 8.0,
/// );
///
/// // Create synchronizer
/// final synchronizer = ShaderQuaternionSynchronizer(
///   bridge: bridge,
///   quaternionService: quaternionService,
///   onSystemUpdate: (system, parameters) {
///     print('System $system updated: $parameters');
///   },
/// );
///
/// // Start listening
/// synchronizer.start();
///
/// // Publish AR tracking data
/// bridge.publishPose(
///   orientation: Quaternion(x, y, z, w),
///   position: Vector3(x, y, z),
///   confidence: 0.95,
/// );
/// ```
library vib34d_xr_quaternion_sdk;

// Core quaternion utilities
export 'src/core/quaternion.dart';
export 'src/core/quaternion_field_service.dart';

// Geometry library
export 'src/geometry/geometry_library.dart';

// Sensor integration
export 'src/sensors/sensory_input_bridge.dart';

// Visualization
export 'src/visualization/shader_quaternion_synchronizer.dart';

// Test utilities (for development and testing)
export 'src/test_utils/test_utils.dart';

// Re-export vector_math for convenience
export 'package:vector_math/vector_math.dart' show Quaternion, Vector3, Vector4, Matrix4;
