/// Gamepad input adapter for web and desktop applications with gamepad support.
///
/// Converts gamepad joystick movements and button presses into quaternion rotations,
/// enabling 3D/4D interaction with game controllers.
///
/// **Usage Example**:
/// ```dart
/// final adapter = GamepadInputAdapter(
///   bridge: sensoryBridge,
///   sensitivity: 2.0,
/// );
///
/// adapter.start();
///
/// // Poll gamepad state (call in your game loop)
/// void update(double deltaTime) {
///   adapter.update(deltaTime);
/// }
/// ```

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../sensors/sensory_input_bridge.dart';
import '../core/quaternion.dart';

/// Configuration for gamepad input behavior
class GamepadInputConfig {
  /// Sensitivity multiplier for joystick movements (default: 2.0)
  final double sensitivity;

  /// Dead zone for joystick input (0.0 to 1.0, default: 0.15)
  /// Values below this threshold are ignored to prevent drift
  final double deadZone;

  /// Whether to invert Y-axis on right stick (default: false)
  final bool invertY;

  /// Whether to invert X-axis on right stick (default: false)
  final bool invertX;

  /// Smoothing factor for movements (0.0 = no smoothing, 1.0 = max smoothing)
  final double smoothing;

  /// Map of button indices to functions
  /// For example: {0: 'reset', 1: 'increaseSpeed'}
  final Map<int, String> buttonMap;

  const GamepadInputConfig({
    this.sensitivity = 2.0,
    this.deadZone = 0.15,
    this.invertY = false,
    this.invertX = false,
    this.smoothing = 0.1,
    this.buttonMap = const {
      0: 'reset',        // A button (Xbox) / Cross (PS)
      1: 'togglePause',  // B button (Xbox) / Circle (PS)
    },
  });
}

/// Gamepad state structure
class GamepadState {
  final double leftStickX;
  final double leftStickY;
  final double rightStickX;
  final double rightStickY;
  final double leftTrigger;
  final double rightTrigger;
  final List<bool> buttons;

  const GamepadState({
    this.leftStickX = 0.0,
    this.leftStickY = 0.0,
    this.rightStickX = 0.0,
    this.rightStickY = 0.0,
    this.leftTrigger = 0.0,
    this.rightTrigger = 0.0,
    this.buttons = const [],
  });
}

/// Gamepad input adapter for quaternion control
///
/// **Standard Gamepad Mapping** (Xbox/PlayStation style):
/// - **Left Stick**: Pitch (Y) and Yaw (X) rotation
/// - **Right Stick**: Roll (X) and fine-tune Yaw (Y)
/// - **Left Trigger**: Decrease rotation speed
/// - **Right Trigger**: Increase rotation speed
/// - **A/Cross Button**: Reset to identity rotation
/// - **B/Circle Button**: Toggle pause
class GamepadInputAdapter {
  final SensoryInputBridge bridge;
  final GamepadInputConfig config;

  // Current rotation state
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;

  // Smoothing
  double _smoothedRotX = 0.0;
  double _smoothedRotY = 0.0;
  double _smoothedRotZ = 0.0;

  // State
  bool _isStarted = false;
  bool _isPaused = false;
  GamepadState _lastState = const GamepadState();

  // Button press tracking (for edge detection)
  List<bool> _lastButtonStates = [];

  GamepadInputAdapter({
    required this.bridge,
    GamepadInputConfig? config,
  }) : config = config ?? const GamepadInputConfig();

  /// Start publishing gamepad-based quaternions
  void start() {
    _isStarted = true;
    _publishCurrentRotation();
  }

  /// Stop publishing updates
  void stop() {
    _isStarted = false;
  }

  /// Toggle pause state
  void togglePause() {
    _isPaused = !_isPaused;
  }

  /// Update gamepad state (call this in your game loop)
  ///
  /// **deltaTime**: Time since last update in seconds
  /// **state**: Current gamepad state from your gamepad API
  ///
  /// **Example**:
  /// ```dart
  /// void gameLoop(double deltaTime) {
  ///   final gamepadState = getGamepadState(); // Your gamepad API
  ///   adapter.update(deltaTime, state: gamepadState);
  /// }
  /// ```
  void update(double deltaTime, {GamepadState? state}) {
    if (!_isStarted || _isPaused) return;

    final currentState = state ?? _lastState;
    _processGamepadInput(currentState, deltaTime);
    _processButtons(currentState);

    _lastState = currentState;
    _publishCurrentRotation();
  }

