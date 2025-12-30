# VIB34D SDK - Quick Start Guide

**Get started with VIB34D SDK in 5 minutes**

## 🎯 Choose Your Path

### Path 1: I'm a Complete Beginner
**Time**: 5 minutes | **Tool**: Agentic CLI

```bash
# Install CLI
cd cli/vib34d-agent
npm install && npm link

# Run interactive onboarding
vib34d onboard

# Create your first project
vib34d create my-first-viz

# Run it
cd my-first-viz
flutter run -d chrome
```

**What you get**: Complete working app with your chosen platform, input method, and geometry.

---

### Path 2: I Want AI to Help Me Code
**Time**: 2 minutes | **Tool**: Claude Code Skill

**Just describe what you want in natural language:**

```
You: "Create a web app with mouse control showing a rotating tesseract"

Claude: [Generates complete Flutter app with MouseInputAdapter]

You: "Add a purple to cyan gradient"

Claude: [Adds gradient colors]

You: "Make it work on mobile too"

Claude: [Adds touch support with momentum]
```

**What you get**: AI generates, explains, and refines code for you.

---

### Path 3: I Use VS Code
**Time**: 3 minutes | **Tool**: VS Code Extension

```bash
# Install extension
cd vscode-extension/vib34d-visualizer
npm install && vsce package
code --install-extension vib34d-visualizer-1.0.0.vsix

# Use it
# 1. Open Command Palette (Ctrl+Shift+P)
# 2. Type "VIB34D: Create New Project"
# 3. Choose options in GUI
# 4. Project created instantly

# Or use snippets
# 1. Create new .dart file
# 2. Type: vib-app
# 3. Press Tab
# 4. Complete app scaffolded
```

**What you get**: GUI-based project creation, smart snippets, live preview.

---

### Path 4: I'm Building with AI Assistants
**Time**: 3 minutes | **Tool**: MCP Server

```bash
# Start MCP server
cd .claude/mcp
npm install @modelcontextprotocol/sdk
node vib34d-mcp-server.js

# Configure in your AI assistant
# (See CLAUDE_INTEGRATION_GUIDE.md)

# Use MCP tools
vib34d_create_project({
  name: "my-viz",
  template: "web-mouse",
  geometry: "tesseract"
})

vib34d_explain_concept({
  concept: "quaternion",
  level: "beginner"
})
```

**What you get**: 8 AI-powered tools for project creation, debugging, optimization.

---

## 📱 Platform-Specific Quick Starts

### Web App (Desktop)
```bash
vib34d create my-web-viz
# Choose: Web → Mouse → Tesseract
cd my-web-viz
flutter run -d chrome
```

**Result**: Desktop web app with mouse drag controls

### Mobile App
```bash
vib34d create my-mobile-viz
# Choose: Mobile → Touch → Sphere
cd my-mobile-viz
flutter run -d android  # or -d ios
```

**Result**: Mobile app with touch gestures and momentum

### Educational Tool
```bash
vib34d create quaternion-teacher
# Choose: Educational → Keyboard → Custom
cd quaternion-teacher
flutter run -d chrome
```

**Result**: Side-by-side visualization showing quaternion math

---

## 🎨 Feature-Specific Quick Starts

### Add Mouse Control to Existing Project
**VS Code**: Type `vib-mouse` + Tab

**Or manually**:
```dart
final mouseAdapter = MouseInputAdapter(
  bridge: bridge,
  config: MouseInputConfig(
    sensitivity: 0.005,
    smoothing: 0.15,
    requireMouseDown: true,
  ),
);
mouseAdapter.start();
```

### Add Touch Control
**VS Code**: Type `vib-touch` + Tab

**Or manually**:
```dart
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

### Add Keyboard Control
**VS Code**: Type `vib-keyboard` + Tab

**Or manually**:
```dart
final keyboardAdapter = KeyboardInputAdapter(
  bridge: bridge,
  config: KeyboardInputConfig(
    rotationSpeed: 1.5,
    acceleration: 1.2,
  ),
);
keyboardAdapter.start();
```

### Add FPS Counter
**VS Code**: Type `vib-fps` + Tab

**Or manually**:
```dart
double _fps = 0.0;
int _frameCount = 0;
DateTime _lastTime = DateTime.now();

