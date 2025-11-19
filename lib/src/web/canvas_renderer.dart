/// Canvas rendering utilities for Flutter Web custom painters.
///
/// Provides high-level rendering functions for 4D geometry visualization
/// using Flutter's Canvas API.
///
/// **Usage Example**:
/// ```dart
/// class MyCustomPainter extends CustomPainter {
///   final CanvasRenderer renderer = CanvasRenderer();
///
///   @override
///   void paint(Canvas canvas, Size size) {
///     renderer.renderTesseract(
///       canvas: canvas,
///       size: size,
///       rotations: rot4d,
///     );
///   }
/// }
/// ```

import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'web_visualization_helper.dart';

/// Canvas renderer for 4D geometries
class CanvasRenderer {
  final WebVisualizationHelper? _helper;

  CanvasRenderer({WebVisualizationHelper? helper}) : _helper = helper;

  /// Render a tesseract (4D hypercube)
  void renderTesseract({
    required ui.Canvas canvas,
    required ui.Size size,
    required Map<String, double> rotations,
    double scale = 100.0,
    Color color = Colors.purple,
    double strokeWidth = 2.0,
  }) {
    final helper = _helper ?? WebVisualizationHelper(
      canvasWidth: size.width,
      canvasHeight: size.height,
    );

    // Generate tesseract vertices
    final vertices4D = helper.generateTesseractVertices();

    // Rotate in 4D
    final rotatedVertices = vertices4D
        .map((v) => v.rotate4D(rotations))
        .toList();

    // Project to 2D
    final points2D = rotatedVertices
        .map((v) => helper.project3DTo2D(v.projectTo3D(), scale: scale))
        .toList();

    // Draw edges (tesseract has 32 edges)
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Define tesseract edges
    final edges = _getTesseractEdges();

    for (final edge in edges) {
      final p1 = points2D[edge[0]];
      final p2 = points2D[edge[1]];
      canvas.drawLine(
        Offset(p1.x, p1.y),
        Offset(p2.x, p2.y),
        paint,
      );
    }

    // Draw vertices
    final vertexPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points2D) {
      canvas.drawCircle(
        Offset(point.x, point.y),
        3.0,
        vertexPaint,
      );
    }
  }

  /// Render a rotating sphere with 4D depth coloring
  void renderSphere({
    required ui.Canvas canvas,
    required ui.Size size,
    required Map<String, double> rotations,
    double radius = 100.0,
    int segments = 30,
    int rings = 15,
    double baseHue = 200.0,
  }) {
    final helper = _helper ?? WebVisualizationHelper(
      canvasWidth: size.width,
      canvasHeight: size.height,
    );

    // Generate sphere vertices
    final vertices4D = helper.generateSphereVertices(
      radius: 1.0,
      segments: segments,
      rings: rings,
    );

    // Rotate in 4D
    final rotatedVertices = vertices4D
        .map((v) => v.rotate4D(rotations))
        .toList();

    // Project and draw
    for (int ring = 0; ring < rings; ring++) {
      for (int segment = 0; segment < segments; segment++) {
        final i1 = ring * (segments + 1) + segment;
        final i2 = i1 + 1;
        final i3 = i1 + (segments + 1);
        final i4 = i3 + 1;

        if (i4 >= rotatedVertices.length) continue;

        // Get 4D points
        final v1 = rotatedVertices[i1];
        final v2 = rotatedVertices[i2];
        final v3 = rotatedVertices[i3];
        final v4 = rotatedVertices[i4];

        // Project to 2D
        final p1 = helper.project3DTo2D(v1.projectTo3D(), scale: radius);
        final p2 = helper.project3DTo2D(v2.projectTo3D(), scale: radius);
        final p3 = helper.project3DTo2D(v3.projectTo3D(), scale: radius);
        final p4 = helper.project3DTo2D(v4.projectTo3D(), scale: radius);

        // Calculate average W for coloring
        final avgW = (v1.w + v2.w + v3.w + v4.w) / 4;
        final colorHSL = helper.getColorFromW(avgW, baseHue: baseHue);

        // Draw quad as two triangles
        final path = Path()
          ..moveTo(p1.x, p1.y)
          ..lineTo(p2.x, p2.y)
          ..lineTo(p4.x, p4.y)
          ..lineTo(p3.x, p3.y)
          ..close();

        final paint = Paint()
          ..color = _hslToColor(colorHSL)
          ..style = PaintingStyle.fill;

        canvas.drawPath(path, paint);

        // Draw edge
        final edgePaint = Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;

        canvas.drawPath(path, edgePaint);
      }
    }
  }

  /// Render a wireframe grid
  void renderGrid({
    required ui.Canvas canvas,
    required ui.Size size,
    required Map<String, double> rotations,
    int gridSize = 10,
    double spacing = 20.0,
    Color color = Colors.white24,
    double strokeWidth = 1.0,
  }) {
    final helper = _helper ?? WebVisualizationHelper(
      canvasWidth: size.width,
      canvasHeight: size.height,
    );

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final halfGrid = gridSize / 2;

    // Draw grid lines in XY plane
    for (int i = -halfGrid; i <= halfGrid; i++) {
      // Horizontal lines
      final start4D = Point4D(i * spacing / 100, -halfGrid * spacing / 100, 0, 0);
      final end4D = Point4D(i * spacing / 100, halfGrid * spacing / 100, 0, 0);

      final startRotated = start4D.rotate4D(rotations);
      final endRotated = end4D.rotate4D(rotations);

      final start2D = helper.project3DTo2D(startRotated.projectTo3D(), scale: 100);
      final end2D = helper.project3DTo2D(endRotated.projectTo3D(), scale: 100);

      canvas.drawLine(
        Offset(start2D.x, start2D.y),
        Offset(end2D.x, end2D.y),
        paint,
      );

      // Vertical lines
      final vStart4D = Point4D(-halfGrid * spacing / 100, i * spacing / 100, 0, 0);
      final vEnd4D = Point4D(halfGrid * spacing / 100, i * spacing / 100, 0, 0);

      final vStartRotated = vStart4D.rotate4D(rotations);
      final vEndRotated = vEnd4D.rotate4D(rotations);

      final vStart2D = helper.project3DTo2D(vStartRotated.projectTo3D(), scale: 100);
      final vEnd2D = helper.project3DTo2D(vEndRotated.projectTo3D(), scale: 100);

      canvas.drawLine(
        Offset(vStart2D.x, vStart2D.y),
        Offset(vEnd2D.x, vEnd2D.y),
        paint,
      );
    }
  }

  /// Render custom 4D geometry from vertex list
  void renderCustomGeometry({
    required ui.Canvas canvas,
    required ui.Size size,
    required Map<String, double> rotations,
    required List<Point4D> vertices,
    required List<List<int>> edges,
    double scale = 100.0,
    Color color = Colors.blue,
    double strokeWidth = 2.0,
    bool showVertices = true,
  }) {
    final helper = _helper ?? WebVisualizationHelper(
      canvasWidth: size.width,
      canvasHeight: size.height,
    );

    // Rotate vertices
    final rotatedVertices = vertices
        .map((v) => v.rotate4D(rotations))
        .toList();

    // Project to 2D
    final points2D = rotatedVertices
        .map((v) => helper.project3DTo2D(v.projectTo3D(), scale: scale))
        .toList();

    // Draw edges
    final edgePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      if (edge[0] >= points2D.length || edge[1] >= points2D.length) continue;

      final p1 = points2D[edge[0]];
      final p2 = points2D[edge[1]];
      canvas.drawLine(
        Offset(p1.x, p1.y),
        Offset(p2.x, p2.y),
        edgePaint,
      );
    }

    // Draw vertices
    if (showVertices) {
      final vertexPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      for (final point in points2D) {
        canvas.drawCircle(
          Offset(point.x, point.y),
          3.0,
          vertexPaint,
        );
      }
    }
  }

  /// Draw text label on canvas
  void drawLabel({
    required ui.Canvas canvas,
    required String text,
    required Offset position,
    Color color = Colors.white,
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  // Helper: Get tesseract edge connections
  List<List<int>> _getTesseractEdges() {
    return [
      // Inner cube edges
      [0, 1], [1, 3], [3, 2], [2, 0], // Bottom face
      [4, 5], [5, 7], [7, 6], [6, 4], // Top face
      [0, 4], [1, 5], [2, 6], [3, 7], // Vertical edges

      // Outer cube edges
      [8, 9], [9, 11], [11, 10], [10, 8], // Bottom face
      [12, 13], [13, 15], [15, 14], [14, 12], // Top face
      [8, 12], [9, 13], [10, 14], [11, 15], // Vertical edges

      // Connections between inner and outer cubes
      [0, 8], [1, 9], [2, 10], [3, 11],
      [4, 12], [5, 13], [6, 14], [7, 15],
    ];
  }

  // Helper: Convert HSL to Flutter Color
  Color _hslToColor(ColorHSL hsl) {
    final h = hsl.hue / 360;
    final s = hsl.saturation / 100;
    final l = hsl.lightness / 100;

    double hue2rgb(double p, double q, double t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }

    double r, g, b;

    if (s == 0) {
      r = g = b = l;
    } else {
      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    return Color.fromRGBO(
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
      hsl.alpha,
    );
  }
}
