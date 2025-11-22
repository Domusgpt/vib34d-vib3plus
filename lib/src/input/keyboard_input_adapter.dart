/// Keyboard input adapter for web and desktop applications.
///
/// Converts keyboard presses into quaternion rotations using WASD/Arrow keys
/// and other configurable key bindings.
///
/// **Usage Example**:
/// ```dart
/// final adapter = KeyboardInputAdapter(
///   bridge: sensoryBridge,
///   rotationSpeed: 1.5,
/// );
///
/// adapter.start();
///
/// // In your widget
/// RawKeyboardListener(
///   onKey: (event) {
///     if (event is RawKeyDownEvent) {
///       adapter.handleKeyDown(event.logicalKey);
///     } else if (event is RawKeyUpEvent) {
///       adapter.handleKeyUp(event.logicalKey);
///     }
///   },
/// )
/// ```

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../sensors/sensory_input_bridge.dart';
import '../core/quaternion.dart';

/// Keyboard key codes (simplified representation)
class KeyCode {
  static const String w = 'w';
  static const String a = 'a';
  static const String s = 's';
  static const String d = 'd';
  static const String q = 'q';
  static const String e = 'e';
  static const String arrowUp = 'ArrowUp';
  static const String arrowDown = 'ArrowDown';
  static const String arrowLeft = 'ArrowLeft';
  static const String arrowRight = 'ArrowRight';
  static const String space = ' ';
  static const String shift = 'Shift';
  static const String r = 'r';
}

/// Configuration for keyboard input behavior
class KeyboardInputConfig {
  /// Rotation speed in radians per second (default: 1.5)
  final double rotationSpeed;

  /// Acceleration factor when holding keys (default: 1.2)
  final double acceleration;

  /// Maximum speed multiplier (default: 3.0)
  final double maxSpeedMultiplier;

  /// Whether to enable continuous rotation when key is held (default: true)
  final bool continuousRotation;

  /// Custom key bindings
  final Map<String, String> keyBindings;

  const KeyboardInputConfig({
    this.rotationSpeed = 1.5,
    this.acceleration = 1.2,
    this.maxSpeedMultiplier = 3.0,
    this.continuousRotation = true,
    this.keyBindings = const {
      // Pitch (X-axis)
      'w': 'pitchUp',
      's': 'pitchDown',
      'ArrowUp': 'pitchUp',
      'ArrowDown': 'pitchDown',

      // Yaw (Y-axis)
      'a': 'yawLeft',
      'd': 'yawRight',
      'ArrowLeft': 'yawLeft',
      'ArrowRight': 'yawRight',

      // Roll (Z-axis)
      'q': 'rollLeft',
      'e': 'rollRight',

      // Reset
      'r': 'reset',

      // Speed modifiers
      'Shift': 'speedBoost',
      ' ': 'speedSlow',
    },
  });
}

/// Keyboard input adapter for quaternion control
///
/// **Default Key Bindings**:
/// - **W / Arrow Up**: Pitch up (rotate forward)
/// - **S / Arrow Down**: Pitch down (rotate backward)
/// - **A / Arrow Left**: Yaw left (rotate left)
/// - **D / Arrow Right**: Yaw right (rotate right)
/// - **Q**: Roll left (tilt left)
/// - **E**: Roll right (tilt right)
/// - **R**: Reset to identity rotation
/// - **Shift**: Speed boost (hold)
/// - **Space**: Slow motion (hold)
class KeyboardInputAdapter {
  final SensoryInputBridge bridge;
  final KeyboardInputConfig config;

  // Current rotation state
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;

  // Key state tracking
  final Set<String> _pressedKeys = {};

  // Speed state
  double _currentSpeedMultiplier = 1.0;
  int _holdFrames = 0;

  // State
  bool _isStarted = false;
  DateTime? _lastUpdateTime;

  KeyboardInputAdapter({required this.bridge, KeyboardInputConfig? config})
    : config = config ?? const KeyboardInputConfig();

  /// Start publishing keyboard-based quaternions
  void start() {
    _isStarted = true;
    _lastUpdateTime = DateTime.now();
    _publishCurrentRotation();

    // Start update loop if continuous rotation enabled
    if (config.continuousRotation) {
      _startUpdateLoop();
    }
  }

  /// Stop publishing updates
  void stop() {
    _isStarted = false;
  }