void _updateFPS() {
  _frameCount++;
  final now = DateTime.now();
  final elapsed = now.difference(_lastTime).inMilliseconds;

  if (elapsed >= 1000) {
    setState(() {
      _fps = (_frameCount / elapsed) * 1000.0;
    });
    _frameCount = 0;
    _lastTime = now;
  }

  Future.delayed(Duration(milliseconds: 16), _updateFPS);
}
```

---

## 🔍 Geometry-Specific Quick Starts

### Tesseract (4D Hypercube)
**VS Code**: Type `vib-painter-tesseract` + Tab

**Best for**: Mathematical visualization, wireframe aesthetics

### Sphere
**VS Code**: Type `vib-painter-sphere` + Tab

**Best for**: Smooth organic motion, colorful gradients

### Grid
**Use CanvasRenderer**:
```dart
renderer.renderGrid(
  canvas: canvas,
  size: size,
  rotations: rot4d,
  gridSize: 10,
  spacing: 30.0,
);
```

**Best for**: Data visualization, architectural views

---

## 🐛 Common Issues & Quick Fixes

### Issue: Rotation is too fast
**Fix**: Reduce sensitivity
```dart
MouseInputConfig(sensitivity: 0.002)  // Lower = slower
```

### Issue: Rotation is jerky
**Fix**: Increase smoothing
```dart
MouseInputConfig(smoothing: 0.25)  // Higher = smoother
```

### Issue: Touch doesn't feel natural
**Fix**: Enable momentum
```dart
TouchInputConfig(
  enableMomentum: true,
  momentumDecay: 0.96,
)
```

### Issue: Performance is poor
**Fix 1**: Reduce geometry complexity
```dart
renderer.renderSphere(
  segments: 20,  // Lower = faster
  rings: 10,     // Lower = faster
)
```

**Fix 2**: Use MCP optimize tool
```bash
vib34d_optimize({
  code: "your code",
  target_fps: 60,
  platform: "mobile"
})
```

---

## 📖 What to Read Next

### If you want to understand the SDK
→ Read `WEB_APP_GUIDE.md` (comprehensive tutorial)

### If you want to integrate with React/Vue
→ Read `WEB_FRAMEWORKS_INTEGRATION.md`

### If you want Flutter Web specific info
→ Read `FLUTTER_WEB_GUIDE.md`

### If you want AI integration details
→ Read `CLAUDE_INTEGRATION_GUIDE.md`

### If you want to see example code
→ Check `examples/web_examples/`

### If you want future feature ideas
→ Read `SDK_ENHANCEMENT_ROADMAP.md`

---

## 🎓 Learning Path

### Week 1: Basics
1. Run `vib34d onboard`
2. Create 3 projects (web, mobile, desktop)
3. Experiment with different input methods
4. Read quaternion explanations

### Week 2: Customization
1. Modify colors and styles
2. Adjust sensitivity and smoothing
3. Create custom geometry
4. Add FPS counter and performance monitoring

### Week 3: Advanced
1. Integrate with existing Flutter app
2. Create custom input adapter
3. Build multi-platform app
4. Optimize for production

### Week 4: Contribution
1. Build something cool
2. Share on GitHub
3. Contribute to roadmap
4. Help other developers

---

## 💡 Pro Tips

**Tip 1**: Start with templates, customize later
```bash
vib34d create my-viz
# Get working code first, then modify
```

**Tip 2**: Use VS Code snippets for speed
```
vib-mouse → Full mouse adapter
vib-touch → Full touch adapter
vib-app → Complete application
```

**Tip 3**: Ask Claude to explain concepts
```
"Explain how quaternion smoothing works"
"Why use quaternions instead of Euler angles?"
"How does the synchronizer work?"
```

**Tip 4**: Check examples for patterns
```bash
cd examples/web_examples
# See 01_simple_mouse_rotation.dart
# See 02_educational_euler_angles.dart
# See 03_mobile_touch_interface.dart
```

**Tip 5**: Use MCP for debugging
```javascript
vib34d_debug_quaternion({
  quaternion: { x: 0.5, y: 0.5, z: 0.5, w: 0.5 },
  issue: "Rotation seems off"
})
```

---

## 🚀 Deploy Your App

### Deploy to GitHub Pages
```bash
flutter build web --release --web-renderer canvaskit
# Upload build/web to GitHub Pages
```

### Deploy to Firebase
```bash
flutter build web --release
firebase deploy
```

### Deploy to Netlify
```bash
flutter build web --release
# Drag build/web folder to Netlify
```

See `FLUTTER_WEB_GUIDE.md` for detailed deployment instructions.

---

## 🤝 Get Help

**GitHub Issues**: Report bugs or request features
**Documentation**: Read the comprehensive guides
**Examples**: Check working code in `examples/`
**Claude Code**: Ask questions in natural language
**MCP**: Use `vib34d_explain_concept` tool

---

## 📊 Quick Reference

| I want to... | Use this... | Command/Snippet |
|--------------|-------------|-----------------|
| Create new project | CLI or VS Code | `vib34d create` or Command Palette |
| Add mouse input | VS Code snippet | `vib-mouse` |
| Add touch input | VS Code snippet | `vib-touch` |
| Add keyboard input | VS Code snippet | `vib-keyboard` |
| Create tesseract | VS Code snippet | `vib-painter-tesseract` |
| Create sphere | VS Code snippet | `vib-painter-sphere` |
| Add FPS counter | VS Code snippet | `vib-fps` |
| Explain concept | CLI or MCP | `vib34d explain` |
| Debug quaternion | MCP | `vib34d_debug_quaternion` |
| Optimize code | MCP or CLI | `vib34d_optimize` |
| Complete app | VS Code snippet | `vib-app` |

---

**Ready to create amazing 4D visualizations?** Pick a path above and start coding! 🎨

**Questions?** Check `CLAUDE_CODE_COMPLETE_INTEGRATION.md` for comprehensive integration details.
