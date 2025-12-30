/// Example 1: Simple Mouse-Controlled Rotation
///
/// This example demonstrates:
/// - Basic mouse input setup
/// - Simple tesseract rendering
/// - Reset functionality
/// - Real-time FPS display
///
/// Usage: Drag mouse to rotate, click reset button to reset rotation

import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

void main() => runApp(SimpleMouseRotationApp());

class SimpleMouseRotationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Mouse Rotation',
      theme: ThemeData.dark(),
      home: SimpleMouseRotation(),
    );
  }
}

class SimpleMouseRotation extends StatefulWidget {
  @override
  _SimpleMouseRotationState createState() => _SimpleMouseRotationState();
}

class _SimpleMouseRotationState extends State<SimpleMouseRotation> {
  late SensoryInputBridge bridge;
  late QuaternionFieldService quaternionService;
  late ShaderQuaternionSynchronizer synchronizer;
  late MouseInputAdapter mouseAdapter;

  Map<String, double> rot4d = {};
  double fps = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize SDK components
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

    // Initialize mouse input with drag-to-rotate
    mouseAdapter = MouseInputAdapter(
      bridge: bridge,
      config: MouseInputConfig(
        sensitivity: 0.005,
        requireMouseDown: true,
        smoothing: 0.15,
      ),
    );

    // Start the system
    synchronizer.start();
    mouseAdapter.start();

    // Track FPS
    _trackFPS();
  }

  void _trackFPS() {
    int frameCount = 0;
    DateTime lastTime = DateTime.now();

    void updateFPS() {
      frameCount++;
      final now = DateTime.now();
      final elapsed = now.difference(lastTime).inMilliseconds;

      if (elapsed >= 1000) {
        setState(() {
          fps = (frameCount / elapsed) * 1000.0;
        });
        frameCount = 0;
        lastTime = now;
      }

      Future.delayed(Duration(milliseconds: 16), updateFPS);
    }

    updateFPS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Mouse Rotation Demo'),
        actions: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'FPS: ${fps.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mouse interaction layer
          MouseRegion(
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
              child: Container(
                color: Colors.black,
                child: CustomPaint(
                  painter: TesseractPainter(rot4d: rot4d),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // Instructions overlay
          Positioned(
            top: 20,
            left: 20,
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🖱️ Instructions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Click and drag to rotate'),
                    Text('• Release to stop'),
                    Text('• Click reset to center'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mouseAdapter.reset(),
        icon: Icon(Icons.refresh),
        label: Text('Reset'),
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
    // Black background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    // Render tesseract if we have rotations
    if (rot4d.isNotEmpty) {
      renderer.renderTesseract(
        canvas: canvas,
        size: size,
        rotations: rot4d,
        scale: 120.0,
        color: Colors.purpleAccent,
        strokeWidth: 2.5,
      );

      // Add grid for depth perception
      renderer.renderGrid(
        canvas: canvas,
        size: size,
        rotations: rot4d,
        gridSize: 8,
        spacing: 25.0,
        color: Colors.white.withOpacity(0.1),
        strokeWidth: 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
