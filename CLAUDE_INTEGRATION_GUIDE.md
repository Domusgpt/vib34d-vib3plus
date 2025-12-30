# Claude Code Integration Guide

**Using VIB34D SDK with Claude Code - Complete Setup**

---

## What's Included

The VIB34D SDK now has **complete Claude Code integration**:

1. **Claude Code Skill** - Natural language visualization generation
2. **MCP Server** - Model Context Protocol for AI tools
3. **Agentic CLI** - Interactive onboarding and code generation
4. **Extension Ideas** - Future VS Code extension

---

## 1. Claude Code Skill

### Location
`.claude/skills/vib34d-visualizer.md`

### What It Does
Enables Claude Code to generate VIB34D visualizations from natural language.

### Usage

Just describe what you want in Claude Code:

```
You: "Create a mouse-controlled tesseract for web"

Claude: I'll create a Flutter Web app with mouse input and tesseract rendering.
        [Generates complete code]

You: "Add FPS counter"

Claude: I'll add a performance counter to the UI.
        [Updates code with FPS display]

You: "Explain quaternions"

Claude: Quaternions are 4-number representations of 3D rotations...
        [Provides educational explanation]
```

### Commands the Skill Understands

- **Create**: "Create a [type] visualization"
- **Add**: "Add [feature] to the visualization"
- **Customize**: "Change color to blue", "Make it faster"
- **Debug**: "Why isn't my quaternion normalized?"
- **Explain**: "Explain gimbal lock", "What are 4D rotations?"
- **Optimize**: "Make this faster", "Optimize for mobile"

### Keywords
- **tesseract, hypercube** → 4D cube
- **sphere** → 4D sphere
- **mouse, touch, keyboard** → Input methods
- **quaternion, euler** → Data displays
- **fps** → Performance counter
- **gradient** → Color effects

---

## 2. MCP Server

### Location
`.claude/mcp/vib34d-server.json` - Configuration
`.claude/mcp/vib34d-mcp-server.js` - Server implementation

### What It Does
Provides AI-powered tools through Model Context Protocol:
- `vib34d_create_project` - Generate new projects
- `vib34d_generate_code` - Generate from descriptions
- `vib34d_explain_concept` - Explain quaternions/4D math
- `vib34d_debug_quaternion` - Debug quaternion issues
- `vib34d_optimize` - Performance optimization suggestions
- `vib34d_convert_code` - Convert Dart ↔ JavaScript

### Setup

#### Option 1: Claude Desktop App

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "vib34d": {
      "command": "node",
      "args": ["/path/to/vib34d-vib3plus/.claude/mcp/vib34d-mcp-server.js"]
    }
  }
}
```

#### Option 2: Claude Code

```bash
# In your project directory
export MCP_SERVER_VIB34D="/path/to/vib34d-vib3plus/.claude/mcp/vib34d-mcp-server.js"
```

### Usage Examples

**Create Project**:
```
Claude, use vib34d_create_project:
  name: "my-viz"
  template: "web-mouse"
  geometry: "tesseract"
  color: "purple"
```

**Generate Code**:
```
Claude, use vib34d_generate_code:
  description: "Touch-controlled sphere with color gradients"
  platform: "flutter-mobile"
  features: ["fps-counter", "reset-button"]
```

**Explain Concept**:
```
Claude, use vib34d_explain_concept:
  concept: "quaternion"
  level: "beginner"
```

**Debug Quaternion**:
```
Claude, use vib34d_debug_quaternion:
  quaternion: {x: 0.5, y: 0.5, z: 0.5, w: 0.5}
  issue: "Rotation seems wrong"
```

---

## 3. Agentic CLI

### Location
`cli/vib34d-agent/`

### What It Does
Interactive AI-powered command-line tool for:
- Smart onboarding for new users
- Project generation based on your needs
- Code generation from descriptions
- Interactive tutorials
- Concept explanations
- Performance optimization

### Installation

```bash
cd cli/vib34d-agent
npm install
npm link  # Makes 'vib34d' command available globally
```

### Usage

#### First Run (Onboarding)
```bash
vib34d
```

The CLI will:
1. Ask about your experience level
2. Ask what you want to build
3. Ask about platform (web/mobile/desktop)
4. Ask about input methods
5. Give personalized recommendations
6. Optionally create your first project

#### Create Project
```bash
# Interactive mode
vib34d create

# Quick mode
vib34d create my-app
```

#### Tutorial
```bash
vib34d tutorial
```

#### Explain Concepts
```bash
vib34d explain quaternion
vib34d explain euler
vib34d explain 4d
```

#### Documentation
```bash
vib34d docs
```

### What It Looks Like

```
██╗   ██╗██╗██████╗ ██████╗ ██╗  ██╗██████╗
██║   ██║██║██╔══██╗╚════██╗██║  ██║██╔══██╗
██║   ██║██║██████╔╝ █████╔╝███████║██║  ██║
╚██╗ ██╔╝██║██╔══██╗ ╚═══██╗╚════██║██║  ██║
 ╚████╔╝ ██║██████╔╝██████╔╝     ██║██████╔╝
  ╚═══╝  ╚═╝╚═════╝ ╚═════╝      ╚═╝╚═════╝

  4D Visualization SDK - AI-Powered CLI

