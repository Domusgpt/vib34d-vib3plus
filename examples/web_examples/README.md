# Web Examples - VIB34D SDK

This directory contains complete, runnable examples demonstrating various use cases for the VIB34D XR Quaternion SDK in web and non-AR applications.

---

## Examples Overview

### 1. Simple Mouse Rotation (`01_simple_mouse_rotation.dart`)

**What it demonstrates:**
- Basic mouse input setup
- Click-and-drag rotation
- Simple tesseract rendering
- FPS tracking
- Reset functionality

**Best for:**
- Getting started
- Desktop web applications
- Learning the basics

**How to run:**
```bash
# Copy to your Flutter project's lib/ folder
cp 01_simple_mouse_rotation.dart your_project/lib/main.dart

# Run
cd your_project
flutter run -d chrome
```

**Controls:**
- Click and drag mouse to rotate
- Release to stop
- Click "Reset" button or press F5

---

### 2. Educational Euler Angles (`02_educational_euler_angles.dart`)

**What it demonstrates:**
- Quaternion → Euler angle conversion
- Real-time data display
- Multiple input methods (mouse + keyboard)
- Educational visualization
- Data-driven UI

**Best for:**
- Educational applications
- Learning quaternion mathematics
- Debugging rotation systems
- Scientific visualization

**How to run:**
```bash
cp 02_educational_euler_angles.dart your_project/lib/main.dart
cd your_project
flutter run -d chrome
```

**Controls:**
- **Mouse:** Click and drag
- **Keyboard:**
  - W/S: Pitch up/down
  - A/D: Yaw left/right
  - Q/E: Roll left/right
  - R: Reset
  - Shift: Speed boost
  - Space: Slow motion

**Educational Value:**
- See how quaternions convert to Euler angles
- Understand roll, pitch, yaw
- Visualize 4D rotation parameters
- Learn coordinate systems

---

### 3. Mobile Touch Interface (`03_mobile_touch_interface.dart`)

**What it demonstrates:**
- Touch gesture handling
- Swipe-to-rotate
- Two-finger rotation
- Momentum/inertia
- Mobile-optimized UI
- Performance-conscious rendering
- Geometry switching

**Best for:**
- Mobile web applications
- Flutter mobile apps (non-AR)
- Tablet applications
- Touch-first experiences

**How to run:**
```bash
# For mobile web
cp 03_mobile_touch_interface.dart your_project/lib/main.dart
cd your_project
flutter run -d chrome  # Then open in mobile browser

# For Flutter mobile (Android/iOS)
flutter run -d <device_id>
```

**Controls:**
- **Swipe:** Rotate geometry
- **Two fingers:** Rotate around Z-axis
- **Release:** Momentum continues rotation
- **Bottom buttons:** Switch geometry
- **Reset button:** Return to identity rotation
- **Help icon:** Toggle help overlay

**Features:**
- Auto-hiding help overlay
- Three geometry types (Tesseract, Sphere, Grid)
- Reduced polygon count for mobile performance
- Smooth momentum physics

---

## Running the Examples

### Prerequisites

1. **Flutter SDK** installed
2. **VIB34D SDK** added to your project:

```yaml
# pubspec.yaml
dependencies:
  vib34d_xr_quaternion_sdk:
    path: ../vib34d-vib3plus  # Adjust path
  flutter:
    sdk: flutter
  vector_math: ^2.1.4
```

### Quick Start

```bash
# 1. Create new Flutter project
flutter create my_vib34d_demo

# 2. Add SDK dependency to pubspec.yaml

# 3. Copy an example
cp 01_simple_mouse_rotation.dart my_vib34d_demo/lib/main.dart

# 4. Run
cd my_vib34d_demo
flutter run -d chrome  # For web
flutter run -d <device>  # For mobile/desktop
```

### Platform Targets

| Platform | Command | Notes |
|----------|---------|-------|
| **Web** | `flutter run -d chrome` | Best with Example 1 or 2 |
| **Mobile** | `flutter run -d <device_id>` | Best with Example 3 |
| **Desktop** | `flutter run -d windows/macos/linux` | Works with all examples |

---

## Customization Ideas

### Change Colors

```dart
// In the Painter class
renderer.renderTesseract(
  canvas: canvas,
  size: size,
  rotations: rot4d,
  color: Colors.cyan,  // Change this!
  strokeWidth: 3.0,    // Thicker lines
);
```

### Add More Geometries

```dart
// Use the geometry library
final geometryIndex = GeometryLibrary.getIndex(5, 1);  // Klein bottle, core 1
final params = GeometryLibrary.getVariationParameters(geometryIndex);
```

