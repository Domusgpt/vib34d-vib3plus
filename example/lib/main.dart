import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const VIB34DExampleApp());
}

class VIB34DExampleApp extends StatelessWidget {
  const VIB34DExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIB34D XR Quaternion SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const QuaternionDemo(),
    );
  }
}

class QuaternionDemo extends StatefulWidget {
  const QuaternionDemo({super.key});

  @override
  State<QuaternionDemo> createState() => _QuaternionDemoState();
}

class _QuaternionDemoState extends State<QuaternionDemo> {
  late SensoryInputBridge _bridge;
  late QuaternionFieldService _quaternionService;
  late ShaderQuaternionSynchronizer _synchronizer;

  Map<String, double> _currentRotations = {};
  EulerAngles _currentEuler = const EulerAngles(roll: 0, pitch: 0, yaw: 0);
  double _motionEnergy = 0.0;
  int _geometryIndex = 0;
  String _geometryName = '';

  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();

    // Initialize SDK components
    _bridge = SensoryInputBridge(channelHistoryLimit: 12);

    _quaternionService = QuaternionFieldService(
      energySmoothing: 0.35,
      velocityReference: 8.0,
    );

    _synchronizer = ShaderQuaternionSynchronizer(
      bridge: _bridge,
      quaternionService: _quaternionService,
      rotationScale: 2.0,
      onSystemUpdate: _handleSystemUpdate,
    );

    // Start synchronizer
    _synchronizer.start();

    // Subscribe to quaternion updates
    _quaternionService.stream.listen(_handleQuaternionSnapshot);

    // Update geometry name
    _updateGeometry();

    // Start simulation (simulates AR tracking data)
    _startSimulation();
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      // Simulate AR tracking with rotating quaternion
      final time = timer.tick * 0.016; // seconds
      final roll = math.sin(time * 0.5) * 0.3;
      final pitch = math.cos(time * 0.7) * 0.4;
      final yaw = math.sin(time * 0.3) * 0.5;

      // Convert Euler to quaternion
      final qx = math.sin(roll / 2) * math.cos(pitch / 2) * math.cos(yaw / 2) -
          math.cos(roll / 2) * math.sin(pitch / 2) * math.sin(yaw / 2);
      final qy = math.cos(roll / 2) * math.sin(pitch / 2) * math.cos(yaw / 2) +
          math.sin(roll / 2) * math.cos(pitch / 2) * math.sin(yaw / 2);
      final qz = math.cos(roll / 2) * math.cos(pitch / 2) * math.sin(yaw / 2) -
          math.sin(roll / 2) * math.sin(pitch / 2) * math.cos(yaw / 2);
      final qw = math.cos(roll / 2) * math.cos(pitch / 2) * math.cos(yaw / 2) +
          math.sin(roll / 2) * math.sin(pitch / 2) * math.sin(yaw / 2);

      final quaternion = Quaternion(qx, qy, qz, qw);

      // Publish simulated AR pose
      _bridge.publishPose(
        orientation: quaternion,
        position: Vector3(0, 1.5, -2),
        confidence: 0.85 + math.sin(time) * 0.1,
        source: 'simulated-ar',
      );
    });
  }

  void _handleSystemUpdate(String system, Map<String, double> parameters) {
    setState(() {
      _currentRotations = parameters;
    });
  }

  void _handleQuaternionSnapshot(QuaternionSnapshot snapshot) {
    setState(() {
      _currentEuler = snapshot.euler;
      _motionEnergy = snapshot.motionEnergy;
    });
  }

  void _updateGeometry() {
    final metadata = GeometryLibrary.describeGeometry(_geometryIndex);
    setState(() {
      _geometryName = metadata?.name ?? 'UNKNOWN';
    });
  }

  void _nextGeometry() {
    setState(() {
      _geometryIndex = (_geometryIndex + 1) % 24;
      _updateGeometry();
    });
  }

  void _previousGeometry() {
    setState(() {
      _geometryIndex = (_geometryIndex - 1 + 24) % 24;
      _updateGeometry();
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _synchronizer.dispose();
    _quaternionService.dispose();
    _bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('VIB34D XR Quaternion SDK'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Geometry selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Geometry Selection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _previousGeometry,
                        ),
                        Expanded(
                          child: Text(
                            _geometryName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _nextGeometry,
                        ),
                      ],
                    ),
                    Text(
                      'Geometry ${_geometryIndex + 1} of 24',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Euler angles display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Euler Angles (radians)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildParameterRow('Roll', _currentEuler.roll),
                    _buildParameterRow('Pitch', _currentEuler.pitch),
                    _buildParameterRow('Yaw', _currentEuler.yaw),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4D rotation parameters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4D Rotation Parameters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildParameterRow('XY Plane', _currentRotations['rot4dXY']),
                    _buildParameterRow('XZ Plane', _currentRotations['rot4dXZ']),
                    _buildParameterRow('YZ Plane', _currentRotations['rot4dYZ']),
                    _buildParameterRow('XW Plane', _currentRotations['rot4dXW']),
                    _buildParameterRow('YW Plane', _currentRotations['rot4dYW']),
                    _buildParameterRow('ZW Plane', _currentRotations['rot4dZW']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Motion energy
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Motion Energy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _motionEnergy,
                      minHeight: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_motionEnergy * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterRow(String label, double? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value?.toStringAsFixed(3) ?? '0.000',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
