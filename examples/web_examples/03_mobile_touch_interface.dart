/// Example 3: Mobile-First Touch Interface
///
/// This example demonstrates:
/// - Touch gestures (swipe, pinch, rotate)
/// - Momentum/inertia after release
/// - Mobile-optimized UI
/// - Performance-conscious rendering
///
/// Usage: Swipe to rotate, pinch to zoom (simulated), two-finger rotate

import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

void main() => runApp(MobileTouchApp());

class MobileTouchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Touch Interface',
      theme: ThemeData.dark(),
      home: MobileTouchDemo(),
    );
  }
}

class MobileTouchDemo extends StatefulWidget {
  @override
  _MobileTouchDemoState createState() => _MobileTouchDemoState();
}

class _MobileTouchDemoState extends State<MobileTouchDemo> {
  late SensoryInputBridge bridge;
  late QuaternionFieldService quaternionService;
  late ShaderQuaternionSynchronizer synchronizer;
  late TouchInputAdapter touchAdapter;

  Map<String, double> rot4d = {};
  int selectedGeometry = 0;
  bool showHelp = true;

  final List<String> geometries = [
    'Tesseract',
    'Sphere',
    'Grid',
  ];

  @override
  void initState() {
    super.initState();

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

    // Touch adapter with momentum enabled
    touchAdapter = TouchInputAdapter(
      bridge: bridge,
      config: TouchInputConfig(
        sensitivity: 0.008,
        invertY: true,
        smoothing: 0.2,
        enableMomentum: true,
        momentumDecay: 0.96,
      ),
    );

    synchronizer.start();
    touchAdapter.start();

    // Auto-hide help after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() => showHelp = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main visualization area
            GestureDetector(
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.deepPurple[900]!,
                      Colors.black,
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: MobileVisualizationPainter(
                    rot4d: rot4d,
                    geometryType: selectedGeometry,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      geometries[selectedGeometry],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(showHelp ? Icons.help : Icons.help_outline),
                      onPressed: () => setState(() => showHelp = !showHelp),
                    ),
                  ],
                ),
              ),
            ),

            // Help overlay
            if (showHelp)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Card(
                      margin: EdgeInsets.all(32),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '👆 Touch Controls',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildHelpItem('Swipe', 'Rotate the geometry'),
                            _buildHelpItem('Two fingers', 'Rotate around Z-axis'),
                            _buildHelpItem('Release', 'Momentum continues'),
                            SizedBox(height: 16),
                            Text(
                              '🎨 Bottom buttons change geometry',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: () => setState(() => showHelp = false),
                                child: Text('Got it!'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom geometry selector
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(geometries.length, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedGeometry = index),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selectedGeometry == index
                              ? Colors.purple
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          geometries[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: selectedGeometry == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => touchAdapter.reset(),
        child: Icon(Icons.refresh, size: 20),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildHelpItem(String gesture, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 100,
            child: Text(
              gesture,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
          ),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}

class MobileVisualizationPainter extends CustomPainter {
  final Map<String, double> rot4d;
  final int geometryType;
  final CanvasRenderer renderer = CanvasRenderer();

  MobileVisualizationPainter({
    required this.rot4d,
    required this.geometryType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Already has gradient background from container

    if (rot4d.isEmpty) return;

    switch (geometryType) {
      case 0: // Tesseract
        renderer.renderTesseract(
          canvas: canvas,
          size: size,
          rotations: rot4d,
          scale: size.width * 0.25,
          color: Colors.cyanAccent,
          strokeWidth: 2.0,
        );
        break;

      case 1: // Sphere
        renderer.renderSphere(
          canvas: canvas,
          size: size,
          rotations: rot4d,
          radius: size.width * 0.35,
          segments: 25, // Reduced for mobile performance
          rings: 12,
          baseHue: 280.0,
        );
        break;

      case 2: // Grid
        renderer.renderGrid(
          canvas: canvas,
          size: size,
          rotations: rot4d,
          gridSize: 12,
          spacing: 15.0,
          color: Colors.purpleAccent.withOpacity(0.5),
          strokeWidth: 1.5,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