### Adjust Sensitivity

```dart
// For mouse
MouseInputConfig(
  sensitivity: 0.01,  // Higher = more sensitive
  smoothing: 0.3,     // Higher = smoother
)

// For touch
TouchInputConfig(
  sensitivity: 0.015,
  momentumDecay: 0.98,  // Higher = longer momentum
)
```

### Change Background

```dart
// Solid color
canvas.drawRect(
  Rect.fromLTWH(0, 0, size.width, size.height),
  Paint()..color = Colors.deepPurple[900]!,
);

// Gradient
final gradient = LinearGradient(
  colors: [Colors.indigo[900]!, Colors.purple[900]!],
);
canvas.drawRect(
  rect,
  Paint()..shader = gradient.createShader(rect),
);
```

---

## Performance Tips

### For Web

1. **Use CanvasKit renderer** (better performance):
```html
<!-- In index.html -->
<script>
  window.flutterConfiguration = {
    renderer: "canvaskit"
  };
</script>
```

2. **Reduce geometry complexity**:
```dart
renderer.renderSphere(
  segments: 20,  // Instead of 40
  rings: 10,     // Instead of 20
);
```

### For Mobile

1. **Use fewer vertices**:
```dart
// Mobile-optimized
renderer.renderSphere(
  segments: 15,
  rings: 8,
);
```

2. **Enable smoothing**:
```dart
TouchInputConfig(
  smoothing: 0.25,  // Reduces update frequency
)
```

3. **Throttle updates**:
```dart
int _frameCount = 0;
void handlePan(double dx, double dy) {
  _frameCount++;
  if (_frameCount % 2 == 0) {  // Every other frame
    touchAdapter.handlePan(dx, dy);
  }
}
```

---

## Combining Examples

You can combine features from multiple examples:

```dart
class CombinedDemo extends StatefulWidget {
  @override
  _CombinedDemoState createState() => _CombinedDemoState();
}

class _CombinedDemoState extends State<CombinedDemo> {
  // Combine mouse, touch, AND keyboard!
  late MouseInputAdapter mouseAdapter;
  late TouchInputAdapter touchAdapter;
  late KeyboardInputAdapter keyboardAdapter;

  @override
  void initState() {
    super.initState();

    final bridge = SensoryInputBridge();

    mouseAdapter = MouseInputAdapter(bridge: bridge);
    touchAdapter = TouchInputAdapter(bridge: bridge);
    keyboardAdapter = KeyboardInputAdapter(bridge: bridge);

    mouseAdapter.start();
    touchAdapter.start();
    keyboardAdapter.start();
  }

  @override
  Widget build(BuildContext context) {
    // Stack all input layers
    return Stack(
      children: [
        // Touch layer
        GestureDetector(
          onPanUpdate: (details) => touchAdapter.handlePan(
            details.delta.dx,
            details.delta.dy,
          ),
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
          onKey: (event) { /* handle keyboard */ },
          child: Container(),
        ),

        // Visualization
        CustomPaint(
          painter: MyPainter(rot4d: rot4d),
        ),
      ],
    );
  }
}
```

---

## Troubleshooting

### Example doesn't rotate
- Ensure `adapter.start()` is called
- Check that `synchronizer.start()` is called
- Verify `setState()` is called in `onSystemUpdate`

### Poor performance
- Reduce geometry complexity
- Enable smoothing
- Use throttling
- Check FPS counter

### Touch gestures not working
- Ensure `GestureDetector` wraps the visualization
- Check `handlePanStart()` and `handlePanEnd()` are called
- Verify `Container(color: Colors.transparent)` for hit testing

### Keyboard not responding
- Check `FocusNode` is set and focused
- Call `focusNode.requestFocus()`
- Verify `RawKeyboardListener` wraps your widget

---

## Next Steps

1. **Try all three examples** to understand different input methods
2. **Customize colors and geometries** to make them your own
3. **Read WEB_APP_GUIDE.md** for comprehensive documentation
4. **Explore FLUTTER_README.md** for complete API reference
5. **Build your own** combining concepts from multiple examples!

---

## Resources

- **Complete Guide:** [WEB_APP_GUIDE.md](../../WEB_APP_GUIDE.md)
- **API Reference:** [FLUTTER_README.md](../../FLUTTER_README.md)
- **Interactive Demo:** [demo/](../../demo/)
- **Developer Guide:** [DEVELOPER_GUIDE.md](../../DEVELOPER_GUIDE.md)

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**

Happy coding! 🚀
