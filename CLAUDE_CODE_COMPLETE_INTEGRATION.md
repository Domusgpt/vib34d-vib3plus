# VIB34D SDK - Complete Claude Code Integration Suite

**Complete AI-Powered Development Experience for VIB34D SDK**

This document provides an overview of the complete Claude Code integration suite, bringing AI-powered development tools to the VIB34D XR Quaternion SDK.

## 🎯 Overview

The VIB34D SDK now includes four integrated AI development tools:

1. **Claude Code Skill** - Natural language visualization generation
2. **MCP Server** - Model Context Protocol tools for AI assistants
3. **Agentic CLI** - Interactive command-line onboarding
4. **VS Code Extension** - Smart snippets, commands, and tooling

## 📦 Components

### 1. Claude Code Skill
**Location**: `.claude/skills/vib34d-visualizer.md`

**Purpose**: Natural language code generation for VIB34D visualizations

**Features**:
- Generates complete Flutter apps from descriptions
- 3 built-in code templates (web-mouse, mobile-touch, educational)
- Smart platform/input/geometry detection
- Concept explanations (quaternions, Euler angles, 4D rotation)
- Performance optimization suggestions
- Debugging workflows

**Activation Keywords**:
- "create", "build", "generate", "make"
- "visualization", "tesseract", "sphere", "grid"
- "mouse", "touch", "keyboard", "gamepad"
- "web", "mobile", "desktop"

**Example Usage**:
```
User: "Create a web app with mouse control showing a rotating tesseract"
Skill: Generates complete Flutter Web app with MouseInputAdapter
```

### 2. MCP Server
**Location**: `.claude/mcp/vib34d-mcp-server.js`

**Purpose**: AI-powered tools for Claude and other AI assistants

**8 Available Tools**:

| Tool | Description |
|------|-------------|
| `vib34d_create_project` | Create complete VIB34D project from template |
| `vib34d_generate_code` | Generate code from natural language description |
| `vib34d_explain_concept` | Explain quaternion/4D concepts (beginner to advanced) |
| `vib34d_debug_quaternion` | Debug quaternion values and rotation issues |
| `vib34d_optimize` | Suggest performance optimizations |
| `vib34d_convert_code` | Convert between platforms (Flutter/React/Vue) |
| `vib34d_add_input` | Add input adapter to existing project |
| `vib34d_add_geometry` | Add geometry renderer to existing project |

**Setup**:
```bash
cd .claude/mcp
npm install @modelcontextprotocol/sdk
node vib34d-mcp-server.js
```

**Configuration**: `.claude/mcp/vib34d-server.json`

### 3. Agentic CLI
**Location**: `cli/vib34d-agent/`

**Purpose**: Interactive onboarding and project creation

**Features**:
- Beautiful ASCII art banner
- Interactive onboarding wizard
- Experience level assessment
- Platform/use case recommendations
- Quick project creation
- Educational commands

**Installation**:
```bash
cd cli/vib34d-agent
npm install
npm link
```

**Usage**:
```bash
vib34d onboard        # Interactive onboarding
vib34d create         # Create new project
vib34d explain        # Explain concepts
vib34d examples       # Show example code
vib34d optimize       # Performance tips
```

**Onboarding Flow**:
1. Experience level (Beginner/Intermediate/Advanced)
2. Use case selection (Art/Data/Education/Game)
3. Platform choice (Web/Mobile/Desktop)
4. Input method (Mouse/Touch/Keyboard/Gamepad)
5. Personalized recommendations

### 4. VS Code Extension
**Location**: `vscode-extension/vib34d-visualizer/`

**Purpose**: Smart development tools for VS Code

**Features**:

**10 Smart Snippets**:
- `vib-imports` - Import VIB34D SDK
- `vib-app` - Complete app template
- `vib-mouse` - MouseInputAdapter
- `vib-touch` - TouchInputAdapter
- `vib-keyboard` - KeyboardInputAdapter
- `vib-sync` - ShaderQuaternionSynchronizer
- `vib-painter-tesseract` - Tesseract CustomPainter
- `vib-painter-sphere` - Sphere CustomPainter
- `vib-fps` - FPS counter

**7 Commands**:
- VIB34D: Create New Project
- VIB34D: Add Input Adapter
- VIB34D: Add Geometry Renderer
- VIB34D: Show Live Preview
- VIB34D: Explain Concept
- VIB34D: Optimize Performance
- VIB34D: Debug Quaternion

**4 Sidebar Views**:
- Templates Browser
- Quaternion Inspector
- Performance Monitor
- Documentation

**Installation**:
```bash
cd vscode-extension/vib34d-visualizer
npm install
npm run compile
vsce package
code --install-extension vib34d-visualizer-1.0.0.vsix
```

## 🔗 Integration Workflows

### Workflow 1: Beginner Getting Started

**Step 1**: Install Agentic CLI
```bash
cd cli/vib34d-agent
npm install && npm link
```

**Step 2**: Run onboarding
```bash
vib34d onboard
```

