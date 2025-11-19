# Flutter Web Implementation Guide

**Complete Guide for Building Web Apps with VIB34D SDK and Flutter Web**

---

## Table of Contents

1. [Overview](#overview)
2. [Setup](#setup)
3. [Project Structure](#project-structure)
4. [Building Your First App](#building-your-first-app)
5. [Optimization](#optimization)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

---

## Overview

Flutter Web allows you to compile your Flutter app to JavaScript and run it in any modern web browser. This guide shows you how to use the VIB34D SDK specifically for web deployment.

### Why Flutter Web?

- ✅ **Single codebase** for web, mobile, and desktop
- ✅ **Full SDK support** - All features available
- ✅ **Native Dart performance**
- ✅ **Hot reload** during development
- ✅ **Responsive** by default

### When to Use Flutter Web

| Use Case | Recommended? | Reason |
|----------|--------------|--------|
| **Interactive visualizations** | ✅ Yes | Excellent canvas performance |
| **Data dashboards** | ✅ Yes | Rich UI components |
| **Educational tools** | ✅ Yes | Cross-platform reach |
| **3D/4D explorers** | ✅ Yes | Full SDK support |
| **Content websites** | ⚠️ Maybe | Consider SEO implications |
| **E-commerce** | ⚠️ Maybe | Large bundle size |

---

## Setup

### 1. Install Flutter

```bash
# Download Flutter SDK
# https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor

# Enable web support
flutter config --enable-web
```

### 2. Create New Project

```bash
# Create Flutter project
flutter create my_vib34d_web_app

# Navigate to project
cd my_vib34d_web_app

# Verify web is available
flutter devices
# Should show "Chrome" and "Web Server"
```

### 3. Add VIB34D SDK

Edit `pubspec.yaml`:

```yaml
name: my_vib34d_web_app
description: VIB34D Web Application

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # VIB34D SDK
  vib34d_xr_quaternion_sdk:
    path: ../vib34d-vib3plus  # Adjust path
    # OR from git:
    # git:
    #   url: https://github.com/username/vib34d-vib3plus.git
    #   ref: main

  vector_math: ^2.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

Install dependencies:

```bash
flutter pub get
```

### 4. Test Web Build

```bash
# Run in Chrome
flutter run -d chrome

# Or run on web server
flutter run -d web-server
```

---

## Project Structure

Recommended structure for Flutter Web projects:

```
my_vib34d_web_app/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── screens/
│   │   ├── home_screen.dart      # Main app screen
│   │   └── about_screen.dart     # About/help
│   ├── widgets/
│   │   ├── tesseract_viewer.dart # Visualization widget
│   │   ├── controls_panel.dart   # UI controls
│   │   └── stats_display.dart    # Performance stats
│   ├── painters/
│   │   ├── tesseract_painter.dart
│   │   └── sphere_painter.dart
│   └── utils/
│       └── responsive.dart       # Responsive helpers
│
├── web/
│   ├── index.html                # HTML entry (customize here)
│   ├── manifest.json             # PWA manifest
│   └── favicon.png               # App icon
│
├── assets/
│   ├── images/
│   └── fonts/
│
└── pubspec.yaml
```

---

## Building Your First App

### Step 1: Create Main Entry Point

`lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyVib34dWebApp());
}

class MyVib34dWebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIB34D 4D Visualizer',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### Step 2: Create Home Screen

`lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../widgets/tesseract_viewer.dart';
import '../widgets/controls_panel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedGeometry = 0;
  double rotationSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text('VIB34D 4D Geometric Visualizer'),
        elevation: 0,
      ),
      body: isDesktop
          ? _buildDesktopLayout()
          : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left panel: Controls
        Container(
          width: 300,
          color: Colors.grey[900],
          child: ControlsPanel(
            selectedGeometry: selectedGeometry,
            rotationSpeed: rotationSpeed,
            onGeometryChanged: (index) {
              setState(() => selectedGeometry = index);
            },
            onSpeedChanged: (speed) {
              setState(() => rotationSpeed = speed);
            },
          ),
        ),

        // Right panel: Visualization
        Expanded(
          child: TesseractViewer(
            geometryType: selectedGeometry,
            rotationSpeed: rotationSpeed,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Top: Visualization
        Expanded(
          child: TesseractViewer(
            geometryType: selectedGeometry,
            rotationSpeed: rotationSpeed,
          ),
        ),

        // Bottom: Controls
        Container(
          color: Colors.grey[900],
          child: ControlsPanel(
            selectedGeometry: selectedGeometry,
            rotationSpeed: rotationSpeed,
            onGeometryChanged: (index) {
              setState(() => selectedGeometry = index);
            },
            onSpeedChanged: (speed) {
              setState(() => rotationSpeed = speed);
            },
          ),
        ),
      ],
    );
  }
}
```

### Step 3: Create Tesseract Viewer Widget

`lib/widgets/tesseract_viewer.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';
import '../painters/tesseract_painter.dart';

class TesseractViewer extends StatefulWidget {
  final int geometryType;
  final double rotationSpeed;

  const TesseractViewer({
    Key? key,
    this.geometryType = 0,
    this.rotationSpeed = 1.0,
  }) : super(key: key);

  @override
  _TesseractViewerState createState() => _TesseractViewerState();
}

class _TesseractViewerState extends State<TesseractViewer> {
  late SensoryInputBridge bridge;
  late QuaternionFieldService quaternionService;
  late ShaderQuaternionSynchronizer synchronizer;
  late MouseInputAdapter mouseAdapter;

  Map<String, double> rot4d = {};

  @override
  void initState() {
    super.initState();

    // Initialize SDK
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

    // Initialize mouse input
    mouseAdapter = MouseInputAdapter(
      bridge: bridge,
      config: MouseInputConfig(
        sensitivity: 0.005 * widget.rotationSpeed,
        requireMouseDown: true,
        smoothing: 0.15,
      ),
    );

    synchronizer.start();
    mouseAdapter.start();
  }

  @override
  void didUpdateWidget(TesseractViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update sensitivity when speed changes
    if (oldWidget.rotationSpeed != widget.rotationSpeed) {
      mouseAdapter = MouseInputAdapter(
        bridge: bridge,
        config: MouseInputConfig(
          sensitivity: 0.005 * widget.rotationSpeed,
        ),
      );
      mouseAdapter.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple[900]!,
                Colors.black,
              ],
            ),
          ),
          child: CustomPaint(
            painter: TesseractPainter(
              rot4d: rot4d,
              geometryType: widget.geometryType,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
```

### Step 4: Create Controls Panel

`lib/widgets/controls_panel.dart`:

```dart
import 'package:flutter/material.dart';

class ControlsPanel extends StatelessWidget {
  final int selectedGeometry;
  final double rotationSpeed;
  final Function(int) onGeometryChanged;
  final Function(double) onSpeedChanged;

  const ControlsPanel({
    Key? key,
    required this.selectedGeometry,
    required this.rotationSpeed,
    required this.onGeometryChanged,
    required this.onSpeedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎨 Geometry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          ..._buildGeometryButtons(),

          Divider(height: 30),

          Text(
            '⚡ Rotation Speed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Slider(
            value: rotationSpeed,
            min: 0.1,
            max: 3.0,
            divisions: 29,
            label: '${rotationSpeed.toStringAsFixed(1)}x',
            onChanged: onSpeedChanged,
          ),

          Divider(height: 30),

          Text(
            '🎮 Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          _buildControlItem('Click & Drag', 'Rotate'),
          _buildControlItem('Mouse Wheel', 'Z-axis rotation'),
          _buildControlItem('Reset Button', 'Return to start'),
        ],
      ),
    );
  }

  List<Widget> _buildGeometryButtons() {
    final geometries = ['Tesseract', 'Sphere', 'Grid'];

    return List.generate(geometries.length, (index) {
      final isSelected = selectedGeometry == index;

      return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: ElevatedButton(
          onPressed: () => onGeometryChanged(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.purple : Colors.grey[800],
            minimumSize: Size(double.infinity, 45),
          ),
          child: Text(
            geometries[index],
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildControlItem(String key, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
```

### Step 5: Create Custom Painter

`lib/painters/tesseract_painter.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

class TesseractPainter extends CustomPainter {
  final Map<String, double> rot4d;
  final int geometryType;
  final CanvasRenderer renderer = CanvasRenderer();

  TesseractPainter({
    required this.rot4d,
    this.geometryType = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background already drawn by container

    if (rot4d.isEmpty) return;

    switch (geometryType) {
      case 0: // Tesseract
        renderer.renderTesseract(
          canvas: canvas,
          size: size,
          rotations: rot4d,
          scale: size.width * 0.15,
          color: Colors.purpleAccent,
          strokeWidth: 2.0,
        );
        break;

      case 1: // Sphere
        renderer.renderSphere(
          canvas: canvas,
          size: size,
          rotations: rot4d,
          radius: size.width * 0.25,
          segments: 30,
          rings: 15,
          baseHue: 280.0,
        );
        break;

      case 2: // Grid
        renderer.renderGrid(
          canvas: canvas,
          size: size,
          rotations: rot4d,
          gridSize: 12,
          spacing: 20.0,
          color: Colors.purpleAccent.withOpacity(0.5),
          strokeWidth: 1.5,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### Step 6: Customize HTML

`web/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="VIB34D 4D Geometric Visualizer - Interactive quaternion-based 4D geometry exploration">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="VIB34D Visualizer">

  <title>VIB34D 4D Geometric Visualizer</title>
  <link rel="manifest" href="manifest.json">

  <style>
    body {
      margin: 0;
      padding: 0;
      background: #000;
    }

    .loading {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      flex-direction: column;
      color: #fff;
      font-family: Arial, sans-serif;
    }

    .spinner {
      border: 4px solid #333;
      border-top: 4px solid #a855f7;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
      margin-bottom: 20px;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <!-- Loading indicator -->
  <div class="loading" id="loading">
    <div class="spinner"></div>
    <p>Loading VIB34D Visualizer...</p>
  </div>

  <script>
    // Use CanvasKit renderer for better performance
    window.flutterConfiguration = {
      canvasKitBaseUrl: "https://unpkg.com/canvaskit-wasm@latest/bin/"
    };

    // Hide loading indicator when Flutter is ready
    window.addEventListener('flutter-first-frame', function() {
      const loading = document.getElementById('loading');
      if (loading) {
        loading.style.display = 'none';
      }
    });
  </script>

  <script src="flutter.js" defer></script>
</body>
</html>
```

---

## Optimization

### 1. Build for Production

```bash
# Build optimized version
flutter build web --release

# Output will be in build/web/
```

### 2. Enable CanvasKit

CanvasKit provides better performance for canvas-heavy apps:

```html
<!-- In index.html -->
<script>
  window.flutterConfiguration = {
    renderer: "canvaskit",
    canvasKitBaseUrl: "https://unpkg.com/canvaskit-wasm@latest/bin/"
  };
</script>
```

### 3. Code Splitting

Add deferred loading for large widgets:

```dart
import 'package:flutter/material.dart';

// Defer loading of heavy widgets
class DeferredWidget extends StatefulWidget {
  @override
  _DeferredWidgetState createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  Widget? _widget;

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  Future<void> _loadWidget() async {
    // Simulate async loading
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _widget = HeavyVisualizationWidget();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _widget ?? CircularProgressIndicator();
  }
}
```

### 4. Image Optimization

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/

# Optimize images before adding
# Use WebP format for smaller file sizes
```

---

## Deployment

### 1. Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Select build/web as public directory

# Deploy
firebase deploy
```

### 2. GitHub Pages

```bash
# Build
flutter build web --release --base-href "/your-repo-name/"

# Navigate to output
cd build/web

# Initialize git
git init
git add .
git commit -m "Deploy to GitHub Pages"

# Push to gh-pages branch
git push -f https://github.com/username/repo.git main:gh-pages
```

### 3. Netlify

1. Build locally: `flutter build web --release`
2. Drag `build/web` folder to Netlify
3. Or connect GitHub repo with build command: `flutter build web --release`

### 4. Custom Server (nginx)

```nginx
# /etc/nginx/sites-available/vib34d

server {
    listen 80;
    server_name yourdomain.com;

    root /var/www/vib34d/build/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## Troubleshooting

### Issue: Blank screen on load

**Solution**: Check browser console for errors. Ensure base href is set correctly:

```html
<base href="/">
<!-- or for subdirectory -->
<base href="/my-app/">
```

### Issue: Large bundle size

**Solution**: Use code splitting and lazy loading:

```dart
import 'heavy_widget.dart' deferred as heavy;

// Later:
await heavy.loadLibrary();
final widget = heavy.HeavyWidget();
```

### Issue: Poor performance

**Solution**:
1. Use CanvasKit renderer
2. Reduce geometry complexity
3. Enable web-specific optimizations:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

// In your widget:
final segments = kIsWeb ? 20 : 40;  // Fewer on web
```

### Issue: Mouse events not working

**Solution**: Ensure MouseRegion wraps your widget:

```dart
MouseRegion(
  onHover: (event) => handleMouseMove(event.localPosition),
  child: YourWidget(),
)
```

---

## Resources

- **Flutter Web Docs**: https://flutter.dev/web
- **VIB34D Examples**: [examples/web_examples/](examples/web_examples/)
- **Web App Guide**: [WEB_APP_GUIDE.md](WEB_APP_GUIDE.md)
- **API Reference**: [FLUTTER_README.md](FLUTTER_README.md)

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**

🌟 **Ready to deploy your Flutter Web app!** 🌟
