# VIB34D SDK for Web Apps & Non-AR Flutter Development

**Complete Guide for General Web Development and Non-Wearable Use Cases**

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Input Methods](#input-methods)
   - [Mouse Input](#mouse-input)
   - [Touch Input](#touch-input)
   - [Keyboard Input](#keyboard-input)
   - [Gamepad Input](#gamepad-input)
   - [Device Motion](#device-motion)
4. [Visualization](#visualization)
5. [Complete Examples](#complete-examples)
6. [Best Practices](#best-practices)
7. [Performance Optimization](#performance-optimization)
8. [Deployment](#deployment)

---

## Overview

The VIB34D XR Quaternion SDK is designed for **both AR/XR applications AND general web/mobile apps**. This guide focuses on using the SDK for:

- **Flutter Web Applications** - Interactive 3D/4D visualizations in the browser
- **Flutter Desktop Apps** - Desktop applications with mouse/keyboard control
- **Flutter Mobile Apps (non-AR)** - Touch-controlled visualizations
- **Vanilla Web Apps** - Direct JavaScript/TypeScript integration

### What You Can Build

- Interactive 4D geometric visualizations
- Data visualization with quaternion-based rotations
- Educational tools for mathematics and physics
- Creative art installations
- Game mechanics with 3D/4D rotations
- Scientific simulations
- Virtual museum exhibits

### No AR Required!

While the SDK supports ARCore and ARKit, you can use it **without any AR hardware**:
- Desktop browsers with mouse/keyboard
- Mobile browsers with touch
- Tablet apps with gestures
- Desktop apps with gamepads
- Any device with sensors (gyroscope/accelerometer)

---

## Quick Start

### 1. Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  vib34d_xr_quaternion_sdk:
    path: ./  # or git/pub.dev URL
  flutter:
    sdk: flutter
  vector_math: ^2.1.4
```

### 2. Import

```dart
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
```

### 3. Choose Your Input Method

Pick the input method that matches your platform:

```dart
// For web/desktop with mouse
final mouseAdapter = MouseInputAdapter(bridge: bridge);

// For mobile with touch
final touchAdapter = TouchInputAdapter(bridge: bridge);

// For desktop/web with keyboard
final keyboardAdapter = KeyboardInputAdapter(bridge: bridge);

// For game controllers
final gamepadAdapter = GamepadInputAdapter(bridge: bridge);

// For mobile device motion
final motionAdapter = DeviceMotionAdapter(bridge: bridge);
```

### 4. Set Up Visualization

```dart
final bridge = SensoryInputBridge();
final quaternionService = QuaternionFieldService();
final synchronizer = ShaderQuaternionSynchronizer(
  bridge: bridge,
  quaternionService: quaternionService,
  onSystemUpdate: (system, params) {
    // Receive 4D rotation parameters for visualization
    setState(() {
      rot4d = params;
    });
  },
);

// Start the system
synchronizer.start();
mouseAdapter.start(); // or touch, keyboard, etc.
```

---

## Input Methods

### Mouse Input

**Best for**: Web apps, desktop apps, precision control

#### Basic Setup

```dart
final mouseAdapter = MouseInputAdapter(
  bridge: bridge,
  config: MouseInputConfig(
    sensitivity: 0.005,
    invertY: false,
    requireMouseDown: true,  // Only rotate when mouse button pressed
    smoothing: 0.15,
  ),
);

mouseAdapter.start();
```

#### Flutter Integration

```dart
class MouseControlledVisualization extends StatefulWidget {
  @override
  _MouseControlledVisualizationState createState() =>
      _MouseControlledVisualizationState();
}

class _MouseControlledVisualizationState
    extends State<MouseControlledVisualization> {
  late MouseInputAdapter mouseAdapter;
  late SensoryInputBridge bridge;

  @override
  void initState() {
    super.initState();
    bridge = SensoryInputBridge();
    mouseAdapter = MouseInputAdapter(bridge: bridge);
    mouseAdapter.start();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        mouseAdapter.handleMouseMove(
          event.localPosition.dx,
          event.localPosition.dy,
        );
      },
      child: GestureDetector(
        onPanStart: (details) {
          mouseAdapter.handleMouseDown(
            details.localPosition.dx,
            details.localPosition.dy,
          );
        },
        onPanEnd: (_) => mouseAdapter.handleMouseUp(),
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              mouseAdapter.handleMouseWheel(event.scrollDelta.dy);
            }
          },
          child: CustomPaint(
            painter: MyVisualizationPainter(/* ... */),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
```

#### Key Features

- **Drag to rotate**: Click and drag to rotate the visualization
- **Scroll wheel**: Control Z-axis rotation
- **Smooth movements**: Built-in exponential smoothing
- **Configurable sensitivity**: Adjust for different use cases

---

### Touch Input

**Best for**: Mobile web, Flutter mobile apps, tablets

#### Basic Setup

```dart
final touchAdapter = TouchInputAdapter(
  bridge: bridge,
  config: TouchInputConfig(
    sensitivity: 0.008,
    invertY: true,  // Natural touch behavior
    smoothing: 0.2,
    enableMomentum: true,  // Inertia after release
    momentumDecay: 0.95,
  ),
);

touchAdapter.start();
```

#### Flutter Integration

```dart
class TouchControlledVisualization extends StatefulWidget {
  @override
  _TouchControlledVisualizationState createState() =>
      _TouchControlledVisualizationState();
}

class _TouchControlledVisualizationState
    extends State<TouchControlledVisualization> {
  late TouchInputAdapter touchAdapter;

  @override
  void initState() {
    super.initState();
    final bridge = SensoryInputBridge();
    touchAdapter = TouchInputAdapter(bridge: bridge);
    touchAdapter.start();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => touchAdapter.handlePanStart(),
      onPanUpdate: (details) => touchAdapter.handlePan(
        details.delta.dx,
        details.delta.dy,
      ),
      onPanEnd: (_) => touchAdapter.handlePanEnd(),
      onScaleStart: (_) => touchAdapter.handleScaleStart(),
      onScaleUpdate: (details) => touchAdapter.handleScale(
        details.scale,
        details.rotation,
      ),
      child: CustomPaint(
        painter: MyVisualizationPainter(/* ... */),
        size: Size.infinite,
      ),
    );
  }
}
```

#### Key Features

- **Swipe to rotate**: Natural touch gestures
- **Two-finger rotation**: Rotate around Z-axis
- **Momentum/inertia**: Continues rotating after release
- **Multi-touch support**: Scale and rotate simultaneously

---

### Keyboard Input

**Best for**: Desktop apps, web apps, accessibility

#### Basic Setup

```dart
final keyboardAdapter = KeyboardInputAdapter(
  bridge: bridge,
  config: KeyboardInputConfig(
    rotationSpeed: 1.5,
    acceleration: 1.2,  // Speed up when holding keys
    continuousRotation: true,
  ),
);

keyboardAdapter.start();
```

#### Default Key Bindings

- **W / Arrow Up**: Pitch up (rotate forward)
- **S / Arrow Down**: Pitch down (rotate backward)
- **A / Arrow Left**: Yaw left (rotate left)
- **D / Arrow Right**: Yaw right (rotate right)
- **Q**: Roll left (tilt left)
- **E**: Roll right (tilt right)
- **R**: Reset to identity rotation
- **Shift**: Speed boost (hold for faster rotation)
- **Space**: Slow motion (hold for slower rotation)

#### Flutter Integration

```dart
class KeyboardControlledVisualization extends StatefulWidget {
  @override
  _KeyboardControlledVisualizationState createState() =>
      _KeyboardControlledVisualizationState();
}

class _KeyboardControlledVisualizationState
    extends State<KeyboardControlledVisualization> {
  late KeyboardInputAdapter keyboardAdapter;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final bridge = SensoryInputBridge();
    keyboardAdapter = KeyboardInputAdapter(bridge: bridge);
    keyboardAdapter.start();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          keyboardAdapter.handleKeyDown(event.character ?? '');
        } else if (event is RawKeyUpEvent) {
          keyboardAdapter.handleKeyUp(event.character ?? '');
        }
      },
      child: CustomPaint(
        painter: MyVisualizationPainter(/* ... */),
        size: Size.infinite,
      ),
    );
  }
}
```

#### Custom Key Bindings

```dart
final keyboardAdapter = KeyboardInputAdapter(
  bridge: bridge,
  config: KeyboardInputConfig(
    keyBindings: {
      'w': 'pitchUp',
      's': 'pitchDown',
      'a': 'yawLeft',
      'd': 'yawRight',
      'q': 'rollLeft',
      'e': 'rollRight',
      'r': 'reset',
      // Add custom bindings...
    },
  ),
);
```

---

### Gamepad Input

**Best for**: Desktop apps, game-like experiences, accessibility

#### Basic Setup

```dart
final gamepadAdapter = GamepadInputAdapter(
  bridge: bridge,
  config: GamepadInputConfig(
    sensitivity: 2.0,
    deadZone: 0.15,  // Prevent drift
    smoothing: 0.1,
  ),
);

gamepadAdapter.start();
```

#### Standard Gamepad Mapping

- **Left Stick**: Pitch (Y) and Yaw (X) rotation
- **Right Stick**: Roll (X) and fine-tune Yaw (Y)
- **Left Trigger**: Decrease rotation speed
- **Right Trigger**: Increase rotation speed
- **A/Cross Button**: Reset to identity rotation
- **B/Circle Button**: Toggle pause

#### Game Loop Integration

```dart
class GamepadControlledApp extends StatefulWidget {
  @override
  _GamepadControlledAppState createState() => _GamepadControlledAppState();
}

class _GamepadControlledAppState extends State<GamepadControlledApp> {
  late GamepadInputAdapter gamepadAdapter;
  late Timer _gameLoop;

  @override
  void initState() {
    super.initState();
    final bridge = SensoryInputBridge();
    gamepadAdapter = GamepadInputAdapter(bridge: bridge);
    gamepadAdapter.start();

    // Start game loop (60 FPS)
    _gameLoop = Timer.periodic(Duration(milliseconds: 16), (timer) {
      final gamepadState = _getGamepadState(); // Your gamepad API
      gamepadAdapter.update(0.016, state: gamepadState);
    });
  }

  @override
  void dispose() {
    _gameLoop.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MyVisualizationPainter(/* ... */),
      size: Size.infinite,
    );
  }
}
```

---

### Device Motion

**Best for**: Mobile web, Flutter mobile apps (non-AR)

#### Basic Setup

```dart
final motionAdapter = DeviceMotionAdapter(
  bridge: bridge,
  config: DeviceMotionConfig(
    smoothing: 0.3,
    autoCalibrate: true,  // Use starting position as zero
    sensitivity: 1.0,
  ),
);

motionAdapter.start();
```

#### Integration with sensors_plus (Flutter Mobile)

Add to `pubspec.yaml`:

```yaml
dependencies:
  sensors_plus: ^3.0.0
```

Example:

```dart
import 'package:sensors_plus/sensors_plus.dart';

class MotionControlledVisualization extends StatefulWidget {
  @override
  _MotionControlledVisualizationState createState() =>
      _MotionControlledVisualizationState();
}

class _MotionControlledVisualizationState
    extends State<MotionControlledVisualization> {
  late DeviceMotionAdapter motionAdapter;
  late StreamSubscription<GyroscopeEvent> _gyroSubscription;

  @override
  void initState() {
    super.initState();
    final bridge = SensoryInputBridge();
    motionAdapter = DeviceMotionAdapter(bridge: bridge);
    motionAdapter.start();

    // Listen to gyroscope
    _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      motionAdapter.updateFromGyroscope(
        event.x,
        event.y,
        event.z,
        deltaTime: 0.016,
      );
    });
  }

  @override
  void dispose() {
    _gyroSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MyVisualizationPainter(/* ... */),
      size: Size.infinite,
    );
  }
}
```

#### Manual Calibration

```dart
// Calibrate to current orientation as zero
FloatingActionButton(
  onPressed: () => motionAdapter.calibrate(),
  child: Icon(Icons.center_focus_strong),
);
```

---

## Visualization

### Using Canvas Renderer

The SDK provides a high-level `CanvasRenderer` for easy visualization:

```dart
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
import 'package:flutter/material.dart';

class MyVisualizationPainter extends CustomPainter {
  final Map<String, double> rot4d;
  final CanvasRenderer renderer = CanvasRenderer();

  MyVisualizationPainter({required this.rot4d});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    // Render tesseract (4D hypercube)
    renderer.renderTesseract(
      canvas: canvas,
      size: size,
      rotations: rot4d,
      scale: 100.0,
      color: Colors.purple,
      strokeWidth: 2.0,
    );

    // Or render a sphere
    renderer.renderSphere(
      canvas: canvas,
      size: size,
      rotations: rot4d,
      radius: 150.0,
      segments: 30,
      rings: 15,
      baseHue: 200.0,
    );

    // Or render a grid
    renderer.renderGrid(
      canvas: canvas,
      size: size,
      rotations: rot4d,
      gridSize: 10,
      spacing: 20.0,
      color: Colors.white24,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### Custom Geometries

```dart
// Define custom 4D vertices
final vertices = [
  Point4D(1, 0, 0, 0),
  Point4D(0, 1, 0, 0),
  Point4D(0, 0, 1, 0),
  Point4D(0, 0, 0, 1),
];

// Define edges
final edges = [
  [0, 1],
  [1, 2],
  [2, 3],
  [3, 0],
];

// Render
renderer.renderCustomGeometry(
  canvas: canvas,
  size: size,
  rotations: rot4d,
  vertices: vertices,
  edges: edges,
  scale: 150.0,
  color: Colors.cyan,
);
```

### Using WebVisualizationHelper

For more control, use `WebVisualizationHelper`:

```dart
final helper = WebVisualizationHelper(
  canvasWidth: 800,
  canvasHeight: 600,
);

// Start animation loop
helper.startAnimationLoop((deltaTime) {
  // Update rotations from quaternion service
  helper.update4DRotationsFromQuaternion(currentQuaternion);

  // Get rotations for rendering
  final rot4d = helper.get4DRotations();

  // Access performance metrics
  print('FPS: ${helper.metrics.fps}');
  print('Frame time: ${helper.metrics.averageFrameTime}ms');

  // Trigger rebuild
  setState(() {});
});
```

---

## Complete Examples

### Example 1: Mouse-Controlled Tesseract (Flutter Web)

```dart
import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIB34D Tesseract Demo',
      home: TesseractDemo(),
    );
  }
}

class TesseractDemo extends StatefulWidget {
  @override
  _TesseractDemoState createState() => _TesseractDemoState();
}

class _TesseractDemoState extends State<TesseractDemo> {
  late SensoryInputBridge bridge;
  late QuaternionFieldService quaternionService;
  late ShaderQuaternionSynchronizer synchronizer;
  late MouseInputAdapter mouseAdapter;

  Map<String, double> rot4d = {};

  @override
  void initState() {
    super.initState();

    // Initialize SDK
    bridge = SensoryInputBridge();
    quaternionService = QuaternionFieldService();
    synchronizer = ShaderQuaternionSynchronizer(
      bridge: bridge,
      quaternionService: quaternionService,
      onSystemUpdate: (system, params) {
        if (system == 'quaternion') {
          setState(() {
            rot4d = params;
          });
        }
      },
    );

    // Initialize mouse input
    mouseAdapter = MouseInputAdapter(
      bridge: bridge,
      config: MouseInputConfig(sensitivity: 0.005),
    );

    // Start
    synchronizer.start();
    mouseAdapter.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('4D Tesseract - Drag to Rotate')),
      body: MouseRegion(
        onHover: (event) => mouseAdapter.handleMouseMove(
          event.localPosition.dx,
          event.localPosition.dy,
        ),
        child: GestureDetector(
          onPanStart: (details) => mouseAdapter.handleMouseDown(
            details.localPosition.dx,
            details.localPosition.dy,
          ),
          onPanEnd: (_) => mouseAdapter.handleMouseUp(),
          child: CustomPaint(
            painter: TesseractPainter(rot4d: rot4d),
            size: Size.infinite,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mouseAdapter.reset(),
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class TesseractPainter extends CustomPainter {
  final Map<String, double> rot4d;
  final CanvasRenderer renderer = CanvasRenderer();

  TesseractPainter({required this.rot4d});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    if (rot4d.isNotEmpty) {
      renderer.renderTesseract(
        canvas: canvas,
        size: size,
        rotations: rot4d,
        scale: 120.0,
        color: Colors.purple,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### Example 2: Touch-Controlled Sphere (Flutter Mobile)

```dart
import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

class SphereDemo extends StatefulWidget {
  @override
  _SphereDemoState createState() => _SphereDemoState();
}

class _SphereDemoState extends State<SphereDemo> {
  late TouchInputAdapter touchAdapter;
  late ShaderQuaternionSynchronizer synchronizer;
  Map<String, double> rot4d = {};

  @override
  void initState() {
    super.initState();

    final bridge = SensoryInputBridge();
    final quaternionService = QuaternionFieldService();

    synchronizer = ShaderQuaternionSynchronizer(
      bridge: bridge,
      quaternionService: quaternionService,
      onSystemUpdate: (system, params) {
        if (system == 'quaternion') {
          setState(() {
            rot4d = params;
          });
        }
      },
    );

    touchAdapter = TouchInputAdapter(
      bridge: bridge,
      config: TouchInputConfig(
        enableMomentum: true,
        momentumDecay: 0.95,
      ),
    );

    synchronizer.start();
    touchAdapter.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('4D Sphere - Swipe to Rotate')),
      body: GestureDetector(
        onPanStart: (_) => touchAdapter.handlePanStart(),
        onPanUpdate: (details) => touchAdapter.handlePan(
          details.delta.dx,
          details.delta.dy,
        ),
        onPanEnd: (_) => touchAdapter.handlePanEnd(),
        child: CustomPaint(
          painter: SpherePainter(rot4d: rot4d),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class SpherePainter extends CustomPainter {
  final Map<String, double> rot4d;
  final CanvasRenderer renderer = CanvasRenderer();

  SpherePainter({required this.rot4d});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.purple.shade900, Colors.blue.shade900],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    if (rot4d.isNotEmpty) {
      renderer.renderSphere(
        canvas: canvas,
        size: size,
        rotations: rot4d,
        radius: size.width * 0.4,
        segments: 40,
        rings: 20,
        baseHue: 280.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### Example 3: Multi-Input Support

```dart
class MultiInputDemo extends StatefulWidget {
  @override
  _MultiInputDemoState createState() => _MultiInputDemoState();
}

class _MultiInputDemoState extends State<MultiInputDemo> {
  late SensoryInputBridge bridge;
  late MouseInputAdapter mouseAdapter;
  late KeyboardInputAdapter keyboardAdapter;
  late TouchInputAdapter touchAdapter;

  Map<String, double> rot4d = {};

  @override
  void initState() {
    super.initState();

    bridge = SensoryInputBridge();
    final quaternionService = QuaternionFieldService();

    final synchronizer = ShaderQuaternionSynchronizer(
      bridge: bridge,
      quaternionService: quaternionService,
      onSystemUpdate: (system, params) {
        if (system == 'quaternion') {
          setState(() => rot4d = params);
        }
      },
    );

    // Initialize all input adapters (they can coexist!)
    mouseAdapter = MouseInputAdapter(bridge: bridge);
    keyboardAdapter = KeyboardInputAdapter(bridge: bridge);
    touchAdapter = TouchInputAdapter(bridge: bridge);

    synchronizer.start();
    mouseAdapter.start();
    keyboardAdapter.start();
    touchAdapter.start();
  }

  @override
  Widget build(BuildContext context) {
    // Now supports mouse, keyboard, AND touch!
    return Scaffold(
      body: Stack(
        children: [
          // Touch layer
          GestureDetector(
            onPanStart: (_) => touchAdapter.handlePanStart(),
            onPanUpdate: (details) => touchAdapter.handlePan(
              details.delta.dx,
              details.delta.dy,
            ),
            onPanEnd: (_) => touchAdapter.handlePanEnd(),
            child: Container(color: Colors.transparent),
          ),

          // Mouse layer
          MouseRegion(
            onHover: (event) => mouseAdapter.handleMouseMove(
              event.localPosition.dx,
              event.localPosition.dy,
            ),
            child: Container(color: Colors.transparent),
          ),

          // Keyboard layer
          RawKeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            onKey: (event) {
              if (event is RawKeyDownEvent) {
                keyboardAdapter.handleKeyDown(event.character ?? '');
              }
            },
            child: Container(),
          ),

          // Visualization
          CustomPaint(
            painter: MyVisualizationPainter(rot4d: rot4d),
            size: Size.infinite,
          ),
        ],
      ),
    );
  }
}
```

---

## Best Practices

### 1. Choose the Right Input Method

| Platform | Recommended Input | Alternative |
|----------|-------------------|-------------|
| **Flutter Web (Desktop)** | Mouse + Keyboard | Device Motion (on laptops with gyroscope) |
| **Flutter Web (Mobile)** | Touch | Device Motion |
| **Flutter Mobile** | Touch + Device Motion | - |
| **Flutter Desktop** | Mouse + Keyboard | Gamepad |
| **Game-like Apps** | Gamepad | Keyboard |

### 2. Performance Considerations

- **Throttle updates**: Don't update on every pixel of mouse movement
- **Use smoothing**: Reduces jitter and improves visual quality
- **Limit geometry complexity**: For 60 FPS, keep vertex count reasonable
- **Object pooling**: Reuse Point4D objects instead of creating new ones

```dart
// Good: Throttled updates
int _frameCount = 0;
void _onMouseMove(double x, double y) {
  _frameCount++;
  if (_frameCount % 2 == 0) {  // Update every 2nd frame
    mouseAdapter.handleMouseMove(x, y);
  }
}

// Good: Smoothing enabled
final mouseAdapter = MouseInputAdapter(
  bridge: bridge,
  config: MouseInputConfig(smoothing: 0.15),
);
```

### 3. Responsive Design

```dart
class ResponsiveVisualization extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final isMobile = constraints.maxWidth < 600;

        return isDesktop
            ? DesktopVisualization() // Mouse + Keyboard
            : isMobile
                ? MobileVisualization() // Touch
                : TabletVisualization(); // Touch + optional keyboard
      },
    );
  }
}
```

### 4. Accessibility

- Always provide keyboard alternatives
- Support high-contrast modes
- Add text labels for controls
- Provide reset functionality

```dart
// Reset button for accessibility
FloatingActionButton(
  onPressed: () {
    mouseAdapter.reset();
    touchAdapter.reset();
    keyboardAdapter.reset();
  },
  tooltip: 'Reset rotation (R key)',
  child: Icon(Icons.refresh),
);
```

---

## Performance Optimization

### Frame Rate Targets

| Platform | Target FPS | Notes |
|----------|------------|-------|
| **Desktop** | 60 FPS | Can handle complex geometries |
| **Mobile** | 30-60 FPS | Reduce complexity on lower-end devices |
| **Web** | 30-60 FPS | Depends on browser and device |

### Optimization Techniques

#### 1. Level of Detail (LOD)

```dart
class AdaptiveRenderer {
  int getSegments(double fps) {
    if (fps > 50) return 40; // High detail
    if (fps > 30) return 25; // Medium detail
    return 15; // Low detail
  }

  void render(Canvas canvas, Size size, Map<String, double> rot4d, double fps) {
    renderer.renderSphere(
      canvas: canvas,
      size: size,
      rotations: rot4d,
      segments: getSegments(fps),
      rings: getSegments(fps) ~/ 2,
    );
  }
}
```

#### 2. Geometry Caching

```dart
class GeometryCache {
  List<Point4D>? _cachedVertices;

  List<Point4D> getTesseractVertices() {
    if (_cachedVertices == null) {
      _cachedVertices = helper.generateTesseractVertices();
    }
    return _cachedVertices!;
  }
}
```

#### 3. Selective Rendering

```dart
void paint(Canvas canvas, Size size) {
  // Only render what's visible
  final isVisible = _checkVisibility();
  if (!isVisible) return;

  // Render based on distance from camera
  if (_distance < 100) {
    _renderHighDetail();
  } else {
    _renderLowDetail();
  }
}
```

---

## Deployment

### Flutter Web

#### 1. Build for Web

```bash
flutter build web --release
```

#### 2. Optimize Build

Add to `index.html`:

```html
<script>
  // Use CanvasKit renderer for better performance
  window.flutterConfiguration = {
    canvasKitBaseUrl: "https://unpkg.com/canvaskit-wasm@latest/bin/"
  };
</script>
```

#### 3. Deploy to Hosting

**Firebase Hosting:**
```bash
firebase deploy
```

**GitHub Pages:**
```bash
cd build/web
git init
git add .
git commit -m "Deploy"
git push -f https://github.com/username/repo.git main:gh-pages
```

**Netlify:**
- Drag and drop `build/web` folder

### Flutter Mobile

#### 1. Build APK (Android)

```bash
flutter build apk --release
```

#### 2. Build iOS

```bash
flutter build ios --release
```

### Flutter Desktop

#### 1. Build for Desktop

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## Troubleshooting

### Common Issues

#### 1. Input not working

```dart
// Ensure adapter is started
mouseAdapter.start();

// Check focus for keyboard
FocusNode()..requestFocus();
```

#### 2. Visualization not updating

```dart
// Ensure setState is called
onSystemUpdate: (system, params) {
  setState(() {  // Don't forget this!
    rot4d = params;
  });
}
```

#### 3. Poor performance

```dart
// Reduce geometry complexity
renderer.renderSphere(
  segments: 20,  // Instead of 40
  rings: 10,     // Instead of 20
);

// Enable smoothing
config: MouseInputConfig(smoothing: 0.2);
```

#### 4. Touch gestures conflicting

```dart
// Use GestureDetector with specific recognizers
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onPanStart: ...,
  onPanUpdate: ...,
);
```

---

## Next Steps

1. **Try the interactive demo**: `cd demo && bash start_server.sh`
2. **Read FLUTTER_README.md**: Complete API reference
3. **Check example/**: Working Flutter app examples
4. **Explore geometries**: Try different shapes in GeometryLibrary
5. **Join the community**: GitHub issues and discussions

---

## Resources

- **API Reference**: [FLUTTER_README.md](FLUTTER_README.md)
- **Developer Guide**: [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)
- **Interactive Demo**: [demo/](demo/)
- **Examples**: [example/](example/)
- **Performance Guide**: [docs/PERFORMANCE.md](docs/PERFORMANCE.md)

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**

**Pioneering 4D Geometric Processing & XR Spatial Intelligence**

🌟 **Ready to build amazing 3D/4D experiences!** 🌟