┌─────────────────────────────────────────────┐
│                                             │
│  Welcome to VIB34D! 👋                      │
│                                             │
│  I'm your AI assistant for creating         │
│  amazing 4D visualizations.                 │
│  Let's get you set up in just a few steps! │
│                                             │
└─────────────────────────────────────────────┘

? How familiar are you with 3D/4D graphics?
  🌱 Beginner - Never worked with 3D before
❯ 🌿 Intermediate - Some 3D experience
  🌳 Advanced - Experienced with graphics/quaternions

? What would you like to build?
  🎨 Interactive art / Creative visualization
❯ 📊 Data visualization
  🎓 Educational tool
  ...
```

### Features

**Smart Onboarding**:
- Adapts to your experience level
- Recommends templates based on use case
- Suggests appropriate geometries
- Provides personalized learning resources

**Interactive Project Creation**:
- Step-by-step guidance
- Validates inputs
- Shows next steps
- Provides running commands

**Educational**:
- Concept explanations at different levels
- Links to relevant documentation
- Example code snippets

---

## 4. VS Code Extension (Future)

### Planned Features

**Code Generation**:
- Right-click → "Generate VIB34D Visualization"
- Template snippets
- Component scaffolding

**Live Preview**:
- See visualization in side panel
- Updates as you code
- Adjustable camera angle

**IntelliSense**:
- Autocomplete for VIB34D classes
- Parameter hints
- Type information

**Debugging**:
- Quaternion inspector
- 4D rotation visualizer
- Performance profiler

**Quick Actions**:
- "Add input adapter"
- "Change geometry"
- "Optimize performance"

---

## Example Workflows

### Workflow 1: Complete Beginner

```bash
# Step 1: Run CLI
vib34d

# CLI asks questions, gives recommendations
# Creates first project

# Step 2: Open in editor with Claude Code
cd my-vib34d-app

# Step 3: Ask Claude for help
"Claude, explain how quaternions work"
"Claude, add a reset button"
"Claude, change the color to blue"
```

### Workflow 2: Experienced Developer

```bash
# Quick create project
vib34d create data-viz --template=educational

# Open in Claude Code
cd data-viz

# Use MCP tools directly
"Claude, use vib34d_generate_code to create a CSV data importer"

# Optimize
"Claude, use vib34d_optimize to improve performance for 60 FPS"
```

### Workflow 3: Learning Quaternions

```bash
# Start tutorial
vib34d tutorial

# Get explanations
vib34d explain quaternion
vib34d explain euler
vib34d explain gimbal-lock

# Create educational project
vib34d create --template=educational

# Ask Claude to enhance
"Claude, add real-time quaternion → Euler conversion display"
```

---

## Customization

### Adding Custom Templates

Edit `vib34d-mcp-server.js` to add your own templates:

```javascript
templates: {
  'my-custom-template': this.getMyCustomTemplate(name, geometry, color),
}

getMyCustomTemplate(name, geometry, color) {
  return `// Your template code here`;
}
```

### Adding Custom Commands

Edit `cli/vib34d-agent/bin/vib34d.js`:

```javascript
program
  .command('my-command')
  .description('My custom command')
  .action(async () => {
    // Your command logic
  });
```

---

## Troubleshooting

### MCP Server Not Working

**Check installation**:
```bash
cd .claude/mcp
npm install @modelcontextprotocol/sdk
```

**Test server**:
```bash
node vib34d-mcp-server.js
```

### CLI Not Found

**Link globally**:
```bash
cd cli/vib34d-agent
npm link
```

**Check PATH**:
```bash
which vib34d
```

### Claude Skill Not Activating

**Location**: Ensure `.claude/skills/vib34d-visualizer.md` exists in your project

**Activation**: The skill activates when you mention keywords like "vib34d", "tesseract", "quaternion"

---

## Best Practices

### With Claude Code Skill

1. **Be specific** about platform and input method
2. **Mention geometry type** you want (tesseract/sphere/grid)
3. **Ask for explanations** when learning new concepts
4. **Request optimizations** for your target platform

### With MCP Server

1. **Use typed tools** for complex operations
2. **Debug quaternions** before asking for full solutions
3. **Optimize incrementally** - don't try to optimize everything at once

### With Agentic CLI

1. **Complete onboarding** for personalized recommendations
2. **Use templates** as starting points
3. **Ask for explanations** when stuck
4. **Check docs** command for relevant guides

---

## Next Steps

1. **Try the onboarding**: `vib34d`
2. **Create a project**: `vib34d create`
3. **Ask Claude for help**: Use the skill in Claude Code
4. **Read the guides**: `vib34d docs`

---

## Resources

- **Claude Code Docs**: https://docs.claude.com/
- **MCP Protocol**: https://modelcontextprotocol.io/
- **VIB34D Guides**: WEB_APP_GUIDE.md, FLUTTER_WEB_GUIDE.md
- **Examples**: examples/web_examples/

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**

🤖 **Now with full AI integration!** 🤖