  /// Set gamepad state manually (alternative to update())
  void setGamepadState(GamepadState state) {
    _lastState = state;
  }

  /// Reset rotation to identity
  void reset() {
    _rotationX = 0.0;
    _rotationY = 0.0;
    _rotationZ = 0.0;
    _smoothedRotX = 0.0;
    _smoothedRotY = 0.0;
    _smoothedRotZ = 0.0;
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
    return EulerAngles(
      roll: _rotationZ,
      pitch: _rotationX,
      yaw: _rotationY,
    );
  }

  /// Get current rotation as quaternion
  Quaternion getCurrentQuaternion() {
    return _eulerToQuaternion(_rotationZ, _rotationX, _rotationY);
  }

  void _processGamepadInput(GamepadState state, double deltaTime) {
    // Apply dead zone
    final leftX = _applyDeadZone(state.leftStickX);
    final leftY = _applyDeadZone(state.leftStickY);
    final rightX = _applyDeadZone(state.rightStickX);
    final rightY = _applyDeadZone(state.rightStickY);

    // Left stick controls pitch (Y) and yaw (X)
    double pitchInput = leftY * config.sensitivity * deltaTime;
    double yawInput = leftX * config.sensitivity * deltaTime;

    // Right stick controls roll (X) and fine yaw adjustment (Y)
    double rollInput = rightX * config.sensitivity * deltaTime;
    double yawFineInput = rightY * config.sensitivity * deltaTime * 0.5;

    // Apply inversion
    if (config.invertY) {
      pitchInput = -pitchInput;
      yawFineInput = -yawFineInput;
    }
    if (config.invertX) {
      yawInput = -yawInput;
      rollInput = -rollInput;
    }

    // Apply smoothing
    _smoothedRotX = _smoothedRotX * (1.0 - config.smoothing) +
                    pitchInput * config.smoothing;
    _smoothedRotY = _smoothedRotY * (1.0 - config.smoothing) +
                    (yawInput + yawFineInput) * config.smoothing;
    _smoothedRotZ = _smoothedRotZ * (1.0 - config.smoothing) +
                    rollInput * config.smoothing;

    // Update rotation
    _rotationX += _smoothedRotX;
    _rotationY += _smoothedRotY;
    _rotationZ += _smoothedRotZ;

    // Optional: Use triggers for speed adjustment
    // This doesn't change rotation but could be used for other parameters
  }

  void _processButtons(GamepadState state) {
    // Initialize button tracking on first call
    if (_lastButtonStates.isEmpty && state.buttons.isNotEmpty) {
      _lastButtonStates = List.filled(state.buttons.length, false);
    }

    // Check for button presses (edge detection)
    for (int i = 0; i < state.buttons.length && i < _lastButtonStates.length; i++) {
      final pressed = state.buttons[i];
      final wasPressed = _lastButtonStates[i];

      // Button was just pressed (rising edge)
      if (pressed && !wasPressed) {
        _handleButtonPress(i);
      }

      _lastButtonStates[i] = pressed;
    }
  }

  void _handleButtonPress(int buttonIndex) {
    final action = config.buttonMap[buttonIndex];

    switch (action) {
      case 'reset':
        reset();
        break;
      case 'togglePause':
        togglePause();
        break;
      // Add more actions as needed
    }
  }

  double _applyDeadZone(double value) {
    if (value.abs() < config.deadZone) {
      return 0.0;
    }

    // Scale value beyond dead zone to full range
    final sign = value.sign;
    final adjusted = (value.abs() - config.deadZone) / (1.0 - config.deadZone);
    return sign * adjusted;
  }

  void _publishCurrentRotation() {
    final quaternion = _eulerToQuaternion(_rotationZ, _rotationX, _rotationY);

    bridge.publishPose(
      orientation: quaternion,
      confidence: 1.0,
      source: 'gamepad-input',
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
