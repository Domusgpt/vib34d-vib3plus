#!/usr/bin/env node

/**
 * VIB34D MCP (Model Context Protocol) Server
 *
 * Provides AI-powered tools for generating VIB34D visualizations
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require('@modelcontextprotocol/sdk/types.js');
const fs = require('fs').promises;
const path = require('path');

class VIB34DMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'vib34d-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupHandlers();
  }

  setupHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'vib34d_create_project',
          description: 'Create a new VIB34D visualization project',
          inputSchema: {
            type: 'object',
            properties: {
              name: { type: 'string', description: 'Project name' },
              template: {
                type: 'string',
                enum: ['web-mouse', 'web-touch', 'mobile-touch', 'desktop-keyboard', 'educational', 'gallery'],
                description: 'Project template'
              },
              geometry: {
                type: 'string',
                enum: ['tesseract', 'sphere', 'grid', 'custom'],
                description: 'Initial geometry'
              },
              color: { type: 'string', description: 'Primary color' }
            },
            required: ['name', 'template']
          }
        },
        {
          name: 'vib34d_generate_code',
          description: 'Generate VIB34D visualization code from description',
          inputSchema: {
            type: 'object',
            properties: {
              description: { type: 'string', description: 'What to build' },
              platform: {
                type: 'string',
                enum: ['flutter-web', 'flutter-mobile', 'flutter-desktop', 'react', 'vue'],
                description: 'Target platform'
              },
              features: {
                type: 'array',
                items: { type: 'string' },
                description: 'Additional features'
              }
            },
            required: ['description', 'platform']
          }
        },
        {
          name: 'vib34d_explain_concept',
          description: 'Explain quaternion/4D rotation concepts',
          inputSchema: {
            type: 'object',
            properties: {
              concept: {
                type: 'string',
                enum: ['quaternion', 'euler-angles', '4d-rotation', 'gimbal-lock', 'slerp'],
                description: 'Concept to explain'
              },
              level: {
                type: 'string',
                enum: ['beginner', 'intermediate', 'advanced'],
                description: 'Explanation depth'
              }
            },
            required: ['concept']
          }
        },
        {
          name: 'vib34d_debug_quaternion',
          description: 'Debug quaternion-related issues',
          inputSchema: {
            type: 'object',
            properties: {
              quaternion: {
                type: 'object',
                properties: {
                  x: { type: 'number' },
                  y: { type: 'number' },
                  z: { type: 'number' },
                  w: { type: 'number' }
                }
              },
              issue: { type: 'string' }
            },
            required: ['quaternion']
          }
        },
        {
          name: 'vib34d_optimize',
          description: 'Suggest performance optimizations',
          inputSchema: {
            type: 'object',
            properties: {
              code: { type: 'string', description: 'Code to optimize' },
              target_fps: { type: 'number', description: 'Target FPS' },
              platform: {
                type: 'string',
                enum: ['web', 'mobile', 'desktop']
              }
            },
            required: ['code']
          }
        }
      ]
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case 'vib34d_create_project':
          return await this.createProject(args);

        case 'vib34d_generate_code':
          return await this.generateCode(args);

        case 'vib34d_explain_concept':
          return await this.explainConcept(args);

        case 'vib34d_debug_quaternion':
          return await this.debugQuaternion(args);

        case 'vib34d_optimize':
          return await this.optimizeCode(args);

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });
  }

  async createProject(args) {
    const { name, template, geometry = 'tesseract', color = 'purple' } = args;

    const templates = {
      'web-mouse': this.getWebMouseTemplate(name, geometry, color),
      'web-touch': this.getWebTouchTemplate(name, geometry, color),
      'mobile-touch': this.getMobileTouchTemplate(name, geometry, color),
      'desktop-keyboard': this.getDesktopKeyboardTemplate(name, geometry, color),
      'educational': this.getEducationalTemplate(name, geometry, color),
      'gallery': this.getGalleryTemplate(name, geometry, color)
    };

    const code = templates[template];

    return {
      content: [
        {
          type: 'text',
          text: `Created ${name} with ${template} template:\n\n${code}\n\n` +
                `To use this:\n` +
                `1. Create a new Flutter project: flutter create ${name}\n` +
                `2. Add vib34d_xr_quaternion_sdk to pubspec.yaml\n` +
                `3. Replace lib/main.dart with the code above\n` +
                `4. Run: flutter run -d chrome`
        }
      ]
    };
  }

  async generateCode(args) {
    const { description, platform, features = [] } = args;

    // This would use AI to generate code, but for now return template
    const code = this.generateFromDescription(description, platform, features);

    return {
      content: [
        {
          type: 'text',
          text: `Generated code for "${description}" on ${platform}:\n\n${code}`
        }
      ]
    };
  }

  async explainConcept(args) {
    const { concept, level = 'intermediate' } = args;

    const explanations = {
      'quaternion': {
        'beginner': `A quaternion is a 4-number representation of 3D rotation. It has x, y, z, w components.\n\n` +
                   `Think of it like this:\n` +
                   `- x, y, z tell you the axis of rotation\n` +
                   `- w tells you how much to rotate\n\n` +
                   `Example: Quaternion(0, 0, 0, 1) = no rotation (identity)`,
        'intermediate': `Quaternions are complex numbers with 4 components (x, y, z, w) used for 3D rotations.\n\n` +
                       `Advantages over Euler angles:\n` +
                       `- No gimbal lock\n` +
                       `- Smooth interpolation (SLERP)\n` +
                       `- More efficient for computer graphics\n\n` +
                       `Formula: q = w + xi + yj + zk\n` +
                       `Where i²= j² = k² = ijk = -1`,
        'advanced': `Quaternions form a 4D non-commutative division algebra.\n\n` +
                   `Unit quaternions (||q|| = 1) represent rotations in SO(3).\n` +
                   `Composition: q₁q₂ rotates by q₂ then q₁ (right-to-left)\n` +
                   `Conjugate q* = (w, -x, -y, -z) represents inverse rotation\n\n` +
                   `Rotation of vector v: v' = qvq*\n` +
                   `Conversion to rotation matrix: M = I + 2ŵŵᵀ - 2w[ŵ]ₓ`
      },
      // Add more concepts...
    };

    const explanation = explanations[concept]?.[level] || `Explanation for ${concept} not found.`;

    return {
      content: [
        {
          type: 'text',
          text: explanation
        }
      ]
    };
  }

  async debugQuaternion(args) {
    const { quaternion, issue = '' } = args;
    const { x, y, z, w } = quaternion;

    // Calculate length
    const length = Math.sqrt(x*x + y*y + z*z + w*w);
    const isNormalized = Math.abs(length - 1.0) < 0.0001;

    // Convert to Euler
    const euler = this.quaternionToEuler(quaternion);

    let diagnosis = `Quaternion Analysis:\n\n`;
    diagnosis += `Input: (${x.toFixed(4)}, ${y.toFixed(4)}, ${z.toFixed(4)}, ${w.toFixed(4)})\n`;
    diagnosis += `Length: ${length.toFixed(6)}\n`;
    diagnosis += `Normalized: ${isNormalized ? '✅ YES' : '❌ NO'}\n\n`;

    if (!isNormalized) {
      const normalized = {
        x: x / length,
        y: y / length,
        z: z / length,
        w: w / length
      };
      diagnosis += `To normalize:\n`;
      diagnosis += `(${normalized.x.toFixed(4)}, ${normalized.y.toFixed(4)}, ${normalized.z.toFixed(4)}, ${normalized.w.toFixed(4)})\n\n`;
    }

    diagnosis += `Euler Angles:\n`;
    diagnosis += `Roll:  ${(euler.roll * 180 / Math.PI).toFixed(2)}°\n`;
    diagnosis += `Pitch: ${(euler.pitch * 180 / Math.PI).toFixed(2)}°\n`;
    diagnosis += `Yaw:   ${(euler.yaw * 180 / Math.PI).toFixed(2)}°\n`;

    if (issue) {
      diagnosis += `\nIssue: "${issue}"\n`;
      diagnosis += `Suggestions:\n`;
      if (!isNormalized) {
        diagnosis += `- Quaternion should be normalized for proper rotation\n`;
      }
      if (Math.abs(w) > 1.0) {
        diagnosis += `- W component > 1 indicates invalid quaternion\n`;
      }
    }

    return {
      content: [
        {
          type: 'text',
          text: diagnosis
        }
      ]
    };
  }

  async optimizeCode(args) {
    const { code, target_fps = 60, platform = 'web' } = args;

    let suggestions = `Performance Optimization Suggestions for ${platform}:\n\n`;

    // Analyze code and provide suggestions
    if (code.includes('segments: 50') || code.includes('rings: 30')) {
      suggestions += `1. Reduce geometry complexity:\n`;
      if (platform === 'mobile') {
        suggestions += `   - Change segments to 20 (from 50)\n`;
        suggestions += `   - Change rings to 10 (from 30)\n`;
      } else {
        suggestions += `   - Change segments to 30 (from 50)\n`;
        suggestions += `   - Change rings to 15 (from 30)\n`;
      }
      suggestions += `\n`;
    }

    if (code.includes('handleMouseMove') && !code.includes('smoothing')) {
      suggestions += `2. Add input smoothing:\n`;
      suggestions += `   MouseInputConfig(smoothing: 0.15)\n\n`;
    }

    if (!code.includes('shouldRepaint')) {
      suggestions += `3. Optimize CustomPainter:\n`;
      suggestions += `   Implement shouldRepaint() properly\n\n`;
    }

    suggestions += `General optimizations:\n`;
    suggestions += `- Use const constructors where possible\n`;
    suggestions += `- Cache geometry vertices\n`;
    suggestions += `- Throttle updates to ${target_fps} FPS\n`;
    suggestions += `- Enable CanvasKit renderer for web\n`;

    return {
      content: [
        {
          type: 'text',
          text: suggestions
        }
      ]
    };
  }

  // Helper methods
  quaternionToEuler(q) {
    const sinr = 2.0 * (q.w * q.x + q.y * q.z);
    const cosr = 1.0 - 2.0 * (q.x * q.x + q.y * q.y);
    const roll = Math.atan2(sinr, cosr);

    const sinp = 2.0 * (q.w * q.y - q.z * q.x);
    const pitch = Math.abs(sinp) >= 1
      ? Math.sign(sinp) * Math.PI / 2
      : Math.asin(sinp);

    const siny = 2.0 * (q.w * q.z + q.x * q.y);
    const cosy = 1.0 - 2.0 * (q.y * q.y + q.z * q.z);
    const yaw = Math.atan2(siny, cosy);

    return { roll, pitch, yaw };
  }

  getWebMouseTemplate(name, geometry, color) {
    return `import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

void main() => runApp(${toPascalCase(name)}App());

class ${toPascalCase(name)}App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${name}',
      theme: ThemeData.dark(),
      home: ${toPascalCase(name)}(),
    );
  }
}

class ${toPascalCase(name)} extends StatefulWidget {
  @override
  _${toPascalCase(name)}State createState() => _${toPascalCase(name)}State();
}

class _${toPascalCase(name)}State extends State<${toPascalCase(name)}> {
  late MouseInputAdapter mouseAdapter;
  late ShaderQuaternionSynchronizer synchronizer;
  Map<String, double> rot4d = {};

  @override
  void initState() {
    super.initState();
    final bridge = SensoryInputBridge();
    mouseAdapter = MouseInputAdapter(bridge: bridge);
    synchronizer = ShaderQuaternionSynchronizer(
      bridge: bridge,
      quaternionService: QuaternionFieldService(),
      onSystemUpdate: (system, params) {
        if (system == 'quaternion') setState(() => rot4d = params);
      },
    );
    mouseAdapter.start();
    synchronizer.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${name}')),
      body: MouseRegion(
        onHover: (e) => mouseAdapter.handleMouseMove(e.localPosition.dx, e.localPosition.dy),
        child: GestureDetector(
          onPanStart: (d) => mouseAdapter.handleMouseDown(d.localPosition.dx, d.localPosition.dy),
          onPanEnd: (_) => mouseAdapter.handleMouseUp(),
          child: Container(
            color: Colors.black,
            child: CustomPaint(
              painter: GeometryPainter(rot4d: rot4d, color: Colors.${color}),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class GeometryPainter extends CustomPainter {
  final Map<String, double> rot4d;
  final Color color;
  final CanvasRenderer renderer = CanvasRenderer();

  GeometryPainter({required this.rot4d, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (rot4d.isEmpty) return;
    renderer.render${toPascalCase(geometry)}(
      canvas: canvas,
      size: size,
      rotations: rot4d,
      scale: 120.0,
      color: color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}`;
  }

  generateFromDescription(description, platform, features) {
    // Simplified code generation
    return `// Generated from: "${description}"\n// Platform: ${platform}\n// Features: ${features.join(', ')}\n\n` +
           `// TODO: Implement based on description`;
  }

  getWebTouchTemplate(name, geometry, color) { return `// Web touch template for ${name}`; }
  getMobileTouchTemplate(name, geometry, color) { return `// Mobile touch template for ${name}`; }
  getDesktopKeyboardTemplate(name, geometry, color) { return `// Desktop keyboard template for ${name}`; }
  getEducationalTemplate(name, geometry, color) { return `// Educational template for ${name}`; }
  getGalleryTemplate(name, geometry, color) { return `// Gallery template for ${name}`; }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('VIB34D MCP server running on stdio');
  }
}

function toPascalCase(str) {
  return str.replace(/(^\w|-\w)/g, g => g.replace('-', '').toUpperCase());
}

// Run server
const server = new VIB34DMCPServer();
server.run().catch(console.error);
