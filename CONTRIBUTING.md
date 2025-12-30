# Contributing to VIB34D XR Quaternion SDK

Thank you for your interest in contributing! This document provides guidelines for both human and AI agent developers.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [For AI Agents](#for-ai-agents)
- [Architecture Guidelines](#architecture-guidelines)

## Getting Started

### Prerequisites

- Flutter 3.10+ installed
- Dart 3.0+ SDK
- Git
- (Optional) Android Studio or Xcode for platform testing

### Fork and Clone

```bash
# Fork repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/vib34d-vib3plus.git
cd vib34d-vib3plus

# Add upstream remote
git remote add upstream https://github.com/Domusgpt/vib34d-vib3plus.git
```

## Development Setup

### 1. Install Dependencies

```bash
flutter pub get

# Install example dependencies
cd example
flutter pub get
cd ..
```

### 2. Verify Setup

```bash
# Run tests
flutter test

# Run linter
flutter analyze

# Check formatting
dart format --output=none --set-exit-if-changed .
```

### 3. Run Example App

```bash
cd example
flutter run
```

## Code Standards

### Dart Style Guide

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart):

```dart
// ✅ Good
class QuaternionUtils {
  static Quaternion normalize(Quaternion? q) {
    if (q == null) return Quaternion.identity();
    // ...
  }
}

// ❌ Bad
class quaternion_utils {
  static quaternion Normalize(quaternion? Q) {
    if (Q == null) return quaternion.Identity();
    // ...
  }
}
```

### Documentation Comments

All public APIs must have documentation comments:

```dart
/// Normalize a quaternion to unit length.
///
/// Returns [Quaternion.identity] if [q] is null or has zero length.
///
/// Example:
/// ```dart
/// final q = Quaternion(1.0, 2.0, 3.0, 4.0);
/// final normalized = QuaternionUtils.normalize(q);
/// assert(normalized.length == 1.0);
/// ```
static Quaternion normalize(Quaternion? q) {
  // implementation
}
```

### File Organization

```
lib/
├── src/
│   ├── core/           # Core quaternion mathematics
│   ├── geometry/       # Geometry definitions
│   ├── sensors/        # XR sensor integration
│   ├── visualization/  # Visualization adapters
│   └── test_utils/     # Testing utilities
└── vib34d_xr_quaternion_sdk.dart  # Main export
```

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Classes | PascalCase | `QuaternionFieldService` |
| Methods | camelCase | `normalizeQuaternion` |
| Constants | lowerCamelCase | `rotationLimit` |
| Private | _prefixed | `_computeEnergy` |
| Files | snake_case | `quaternion_field_service.dart` |

## Testing Requirements

### Unit Tests

Every new feature must have unit tests:

```dart
// test/new_feature_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

void main() {
  group('NewFeature', () {
    test('does something correctly', () {
      // Arrange
      final input = SomeInput();

      // Act
      final result = newFeature(input);

      // Assert
      expect(result, isNotNull);
      expect(result.value, equals(expectedValue));
    });

    test('handles edge cases', () {
      expect(() => newFeature(null), throwsArgumentError);
    });
  });
}
```

### Test Coverage

- Minimum coverage: 80%
- Critical paths (quaternion math, sensor integration): 95%

Check coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Integration Tests

For features involving multiple components:

```dart
import 'package:vib34d_xr_quaternion_sdk/src/test_utils/test_utils.dart';

void main() {
  test('full pipeline integration', () {
    final sdk = TestSDKFactory.createMockSDK();

    // Simulate AR tracking
    sdk.mockSession.tick(Duration(milliseconds: 16));

    // Verify quaternion propagation
    expect(sdk.synchronizer.rotationState, isNotEmpty);

    TestSDKFactory.dispose(
      bridge: sdk.bridge,
      quaternionService: sdk.quaternionService,
      synchronizer: sdk.synchronizer,
    );
  });
}
```

## Pull Request Process

### 1. Create Feature Branch

```bash
# Update main
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/my-awesome-feature
```

### 2. Make Changes

- Write code following style guide
- Add tests
- Update documentation
- Run linter and tests

```bash
# Format code
dart format .

# Run analyzer
flutter analyze

# Run tests
flutter test

# Verify example still works
cd example && flutter run
```

### 3. Commit Changes

Use [conventional commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat: add quaternion interpolation slerp method"
git commit -m "fix: handle null quaternion in normalize"
git commit -m "docs: add ARKit integration guide"
git commit -m "test: add coverage for edge cases"
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `test`: Adding/updating tests
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `chore`: Maintenance

### 4. Push and Create PR

```bash
git push origin feature/my-awesome-feature
```

Create PR on GitHub with:
- Clear title
- Description of changes
- Link to related issues
- Screenshots/videos if UI changes

### 5. Code Review

- Address review feedback
- Keep commits clean
- Update branch if needed:

```bash
git checkout main
git pull upstream main
git checkout feature/my-awesome-feature
git rebase main
```

## For AI Agents

### Agent-Friendly Guidelines

#### 1. Module Boundaries

Each module has clear responsibilities:

```dart
// ✅ Good: Quaternion math in core
lib/src/core/quaternion.dart:
  - QuaternionUtils.normalize()
  - QuaternionUtils.toEuler()

// ❌ Bad: Sensor logic in core
lib/src/core/quaternion.dart:
  - ARCoreSensorAdapter  // Wrong module!
```

#### 2. Type Contracts

All public APIs have explicit types:

```dart
// ✅ Good: Explicit types
Quaternion normalize(Quaternion? input) {
  if (input == null) return Quaternion.identity();
  return input.normalized();
}

// ❌ Bad: Dynamic types
dynamic normalize(dynamic input) {
  if (input == null) return null;
  return input.normalized();
}
```

#### 3. Extensibility Points

Abstract classes for custom implementations:

```dart
// Extend for custom quaternion service
abstract class QuaternionFieldService {
  void ingestPrimaryQuaternion(Quaternion q);
  Stream<QuaternionSnapshot> get stream;
}

// Extend for custom sensor bridge
abstract class SensorAdapter {
  Future<void> connect();
  Future<SensorEvent> read();
}
```

#### 4. Test Utilities

Use provided test helpers:

```dart
import 'package:vib34d_xr_quaternion_sdk/src/test_utils/test_utils.dart';

// Mock AR session
final mockSession = MockARSession(bridge: bridge);
mockSession.tick(Duration(milliseconds: 16));

// Assertions
QuaternionAssertions.assertNormalized(quaternion);
QuaternionAssertions.assertQuaternionEquals(actual, expected);
```

#### 5. Documentation Templates

```dart
/// [Brief one-line summary]
///
/// [Detailed explanation of what this does]
///
/// Parameters:
/// - [param1]: Description
/// - [param2]: Description
///
/// Returns:
/// - Description of return value
///
/// Throws:
/// - [ExceptionType]: When condition happens
///
/// Example:
/// ```dart
/// final result = myFunction(arg1, arg2);
/// ```
///
/// See also:
/// - [RelatedClass]
/// - [RelatedMethod]
```

## Architecture Guidelines

### Adding New Features

#### 1. Plan Module Location

```
Feature: Custom geometry generator
Module: lib/src/geometry/
Files:
  - custom_geometry_generator.dart
  - custom_geometry_parameters.dart
Tests:
  - test/custom_geometry_generator_test.dart
```

#### 2. Define Public API

```dart
// lib/src/geometry/custom_geometry_generator.dart

/// Generates custom 4D geometry configurations.
class CustomGeometryGenerator {
  /// Creates generator with [config].
  CustomGeometryGenerator(this.config);

  final GeneratorConfig config;

  /// Generates geometry based on [parameters].
  GeometryDefinition generate(CustomParameters parameters) {
    // Implementation
  }
}
```

#### 3. Export in Main Library

```dart
// lib/vib34d_xr_quaternion_sdk.dart

// Geometry library
export 'src/geometry/geometry_library.dart';
export 'src/geometry/custom_geometry_generator.dart';  // Add new export
```

#### 4. Add Tests

```dart
// test/custom_geometry_generator_test.dart

void main() {
  group('CustomGeometryGenerator', () {
    test('generates valid geometry', () {
      final generator = CustomGeometryGenerator(config);
      final geometry = generator.generate(parameters);

      expect(geometry, isNotNull);
      expect(geometry.vertices, isNotEmpty);
    });
  });
}
```

#### 5. Update Documentation

- Add section to `FLUTTER_README.md`
- Create guide in `docs/guides/` if complex
- Add example to `example/`

### Performance Considerations

- Use `const` constructors when possible
- Avoid creating objects in hot paths
- Use object pooling for frequently allocated objects
- Profile with Flutter DevTools before optimizing

### Breaking Changes

If making breaking changes:
1. Discuss in issue first
2. Update CHANGELOG.md
3. Provide migration guide
4. Deprecate old API first if possible

```dart
// Deprecate old API
@Deprecated('Use normalizeQuaternion instead')
Quaternion normalize(Quaternion q) => normalizeQuaternion(q);

// New API
Quaternion normalizeQuaternion(Quaternion q) {
  // implementation
}
```

## Getting Help

- **Issues**: Check existing issues or create new one
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Paul@clearseassolutions.com

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing to VIB34D XR Quaternion SDK!** 🚀
