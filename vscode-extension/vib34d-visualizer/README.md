# VIB34D Visualizer - VS Code Extension

**Complete development toolkit for VIB34D SDK**

## Features

### 🎨 Code Generation
- **Create New Project**: Full project scaffolding with templates
- **Add Input Adapters**: Mouse, Touch, Keyboard, Gamepad, Motion
- **Add Geometry Renderers**: Tesseract, Sphere, Grid, Custom

### ⚡ Smart Snippets
- `vib-imports` - Import VIB34D SDK
- `vib-app` - Complete app template
- `vib-mouse` - MouseInputAdapter
- `vib-touch` - TouchInputAdapter
- `vib-keyboard` - KeyboardInputAdapter
- `vib-sync` - ShaderQuaternionSynchronizer
- `vib-painter-tesseract` - Tesseract CustomPainter
- `vib-painter-sphere` - Sphere CustomPainter
- `vib-fps` - FPS counter

### 🔍 Quaternion Inspector
- Real-time quaternion values
- Euler angle conversion
- Normalization status
- 4D rotation parameters
- Visual representation

### 📊 Performance Monitor
- FPS tracking
- Frame time analysis
- Memory usage
- Bottleneck detection
- Optimization suggestions

### 📚 Integrated Documentation
- Quick concept explanations
- API reference
- Code examples
- Best practices
- Troubleshooting guides

### 🐛 Debugging Tools
- Quaternion debugger (right-click selection)
- Rotation validation
- Performance profiler
- Code optimizer

## Installation

### From VSIX
1. Download `vib34d-visualizer-1.0.0.vsix`
2. Open VS Code
3. Go to Extensions (Ctrl+Shift+X)
4. Click "..." → "Install from VSIX"
5. Select the downloaded file

### From Source
```bash
cd vscode-extension/vib34d-visualizer
npm install
npm run compile
vsce package
code --install-extension vib34d-visualizer-1.0.0.vsix
```

## Usage

### Create New Project
1. Open Command Palette (Ctrl+Shift+P)
2. Type "VIB34D: Create New Project"
3. Choose template:
   - Web with Mouse Control
   - Mobile with Touch Control
   - Desktop with Keyboard Control
   - Educational Tool
   - Gallery Showcase
4. Enter project name
5. Select geometry (Tesseract/Sphere/Grid)
6. Choose color scheme

### Use Snippets
1. Open a Dart file
2. Type snippet prefix (e.g., `vib-mouse`)
3. Press Tab to expand
4. Fill in placeholders

### Show Live Preview
1. Open a VIB34D Flutter file
2. Run "VIB34D: Show Live Preview" command
3. Preview appears in side panel
4. Updates in real-time as you code

### Debug Quaternion
1. Select quaternion code
2. Right-click → "VIB34D: Debug Quaternion"
3. View analysis in output panel

## Commands

| Command | Description | Shortcut |
|---------|-------------|----------|
| `VIB34D: Create New Project` | Create new project | - |
| `VIB34D: Add Input Adapter` | Add input method | - |
| `VIB34D: Add Geometry Renderer` | Add geometry | - |
| `VIB34D: Show Live Preview` | Open live preview | - |
| `VIB34D: Explain Concept` | Explain quaternion/4D | - |
| `VIB34D: Optimize Performance` | Get optimization tips | - |
| `VIB34D: Debug Quaternion` | Debug quaternion values | Right-click |

## Configuration

```json
{
  "vib34d.autoPreview": false,
  "vib34d.defaultPlatform": "web",
  "vib34d.defaultInput": "mouse",
  "vib34d.snippetsEnabled": true,
  "vib34d.livePreviewPort": 8080
}
```

## Sidebar Views

### Templates
- Browse project templates
- One-click project creation
- Template customization

### Quaternion Inspector
- Current quaternion values (x, y, z, w)
- Euler angles (roll, pitch, yaw)
- 4D rotation parameters
- Normalization status
- Visual representation

### Performance Monitor
- Real-time FPS
- Frame time graph
- Memory usage
- Optimization suggestions

### Documentation
- Quick reference
- API docs
- Code examples
- Troubleshooting

## Examples

### Create Tesseract App
```dart
// Type: vib-app
// Generates complete app with mouse input
```

### Add Touch Input
```dart
// Type: vib-touch
final touchAdapter = TouchInputAdapter(
  bridge: bridge,
  config: TouchInputConfig(
    sensitivity: 0.008,
    enableMomentum: true,
    momentumDecay: 0.95,
  ),
);
touchAdapter.start();
```

### Create Sphere Painter
```dart
// Type: vib-painter-sphere
class SpherePainter extends CustomPainter {
  final Map<String, double> rot4d;
  final CanvasRenderer renderer = CanvasRenderer();

  SpherePainter({required this.rot4d});

  @override
  void paint(Canvas canvas, Size size) {
    if (rot4d.isEmpty) return;

    renderer.renderSphere(
      canvas: canvas,
      size: size,
      rotations: rot4d,
      radius: size.width * 0.35,
      segments: 30,
      rings: 15,
      baseHue: 280.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

## Troubleshooting

### Extension Not Loading
- Ensure VS Code version >= 1.80.0
- Restart VS Code
- Check Output panel for errors

### Snippets Not Working
- Verify file is saved as `.dart`
- Check `vib34d.snippetsEnabled` setting
- Restart VS Code

### Live Preview Not Showing
- Check `vib34d.livePreviewPort` setting
- Ensure port is available
- Check firewall settings

## Contributing

Found a bug? Have a feature request?
- GitHub: https://github.com/yourusername/vib34d-vib3plus
- Issues: https://github.com/yourusername/vib34d-vib3plus/issues

## License

MIT

## Credits

Created by Paul Phillips - Clear Seas Solutions LLC
VIB34D SDK - Pioneering 4D Geometric Processing

---

**Enjoy creating amazing 4D visualizations!** 🚀