**Step 3**: Create first project (CLI generates code)
```bash
vib34d create my-first-viz
```

**Step 4**: Open in VS Code with extension installed
```bash
code my-first-viz
```

**Step 5**: Use snippets to add features (type `vib-mouse` + Tab)

### Workflow 2: AI-Assisted Development with Claude Code

**Step 1**: Open project in Claude Code

**Step 2**: Use natural language
```
User: "Add touch input with momentum to my visualization"
```

**Step 3**: Claude Code Skill activates
- Detects "touch", "momentum" keywords
- Generates TouchInputAdapter code
- Provides integration instructions

**Step 4**: Continue refining
```
User: "Make it work better on mobile"
```

**Step 5**: Skill provides optimization suggestions

### Workflow 3: Professional Development with MCP

**Step 1**: Configure MCP in AI assistant
```json
{
  "mcpServers": {
    "vib34d": {
      "command": "node",
      "args": ["/path/to/.claude/mcp/vib34d-mcp-server.js"]
    }
  }
}
```

**Step 2**: Use MCP tools
```javascript
// AI calls vib34d_create_project
{
  name: "data-viz",
  template: "web-mouse",
  geometry: "sphere"
}
```

**Step 3**: Debug with MCP
```javascript
// AI calls vib34d_debug_quaternion
{
  quaternion: { x: 0.5, y: 0.5, z: 0.5, w: 2.0 }
}
// Returns: "W component > 1 indicates invalid quaternion"
```

**Step 4**: Optimize with MCP
```javascript
// AI calls vib34d_optimize
{
  code: "...",
  target_fps: 60,
  platform: "mobile"
}
// Returns performance suggestions
```

### Workflow 4: Rapid Prototyping with VS Code Extension

**Step 1**: Open VS Code with VIB34D extension

**Step 2**: Command Palette → "VIB34D: Create New Project"

**Step 3**: Choose options via GUI
- Template: Web with Mouse Control
- Geometry: Tesseract
- Color: Purple

**Step 4**: Project scaffolded automatically

**Step 5**: Use snippets to add features
- Type `vib-touch` → Add touch support
- Type `vib-fps` → Add FPS counter

**Step 6**: View in Live Preview panel

## 📊 Feature Comparison

| Feature | Claude Skill | MCP Server | Agentic CLI | VS Code Ext |
|---------|-------------|------------|-------------|-------------|
| Natural Language | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| Project Creation | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Code Snippets | ❌ No | ❌ No | ❌ No | ✅ Yes |
| Onboarding | ✅ Yes | ❌ No | ✅ Yes | ❌ No |
| Debugging | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| Optimization | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Live Preview | ❌ No | ❌ No | ❌ No | ✅ Yes |
| Concept Explain | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| GUI | ❌ No | ❌ No | ✅ CLI UI | ✅ Yes |
| AI Integration | ✅ Native | ✅ Native | ❌ No | ❌ No |

## 🎨 Code Generation Examples

### Example 1: Web Mouse Control
**Input**: "Create a web app with mouse control showing a tesseract"