  /// Handle key down event
  ///
  /// **Example with Flutter's RawKeyboardListener**:
  /// ```dart
  /// RawKeyboardListener(
  ///   focusNode: _focusNode,
  ///   onKey: (event) {
  ///     if (event is RawKeyDownEvent) {
  ///       adapter.handleKeyDown(event.character ?? '');
  ///     }
  ///   },
  /// )
  /// ```
  ///
  /// **Example with Web KeyboardEvent**:
  /// ```dart
  /// document.addEventListener('keydown', (event) {
  ///   adapter.handleKeyDown(event.key);
  /// });
  /// ```
  void handleKeyDown(String key) {
    if (!_isStarted) return;

    final wasEmpty = _pressedKeys.isEmpty;
    _pressedKeys.add(key);

    // If this is first key press, reset speed multiplier
    if (wasEmpty) {
      _currentSpeedMultiplier = 1.0;
      _holdFrames = 0;
    }

    // Handle immediate actions (non-continuous)
    if (!config.continuousRotation) {
      _processKeyPress(key);
    }
  }

  /// Handle key up event
  void handleKeyUp(String key) {
    _pressedKeys.remove(key);

    // Reset speed when all keys released
    if (_pressedKeys.isEmpty) {
      _currentSpeedMultiplier = 1.0;
      _holdFrames = 0;
    }
  }

  /// Reset rotation to identity
  void reset() {
    _rotationX = 0.0;
    _rotationY = 0.0;
    _rotationZ = 0.0;
    _currentSpeedMultiplier = 1.0;
    _holdFrames = 0;
    _publishCurrentRotation();
  }

  /// Set absolute rotation values
  void setRotation(double x, double y, double z) {
    _rotationX = x;
    _rotationY = y;
    _rotationZ = z;
    _publishCurrentRotation();
  }

  /// Get current rotation as Euler angles
  EulerAngles getCurrentEuler() {
    return EulerAngles(roll: _rotationZ, pitch: _rotationX, yaw: _rotationY);
  }

  /// Get current rotation as quaternion
  Quaternion getCurrentQuaternion() {
    return _eulerToQuaternion(_rotationZ, _rotationX, _rotationY);
  }

  void _startUpdateLoop() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (_isStarted) {
        _update();
        _startUpdateLoop();
      }
    });
  }

  void _update() {
    if (_pressedKeys.isEmpty) return;

    final now = DateTime.now();
    final deltaTime = _lastUpdateTime != null
        ? (now.difference(_lastUpdateTime!).inMicroseconds / 1000000.0)
        : 0.016;
    _lastUpdateTime = now;

    // Process all currently pressed keys
    for (final key in _pressedKeys) {
      _processKeyPress(key, deltaTime: deltaTime);
    }

    // Apply acceleration for held keys
    if (_pressedKeys.isNotEmpty) {
      _holdFrames++;
      if (_holdFrames > 10) {
        _currentSpeedMultiplier = math.min(
          _currentSpeedMultiplier * config.acceleration,
          config.maxSpeedMultiplier,
        );
      }
    }

    _publishCurrentRotation();
  }

  void _processKeyPress(String key, {double deltaTime = 0.016}) {
    final action = config.keyBindings[key];
    if (action == null) return;

    // Calculate rotation amount
    double speedModifier = _currentSpeedMultiplier;

    // Apply speed modifiers
    if (_pressedKeys.contains('Shift')) {
      speedModifier *= 2.0;
    }
    if (_pressedKeys.contains(' ')) {
      speedModifier *= 0.5;
    }

    final rotationAmount = config.rotationSpeed * deltaTime * speedModifier;

    switch (action) {
      case 'pitchUp':
        _rotationX += rotationAmount;
        break;
      case 'pitchDown':
        _rotationX -= rotationAmount;
        break;
      case 'yawLeft':
        _rotationY -= rotationAmount;
        break;
      case 'yawRight':
        _rotationY += rotationAmount;
        break;
      case 'rollLeft':
        _rotationZ -= rotationAmount;
        break;
      case 'rollRight':
        _rotationZ += rotationAmount;
        break;
      case 'reset':
        reset();
        break;
    }
  }

  void _publishCurrentRotation() {
    final quaternion = _eulerToQuaternion(_rotationZ, _rotationX, _rotationY);

    bridge.publishPose(
      orientation: quaternion,
      confidence: 1.0,
      source: 'keyboard-input',
    );
  }

  Quaternion _eulerToQuaternion(double roll, double pitch, double yaw) {
    final cr = math.cos(roll * 0.5);
    final sr = math.sin(roll * 0.5);
    final cp = math.cos(pitch * 0.5);
    final sp = math.sin(pitch * 0.5);
    final cy = math.cos(yaw * 0.5);
    final sy = math.sin(yaw * 0.5);

    return Quaternion(
      sr * cp * cy - cr * sp * sy, // x
      cr * sp * cy + sr * cp * sy, // y
      cr * cp * sy - sr * sp * cy, // z
      cr * cp * cy + sr * sp * sy, // w
    );
  }
}
