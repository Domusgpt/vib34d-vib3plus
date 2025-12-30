# Changelog

All notable changes to the VIB34D XR Quaternion SDK will be documented in this file.

## [1.0.0-flutter] - 2025-01-19

### Added - Flutter/Dart Support

#### Core Modules
- **Quaternion Utilities** (`lib/src/core/quaternion.dart`)
  - Complete quaternion algebra implementation in Dart
  - Quaternion normalization, multiplication, conjugation
  - Conversion to/from Euler angles
  - Linear and spherical interpolation (lerp/slerp)
  - Angular velocity computation

- **Quaternion Field Service** (`lib/src/core/quaternion_field_service.dart`)
  - Observable quaternion state management using Dart Streams
  - Motion energy tracking with smoothing
  - Primary and secondary quaternion channels
  - Pose ingestion (orientation + position)
  - Real-time snapshot generation

#### Geometry System
- **Geometry Library** (`lib/src/geometry/geometry_library.dart`)
  - 8 base geometries: Tetrahedron, Hypercube, Sphere, Torus, Klein Bottle, Fractal, Wave, Crystal
  - 3 core 4D polytope variants: Hypercube Core, Hypersphere Core, Hypertetra Core
  - 24 total geometry combinations
  - Geometry encoding/decoding by index or key
  - Variation parameter generation for procedural rendering
  - Complete metadata system

#### XR Sensor Integration
- **Sensory Input Bridge** (`lib/src/sensors/sensory_input_bridge.dart`)
  - Channel-based sensor event routing
  - Stream-based pub/sub architecture
  - ARCore/ARKit pose data normalization
  - Spatial anchor and hit-test support
  - Configurable channel history

- **Shader Quaternion Synchronizer** (`lib/src/visualization/shader_quaternion_synchronizer.dart`)
  - Bridges XR sensor data to 4D rotation parameters
  - Six-plane rotation generation (XY, XZ, YZ, XW, YW, ZW)
  - Confidence-based parameter smoothing
  - Motion energy integration
  - System update callbacks for custom renderers

#### Testing
- **Comprehensive Test Suite**
  - Quaternion operations and conversions (`test/quaternion_test.dart`)
  - Geometry library functionality (`test/geometry_library_test.dart`)
  - Quaternion field service state management (`test/quaternion_field_service_test.dart`)
  - Full test coverage for core functionality

#### Example Application
- **Flutter Demo App** (`example/`)
  - Complete SDK integration example
  - Simulated AR tracking visualization
  - Real-time quaternion updates
  - Geometry selection UI
  - 4D rotation parameter display
  - Motion energy meter

#### Documentation
- **Flutter README** (`FLUTTER_README.md`)
  - Complete Flutter/Dart API documentation
  - Quick start guide
  - Integration examples
  - Platform support information

- **Package Configuration** (`pubspec.yaml`)
  - Flutter 3.10+ support
  - Dart 3.0+ SDK requirement
  - vector_math dependency

### Technical Details

- **Language**: Dart 3.0+
- **Framework**: Flutter 3.10+
- **Dependencies**: vector_math ^2.1.4
- **Platforms**: Android (ARCore), iOS (ARKit), Desktop, Web
- **Architecture**: Stream-based reactive design
- **Test Framework**: flutter_test

### Migration from JavaScript

The Flutter port maintains API compatibility with the JavaScript SDK while adapting to Dart idioms:

- Event emitters → Dart Streams
- Promises → async/await
- Maps/Sets → Dart collections
- Performance.now() → DateTime.now()
- WebGL shaders → Flutter CustomPainter/Shader integration points

### Breaking Changes from JS SDK

- No direct DOM/WebGL integration (Flutter uses CustomPainter/Shader)
- Stream-based instead of callback-based APIs
- Strongly typed Dart instead of JavaScript
- No browser-specific APIs

### Known Limitations

- Shader code needs to be implemented separately using Flutter's Shader API
- AR tracking requires platform-specific AR plugins (ARCore/ARKit Flutter plugins)
- No built-in visualization renderer (provides parameters for custom renderers)

### Future Roadmap

- [ ] Flutter CustomPainter examples for 4D geometry rendering
- [ ] ARCore Flutter plugin integration example
- [ ] ARKit Flutter plugin integration example
- [ ] WebGL shader adapter for Flutter Web
- [ ] Performance benchmarks
- [ ] Additional geometry types
- [ ] VR headset support (Quest, Vive, etc.)

---

## [1.0.0] - 2025-01-XX (JavaScript SDK)

Initial release of VIB34D XR Quaternion SDK for JavaScript/Node.js.

See main README.md for JavaScript SDK changelog.
