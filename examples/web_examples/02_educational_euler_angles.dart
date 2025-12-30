/// Example 2: Educational Euler Angles Visualizer
///
/// This example demonstrates:
/// - Displaying quaternion → Euler conversion
/// - Real-time angle displays
/// - Multiple input methods
/// - Educational data visualization
///
/// Usage: Use mouse, keyboard, or touch to rotate and see angle changes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
import 'dart:math' as math;

void main() => runApp(EulerAnglesApp());

class EulerAnglesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Euler Angles Visualizer',
      theme: ThemeData.dark(),
      home: EulerAnglesDemo(),
    );
  }
}

class EulerAnglesDemo extends StatefulWidget {
  @override
  _EulerAnglesDemoState createState() => _EulerAnglesDemoState();
}

class _EulerAnglesDemoState extends State<EulerAnglesDemo> {
  late SensoryInputBridge bridge;
  late QuaternionFieldService quaternionService;
  late ShaderQuaternionSynchronizer synchronizer;
  late MouseInputAdapter mouseAdapter;
  late KeyboardInputAdapter keyboardAdapter;

  Map<String, double> rot4d = {};
  Quaternion currentQuaternion = Quaternion.identity();
  EulerAngles currentEuler = EulerAngles(roll: 0, pitch: 0, yaw: 0);

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    bridge = SensoryInputBridge();
    quaternionService = QuaternionFieldService();

    // Subscribe to quaternion updates
    quaternionService.state.listen((state) {
      setState(() {
        currentQuaternion = state.primary;
        currentEuler = QuaternionUtils.toEuler(state.primary);
      });
    });

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

    mouseAdapter = MouseInputAdapter(bridge: bridge);
    keyboardAdapter = KeyboardInputAdapter(bridge: bridge);

    synchronizer.start();
    mouseAdapter.start();
    keyboardAdapter.start();

    // Auto-focus for keyboard
    Future.delayed(Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _radToDeg(double rad) {
    return (rad * 180 / math.pi).toStringAsFixed(1) + '°';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Euler Angles Educational Visualizer')),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            keyboardAdapter.handleKeyDown(event.character ?? '');
          } else if (event is RawKeyUpEvent) {
            keyboardAdapter.handleKeyUp(event.character ?? '');
          }
        },
        child: Row(
          children: [
            // Left panel: Data displays
            Container(
              width: 300,
              color: Colors.grey[900],
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Rotation Data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Quaternion display
                    _buildSection('Quaternion (x, y, z, w)', [
                      'x: ${currentQuaternion.x.toStringAsFixed(3)}',
                      'y: ${currentQuaternion.y.toStringAsFixed(3)}',
                      'z: ${currentQuaternion.z.toStringAsFixed(3)}',
                      'w: ${currentQuaternion.w.toStringAsFixed(3)}',
                    ]),

                    Divider(height: 30),

                    // Euler angles display
                    _buildSection('Euler Angles', [
                      'Roll:  ${_radToDeg(currentEuler.roll)}',
                      'Pitch: ${_radToDeg(currentEuler.pitch)}',
                      'Yaw:   ${_radToDeg(currentEuler.yaw)}',
                    ]),

                    Divider(height: 30),

                    // 4D Rotations
                    _buildSection('4D Rotation Parameters', [
                      'XY: ${rot4d['rot4dXY']?.toStringAsFixed(3) ?? '0.000'}',
                      'XZ: ${rot4d['rot4dXZ']?.toStringAsFixed(3) ?? '0.000'}',
                      'YZ: ${rot4d['rot4dYZ']?.toStringAsFixed(3) ?? '0.000'}',
                      'XW: ${rot4d['rot4dXW']?.toStringAsFixed(3) ?? '0.000'}',
                      'YW: ${rot4d['rot4dYW']?.toStringAsFixed(3) ?? '0.000'}',
                      'ZW: ${rot4d['rot4dZW']?.toStringAsFixed(3) ?? '0.000'}',
                    ]),

                    Divider(height: 30),

                    // Controls help
                    _buildSection('🎮 Controls', [
                      'Mouse: Click & drag',
                      'W/S: Pitch up/down',
                      'A/D: Yaw left/right',
                      'Q/E: Roll left/right',
                      'R: Reset',
                      'Shift: Speed boost',
                    ]),
                  ],
                ),
              ),
            ),

            // Right panel: Visualization
            Expanded(
              child: MouseRegion(
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
                    painter: EducationalPainter(
                      rot4d: rot4d,
                      euler: currentEuler,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mouseAdapter.reset();
          keyboardAdapter.reset();
        },
        child: Icon(Icons.refresh),
        tooltip: 'Reset (R key)',
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
          ),
        ),
        SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              item,
              style: TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class EducationalPainter extends CustomPainter {
  final Map<String, double> rot4d;
  final EulerAngles euler;
  final CanvasRenderer renderer = CanvasRenderer();

  EducationalPainter({required this.rot4d, required this.euler});

  @override
  void paint(Canvas canvas, Size size) {
    // Gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.indigo[900]!, Colors.purple[900]!],
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );

    if (rot4d.isNotEmpty) {
      // Render grid
      renderer.renderGrid(
        canvas: canvas,
        size: size,
        rotations: rot4d,
        gridSize: 10,
        spacing: 20.0,
        color: Colors.white.withOpacity(0.15),
      );

      // Render sphere
      renderer.renderSphere(
        canvas: canvas,
        size: size,
        rotations: rot4d,
        radius: size.width * 0.3,
        segments: 30,
        rings: 15,
        baseHue: 200.0,
      );

      // Draw axis labels
      _drawAxisLabels(canvas, size);
    }
  }

  void _drawAxisLabels(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw coordinate system
    final axisPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // X axis (red)
    axisPaint.color = Colors.red;
    canvas.drawLine(center, center + Offset(100, 0), axisPaint);
    _drawText(canvas, 'X', center + Offset(110, 0), Colors.red);

    // Y axis (green)
    axisPaint.color = Colors.green;
    canvas.drawLine(center, center + Offset(0, -100), axisPaint);
    _drawText(canvas, 'Y', center + Offset(0, -110), Colors.green);

    // Z axis (blue) - perspective
    axisPaint.color = Colors.blue;
    canvas.drawLine(center, center + Offset(70, 70), axisPaint);
    _drawText(canvas, 'Z', center + Offset(80, 80), Colors.blue);
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