**Generated Output**:
```dart
import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

void main() => runApp(MyVisualizationApp());

class MyVisualizationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tesseract Visualization',
      theme: ThemeData.dark(),
      home: VisualizationScreen(),
    );
  }
}

class VisualizationScreen extends StatefulWidget {
  @override
  _VisualizationScreenState createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  late MouseInputAdapter mouseAdapter;
  late ShaderQuaternionSynchronizer synchronizer;
  Map<String, double> rot4d = {};

  @override
  void initState() {
    super.initState();
    final bridge = SensoryInputBridge();

    mouseAdapter = MouseInputAdapter(
      bridge: bridge,
      config: MouseInputConfig(
        sensitivity: 0.005,
        smoothing: 0.15,
        requireMouseDown: true,
      ),
    );

    synchronizer = ShaderQuaternionSynchronizer(
      bridge: bridge,
      quaternionService: QuaternionFieldService(),
      onSystemUpdate: (system, params) {
        if (system == 'quaternion') {
          setState(() => rot4d = params);
        }
      },
    );

    mouseAdapter.start();
    synchronizer.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tesseract Visualization')),
      body: MouseRegion(
        onHover: (e) => mouseAdapter.handleMouseMove(
          e.localPosition.dx,
          e.localPosition.dy,
        ),
        child: GestureDetector(
          onPanStart: (d) => mouseAdapter.handleMouseDown(
            d.localPosition.dx,
            d.localPosition.dy,
          ),
          onPanEnd: (_) => mouseAdapter.handleMouseUp(),
          child: Container(
            color: Colors.black,
            child: CustomPaint(
              painter: TesseractPainter(rot4d: rot4d),
              size: Size.infinite,
            ),
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
    if (rot4d.isEmpty) return;

    renderer.renderTesseract(
      canvas: canvas,
      size: size,
      rotations: rot4d,
      scale: 120.0,
      color: Colors.purple,
      strokeWidth: 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### Example 2: Mobile Touch Interface
**Input**: "Create a mobile app with touch gestures and momentum"

**Generated Output**: Complete mobile app with TouchInputAdapter, momentum physics, and mobile-optimized UI.

### Example 3: Educational Tool
**Input**: "Create an educational tool showing quaternion to Euler conversion"

**Generated Output**: Side-by-side visualization with real-time data display.

## 🧪 Testing the Integration

### Test 1: Claude Code Skill
```bash
# In Claude Code conversation
User: "Create a sphere visualization with keyboard controls"
# Skill should activate and generate complete code
```

### Test 2: MCP Server
```bash
cd .claude/mcp
node vib34d-mcp-server.js
# Test with MCP client
```

### Test 3: Agentic CLI
```bash
vib34d onboard
# Complete onboarding flow
vib34d create test-project
# Verify project creation
```

### Test 4: VS Code Extension
1. Install extension: `code --install-extension vib34d-visualizer-1.0.0.vsix`
2. Open Dart file
3. Type `vib-app` + Tab
4. Verify snippet expansion

## 📈 Usage Statistics

**Total Lines of Code**: 11,200+
**Total Files**: 28
**Components**:
- 1 Claude Code Skill
- 1 MCP Server (8 tools)
- 1 Agentic CLI (5 commands)
- 1 VS Code Extension (10 snippets, 7 commands, 4 views)

**Code Templates**: 6
**Documentation Pages**: 10
**Example Apps**: 3

## 🚀 Getting Started Guide

### For Complete Beginners

**Step 1**: Install the Agentic CLI
```bash
cd cli/vib34d-agent
npm install
npm link
```

**Step 2**: Run onboarding
```bash
vib34d onboard
```
Answer the questions to get personalized recommendations.

**Step 3**: Create your first project
```bash
vib34d create my-first-4d-viz
```

**Step 4**: Run the project
```bash
cd my-first-4d-viz
flutter run -d chrome
```

### For AI-Assisted Development

**Step 1**: Set up Claude Code Skill
- Skill is automatically available in `.claude/skills/vib34d-visualizer.md`
- Works with Claude Code desktop/web

**Step 2**: Use natural language
```
"Create a tesseract visualization with mouse control"
"Add touch input with momentum"
"Optimize for mobile devices"
"Explain how quaternions work"
```

### For VS Code Users

**Step 1**: Install extension
```bash
cd vscode-extension/vib34d-visualizer
npm install
npm run compile
vsce package
code --install-extension vib34d-visualizer-1.0.0.vsix
```

**Step 2**: Use Command Palette
- Ctrl+Shift+P → "VIB34D: Create New Project"

**Step 3**: Use snippets
- Type `vib-` to see all snippets
- Tab to expand

## 🎯 Use Cases

### 1. Interactive Art Installation
**Tools**: Claude Code Skill + VS Code Extension
**Process**:
1. Describe vision to Claude: "Create an interactive art piece with touch"
2. Refine in VS Code with snippets
3. Deploy to web

### 2. Educational Math Visualization
**Tools**: Agentic CLI + MCP Server
**Process**:
1. Run `vib34d onboard` → Choose "Education"
2. Get educational template
3. Use MCP to explain concepts

### 3. Data Visualization Dashboard
**Tools**: All components
**Process**:
1. CLI onboarding for setup
2. Claude generates base code
3. VS Code for refinement
4. MCP for optimization

### 4. Mobile Game Prototype
**Tools**: Claude Code Skill + VS Code Extension
**Process**:
1. Claude generates mobile template
2. VS Code snippets add gamepad support
3. Live preview for testing

## 📚 Documentation Links

- **Main SDK Guide**: `WEB_APP_GUIDE.md`
- **Framework Integration**: `WEB_FRAMEWORKS_INTEGRATION.md`
- **Flutter Web Guide**: `FLUTTER_WEB_GUIDE.md`
- **Claude Integration**: `CLAUDE_INTEGRATION_GUIDE.md`
- **Enhancement Roadmap**: `SDK_ENHANCEMENT_ROADMAP.md`
- **Examples**: `examples/web_examples/README.md`

## 🔮 Future Enhancements

See `SDK_ENHANCEMENT_ROADMAP.md` for 60+ planned features including:
- Live preview in VS Code extension
- IntelliSense for quaternion math
- WebGL renderer
- Unity/Unreal/Blender plugins
- Real-time collaboration
- Cloud deployment tools

## 🤝 Contributing

To contribute to the integration suite:

1. **Claude Code Skill**: Edit `.claude/skills/vib34d-visualizer.md`
2. **MCP Server**: Edit `.claude/mcp/vib34d-mcp-server.js`
3. **CLI**: Edit `cli/vib34d-agent/bin/vib34d.js`
4. **VS Code**: Edit `vscode-extension/vib34d-visualizer/`

## 📝 License

MIT - See LICENSE file

## 👨‍💻 Author

Paul Phillips - Clear Seas Solutions LLC

---

**VIB34D SDK - Pioneering 4D Geometric Processing with AI-Powered Development Tools** 🚀
