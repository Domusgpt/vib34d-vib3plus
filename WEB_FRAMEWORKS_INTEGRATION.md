# VIB34D SDK - Web Frameworks Integration Guide

**Integrating VIB34D Quaternion SDK with React, Vue, Angular, and Vanilla JavaScript**

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Vanilla JavaScript](#vanilla-javascript)
4. [React Integration](#react-integration)
5. [Vue Integration](#vue-integration)
6. [Angular Integration](#angular-integration)
7. [TypeScript Support](#typescript-support)
8. [Best Practices](#best-practices)

---

## Overview

The VIB34D SDK can be used in **two ways** with web frameworks:

### Option 1: Flutter Web (Recommended)
- Use Flutter Web to compile to JavaScript
- Full SDK functionality
- Native Dart performance
- Best for new projects

### Option 2: JavaScript Port (This Guide)
- Port core algorithms to JavaScript/TypeScript
- Integrate with existing React/Vue/Angular apps
- Lighter weight
- Best for existing projects

This guide focuses on **Option 2** - integrating the core SDK algorithms into existing web frameworks.

---

## Architecture

### Core Components to Port

The SDK has three main layers that can be ported to JavaScript:

```
┌─────────────────────────────────────┐
│   Your Web Framework                │
│   (React/Vue/Angular/Vanilla)       │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│   VIB34D JavaScript SDK             │
│                                     │
│   ├── Quaternion Math               │
│   ├── Euler Conversion              │
│   ├── 4D Rotation Synthesis         │
│   ├── Input Handlers                │
│   └── Visualization Helpers         │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│   Canvas 2D / WebGL                 │
└─────────────────────────────────────┘
```

### File Structure

```
your-web-project/
├── src/
│   ├── lib/
│   │   ├── quaternion.js          # Core quaternion math
│   │   ├── euler.js               # Euler angle conversion
│   │   ├── rotation4d.js          # 4D rotation synthesis
│   │   ├── input-handler.js       # Mouse/touch/keyboard
│   │   └── visualizer.js          # Canvas rendering
│   ├── components/
│   │   └── Tesseract Viewer.jsx   # Your framework components
│   └── app.js
```

---

## Vanilla JavaScript

### 1. Core Quaternion Class

Create `quaternion.js`:

```javascript
/**
 * Quaternion class for 3D rotations
 * Based on VIB34D Dart implementation
 */
class Quaternion {
  constructor(x = 0, y = 0, z = 0, w = 1) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
  }

  // Normalize to unit length
  normalize() {
    const length = Math.sqrt(
      this.x * this.x +
      this.y * this.y +
      this.z * this.z +
      this.w * this.w
    );

    if (length === 0) {
      return new Quaternion(0, 0, 0, 1);
    }

    return new Quaternion(
      this.x / length,
      this.y / length,
      this.z / length,
      this.w / length
    );
  }

  // Convert to Euler angles (roll, pitch, yaw)
  toEuler() {
    // Roll (x-axis rotation)
    const sinr = 2.0 * (this.w * this.x + this.y * this.z);
    const cosr = 1.0 - 2.0 * (this.x * this.x + this.y * this.y);
    const roll = Math.atan2(sinr, cosr);

    // Pitch (y-axis rotation)
    const sinp = 2.0 * (this.w * this.y - this.z * this.x);
    let pitch;
    if (Math.abs(sinp) >= 1) {
      pitch = Math.sign(sinp) * Math.PI / 2;
    } else {
      pitch = Math.asin(sinp);
    }

    // Yaw (z-axis rotation)
    const siny = 2.0 * (this.w * this.z + this.x * this.y);
    const cosy = 1.0 - 2.0 * (this.y * this.y + this.z * this.z);
    const yaw = Math.atan2(siny, cosy);

    return { roll, pitch, yaw };
  }

  // Create from Euler angles
  static fromEuler(roll, pitch, yaw) {
    const cr = Math.cos(roll * 0.5);
    const sr = Math.sin(roll * 0.5);
    const cp = Math.cos(pitch * 0.5);
    const sp = Math.sin(pitch * 0.5);
    const cy = Math.cos(yaw * 0.5);
    const sy = Math.sin(yaw * 0.5);

    return new Quaternion(
      sr * cp * cy - cr * sp * sy,  // x
      cr * sp * cy + sr * cp * sy,  // y
      cr * cp * sy - sr * sp * cy,  // z
      cr * cp * cy + sr * sp * sy   // w
    );
  }

  // Multiply two quaternions
  multiply(other) {
    return new Quaternion(
      this.w * other.x + this.x * other.w + this.y * other.z - this.z * other.y,
      this.w * other.y - this.x * other.z + this.y * other.w + this.z * other.x,
      this.w * other.z + this.x * other.y - this.y * other.x + this.z * other.w,
      this.w * other.w - this.x * other.x - this.y * other.y - this.z * other.z
    );
  }
}

export default Quaternion;
```

### 2. 4D Rotation Synthesizer

Create `rotation4d.js`:

```javascript
import Quaternion from './quaternion.js';

/**
 * Synthesize 4D rotation parameters from quaternion
 * Matches VIB34D ShaderQuaternionSynchronizer
 */
export function synthesize4DRotations(quaternion, rotationScale = 1.0) {
  const normalized = quaternion.normalize();
  const euler = normalized.toEuler();

  return {
    rot4dXY: (euler.pitch + euler.yaw) * 0.5 * rotationScale,
    rot4dXZ: (euler.pitch + euler.roll) * 0.5 * rotationScale,
    rot4dYZ: (euler.yaw + euler.roll) * 0.5 * rotationScale,
    rot4dXW: euler.pitch * rotationScale,
    rot4dYW: euler.yaw * rotationScale,
    rot4dZW: euler.roll * rotationScale,
  };
}

/**
 * Apply 4D rotations to a 4D point
 */
export function rotate4D(point, rotations) {
  let { x, y, z, w } = point;

  // XY rotation
  if (rotations.rot4dXY) {
    const angle = rotations.rot4dXY;
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const newX = x * cos - y * sin;
    const newY = x * sin + y * cos;
    x = newX;
    y = newY;
  }

  // XZ rotation
  if (rotations.rot4dXZ) {
    const angle = rotations.rot4dXZ;
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const newX = x * cos - z * sin;
    const newZ = x * sin + z * cos;
    x = newX;
    z = newZ;
  }

  // XW rotation
  if (rotations.rot4dXW) {
    const angle = rotations.rot4dXW;
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const newX = x * cos - w * sin;
    const newW = x * sin + w * cos;
    x = newX;
    w = newW;
  }

  // YZ rotation
  if (rotations.rot4dYZ) {
    const angle = rotations.rot4dYZ;
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const newY = y * cos - z * sin;
    const newZ = y * sin + z * cos;
    y = newY;
    z = newZ;
  }

  // YW rotation
  if (rotations.rot4dYW) {
    const angle = rotations.rot4dYW;
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const newY = y * cos - w * sin;
    const newW = y * sin + w * cos;
    y = newY;
    w = newW;
  }

  // ZW rotation
  if (rotations.rot4dZW) {
    const angle = rotations.rot4dZW;
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const newZ = z * cos - w * sin;
    const newW = z * sin + w * cos;
    z = newZ;
    w = newW;
  }

  return { x, y, z, w };
}
```

### 3. Mouse Input Handler

Create `input-handler.js`:

```javascript
import Quaternion from './quaternion.js';

export class MouseInputHandler {
  constructor(config = {}) {
    this.sensitivity = config.sensitivity || 0.005;
    this.invertY = config.invertY || false;
    this.smoothing = config.smoothing || 0.15;

    this.rotationX = 0;
    this.rotationY = 0;
    this.rotationZ = 0;

    this.lastMouseX = 0;
    this.lastMouseY = 0;
    this.isMouseDown = false;

    this.smoothedDeltaX = 0;
    this.smoothedDeltaY = 0;

    this.callbacks = [];
  }

  handleMouseDown(x, y) {
    this.isMouseDown = true;
    this.lastMouseX = x;
    this.lastMouseY = y;
    this.smoothedDeltaX = 0;
    this.smoothedDeltaY = 0;
  }

  handleMouseUp() {
    this.isMouseDown = false;
  }

  handleMouseMove(x, y) {
    if (!this.isMouseDown) return;

    const deltaX = x - this.lastMouseX;
    const deltaY = y - this.lastMouseY;

    // Apply smoothing
    this.smoothedDeltaX = this.smoothedDeltaX * (1 - this.smoothing) +
                          deltaX * this.smoothing;
    this.smoothedDeltaY = this.smoothedDeltaY * (1 - this.smoothing) +
                          deltaY * this.smoothing;

    // Apply sensitivity
    let rotX = this.smoothedDeltaY * this.sensitivity;
    let rotY = this.smoothedDeltaX * this.sensitivity;

    if (this.invertY) rotX = -rotX;

    this.rotationX += rotX;
    this.rotationY += rotY;

    this.lastMouseX = x;
    this.lastMouseY = y;

    this._notifyCallbacks();
  }

  handleWheel(delta) {
    this.rotationZ += delta * this.sensitivity * 0.1;
    this._notifyCallbacks();
  }

  getCurrentQuaternion() {
    return Quaternion.fromEuler(
      this.rotationZ,
      this.rotationX,
      this.rotationY
    );
  }

  reset() {
    this.rotationX = 0;
    this.rotationY = 0;
    this.rotationZ = 0;
    this._notifyCallbacks();
  }

  onChange(callback) {
    this.callbacks.push(callback);
  }

  _notifyCallbacks() {
    const quaternion = this.getCurrentQuaternion();
    this.callbacks.forEach(cb => cb(quaternion));
  }
}
```

### 4. Canvas Visualizer

Create `visualizer.js`:

```javascript
import { rotate4D } from './rotation4d.js';

export class CanvasVisualizer {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.width = canvas.width;
    this.height = canvas.height;
  }

  clear() {
    this.ctx.fillStyle = '#000';
    this.ctx.fillRect(0, 0, this.width, this.height);
  }

  // Generate tesseract vertices
  generateTesseract(size = 1) {
    const vertices = [];
    for (let i = 0; i < 16; i++) {
      const x = ((i & 1) * 2 - 1) * size;
      const y = (((i >> 1) & 1) * 2 - 1) * size;
      const z = (((i >> 2) & 1) * 2 - 1) * size;
      const w = (((i >> 3) & 1) * 2 - 1) * size;
      vertices.push({ x, y, z, w });
    }
    return vertices;
  }

  // Project 4D to 2D
  project(point4d, scale = 100, distance = 2) {
    const factor = distance / (distance + point4d.w);
    const x3d = point4d.x * factor;
    const y3d = point4d.y * factor;
    const z3d = point4d.z * factor;

    const perspective = 500;
    const factor3d = perspective / (perspective + z3d);

    return {
      x: x3d * factor3d * scale + this.width / 2,
      y: y3d * factor3d * scale + this.height / 2,
    };
  }

  // Render tesseract
  renderTesseract(rotations) {
    const vertices4d = this.generateTesseract();
    const rotatedVertices = vertices4d.map(v => rotate4D(v, rotations));
    const points2d = rotatedVertices.map(v => this.project(v));

    // Define edges (same as Dart version)
    const edges = [
      // Inner cube
      [0, 1], [1, 3], [3, 2], [2, 0],
      [4, 5], [5, 7], [7, 6], [6, 4],
      [0, 4], [1, 5], [2, 6], [3, 7],
      // Outer cube
      [8, 9], [9, 11], [11, 10], [10, 8],
      [12, 13], [13, 15], [15, 14], [14, 12],
      [8, 12], [9, 13], [10, 14], [11, 15],
      // Connections
      [0, 8], [1, 9], [2, 10], [3, 11],
      [4, 12], [5, 13], [6, 14], [7, 15],
    ];

    // Draw edges
    this.ctx.strokeStyle = '#a855f7';
    this.ctx.lineWidth = 2;

    edges.forEach(([i1, i2]) => {
      const p1 = points2d[i1];
      const p2 = points2d[i2];

      this.ctx.beginPath();
      this.ctx.moveTo(p1.x, p1.y);
      this.ctx.lineTo(p2.x, p2.y);
      this.ctx.stroke();
    });

    // Draw vertices
    this.ctx.fillStyle = '#a855f7';
    points2d.forEach(point => {
      this.ctx.beginPath();
      this.ctx.arc(point.x, point.y, 3, 0, Math.PI * 2);
      this.ctx.fill();
    });
  }
}
```

### 5. Putting It All Together

Create `main.js`:

```javascript
import Quaternion from './lib/quaternion.js';
import { synthesize4DRotations } from './lib/rotation4d.js';
import { MouseInputHandler } from './lib/input-handler.js';
import { CanvasVisualizer } from './lib/visualizer.js';

// Initialize
const canvas = document.getElementById('canvas');
canvas.width = 800;
canvas.height = 600;

const visualizer = new CanvasVisualizer(canvas);
const inputHandler = new MouseInputHandler({
  sensitivity: 0.005,
  smoothing: 0.15,
});

let currentRotations = {};

// Handle input changes
inputHandler.onChange((quaternion) => {
  currentRotations = synthesize4DRotations(quaternion);
  render();
});

// Set up mouse events
canvas.addEventListener('mousedown', (e) => {
  inputHandler.handleMouseDown(e.offsetX, e.offsetY);
});

canvas.addEventListener('mouseup', () => {
  inputHandler.handleMouseUp();
});

canvas.addEventListener('mousemove', (e) => {
  inputHandler.handleMouseMove(e.offsetX, e.offsetY);
});

canvas.addEventListener('wheel', (e) => {
  e.preventDefault();
  inputHandler.handleWheel(e.deltaY);
});

// Render function
function render() {
  visualizer.clear();
  visualizer.renderTesseract(currentRotations);
}

// Initial render
render();

// Reset button
document.getElementById('reset').addEventListener('click', () => {
  inputHandler.reset();
});
```

Create `index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <title>VIB34D Tesseract Demo</title>
  <style>
    body {
      margin: 0;
      padding: 20px;
      background: #111;
      color: #fff;
      font-family: Arial, sans-serif;
    }
    #canvas {
      border: 1px solid #333;
      cursor: move;
    }
    button {
      margin-top: 10px;
      padding: 10px 20px;
      background: #a855f7;
      border: none;
      color: white;
      border-radius: 5px;
      cursor: pointer;
    }
    button:hover {
      background: #9333ea;
    }
  </style>
</head>
<body>
  <h1>VIB34D Tesseract Viewer</h1>
  <canvas id="canvas"></canvas>
  <br>
  <button id="reset">Reset</button>

  <script type="module" src="main.js"></script>
</body>
</html>
```

---

## React Integration

### 1. Create React Component

`TesseractViewer.jsx`:

```jsx
import React, { useEffect, useRef, useState } from 'react';
import Quaternion from '../lib/quaternion';
import { synthesize4DRotations } from '../lib/rotation4d';
import { MouseInputHandler } from '../lib/input-handler';
import { CanvasVisualizer } from '../lib/visualizer';

export function TesseractViewer({ width = 800, height = 600 }) {
  const canvasRef = useRef(null);
  const [rotations, setRotations] = useState({});
  const inputHandlerRef = useRef(null);
  const visualizerRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    // Initialize visualizer
    canvas.width = width;
    canvas.height = height;
    visualizerRef.current = new CanvasVisualizer(canvas);

    // Initialize input handler
    inputHandlerRef.current = new MouseInputHandler({
      sensitivity: 0.005,
      smoothing: 0.15,
    });

    inputHandlerRef.current.onChange((quaternion) => {
      const rot4d = synthesize4DRotations(quaternion);
      setRotations(rot4d);
    });

    // Set up event listeners
    const handleMouseDown = (e) => {
      const rect = canvas.getBoundingClientRect();
      inputHandlerRef.current.handleMouseDown(
        e.clientX - rect.left,
        e.clientY - rect.top
      );
    };

    const handleMouseUp = () => {
      inputHandlerRef.current.handleMouseUp();
    };

    const handleMouseMove = (e) => {
      const rect = canvas.getBoundingClientRect();
      inputHandlerRef.current.handleMouseMove(
        e.clientX - rect.left,
        e.clientY - rect.top
      );
    };

    const handleWheel = (e) => {
      e.preventDefault();
      inputHandlerRef.current.handleWheel(e.deltaY);
    };

    canvas.addEventListener('mousedown', handleMouseDown);
    window.addEventListener('mouseup', handleMouseUp);
    window.addEventListener('mousemove', handleMouseMove);
    canvas.addEventListener('wheel', handleWheel, { passive: false });

    return () => {
      canvas.removeEventListener('mousedown', handleMouseDown);
      window.removeEventListener('mouseup', handleMouseUp);
      window.removeEventListener('mousemove', handleMouseMove);
      canvas.removeEventListener('wheel', handleWheel);
    };
  }, [width, height]);

  // Render when rotations change
  useEffect(() => {
    if (visualizerRef.current && Object.keys(rotations).length > 0) {
      visualizerRef.current.clear();
      visualizerRef.current.renderTesseract(rotations);
    }
  }, [rotations]);

  const handleReset = () => {
    if (inputHandlerRef.current) {
      inputHandlerRef.current.reset();
    }
  };

  return (
    <div>
      <canvas
        ref={canvasRef}
        style={{
          border: '1px solid #333',
          cursor: 'move',
        }}
      />
      <br />
      <button onClick={handleReset}>Reset</button>
    </div>
  );
}
```

### 2. Use in App

`App.jsx`:

```jsx
import React from 'react';
import { TesseractViewer } from './components/TesseractViewer';

function App() {
  return (
    <div style={{ padding: '20px', background: '#111', minHeight: '100vh' }}>
      <h1 style={{ color: '#fff' }}>VIB34D Tesseract Viewer</h1>
      <TesseractViewer width={800} height={600} />
    </div>
  );
}

export default App;
```

---

## Vue Integration

### 1. Create Vue Component

`TesseractViewer.vue`:

```vue
<template>
  <div>
    <canvas
      ref="canvas"
      :width="width"
      :height="height"
      @mousedown="handleMouseDown"
      @wheel.prevent="handleWheel"
      style="border: 1px solid #333; cursor: move;"
    />
    <br />
    <button @click="handleReset">Reset</button>
  </div>
</template>

<script>
import Quaternion from '../lib/quaternion';
import { synthesize4DRotations } from '../lib/rotation4d';
import { MouseInputHandler } from '../lib/input-handler';
import { CanvasVisualizer } from '../lib/visualizer';

export default {
  name: 'TesseractViewer',
  props: {
    width: {
      type: Number,
      default: 800,
    },
    height: {
      type: Number,
      default: 600,
    },
  },
  data() {
    return {
      rotations: {},
      inputHandler: null,
      visualizer: null,
    };
  },
  mounted() {
    const canvas = this.$refs.canvas;

    // Initialize visualizer
    this.visualizer = new CanvasVisualizer(canvas);

    // Initialize input handler
    this.inputHandler = new MouseInputHandler({
      sensitivity: 0.005,
      smoothing: 0.15,
    });

    this.inputHandler.onChange((quaternion) => {
      this.rotations = synthesize4DRotations(quaternion);
      this.render();
    });

    // Set up window event listeners
    window.addEventListener('mouseup', this.handleMouseUp);
    window.addEventListener('mousemove', this.handleMouseMove);

    // Initial render
    this.render();
  },
  beforeUnmount() {
    window.removeEventListener('mouseup', this.handleMouseUp);
    window.removeEventListener('mousemove', this.handleMouseMove);
  },
  methods: {
    handleMouseDown(e) {
      const rect = this.$refs.canvas.getBoundingClientRect();
      this.inputHandler.handleMouseDown(
        e.clientX - rect.left,
        e.clientY - rect.top
      );
    },
    handleMouseUp() {
      this.inputHandler.handleMouseUp();
    },
    handleMouseMove(e) {
      if (!this.inputHandler.isMouseDown) return;

      const rect = this.$refs.canvas.getBoundingClientRect();
      this.inputHandler.handleMouseMove(
        e.clientX - rect.left,
        e.clientY - rect.top
      );
    },
    handleWheel(e) {
      this.inputHandler.handleWheel(e.deltaY);
    },
    handleReset() {
      this.inputHandler.reset();
    },
    render() {
      if (Object.keys(this.rotations).length > 0) {
        this.visualizer.clear();
        this.visualizer.renderTesseract(this.rotations);
      }
    },
  },
};
</script>
```

---

## Angular Integration

### 1. Create Angular Component

`tesseract-viewer.component.ts`:

```typescript
import { Component, OnInit, OnDestroy, ElementRef, ViewChild } from '@angular/core';
import { Quaternion } from '../lib/quaternion';
import { synthesize4DRotations } from '../lib/rotation4d';
import { MouseInputHandler } from '../lib/input-handler';
import { CanvasVisualizer } from '../lib/visualizer';

@Component({
  selector: 'app-tesseract-viewer',
  template: `
    <div>
      <canvas
        #canvas
        [width]="width"
        [height]="height"
        (mousedown)="handleMouseDown($event)"
        (wheel)="handleWheel($event)"
        style="border: 1px solid #333; cursor: move;"
      ></canvas>
      <br />
      <button (click)="handleReset()">Reset</button>
    </div>
  `,
})
export class TesseractViewerComponent implements OnInit, OnDestroy {
  @ViewChild('canvas', { static: true }) canvasRef!: ElementRef<HTMLCanvasElement>;

  width = 800;
  height = 600;

  private rotations: any = {};
  private inputHandler!: MouseInputHandler;
  private visualizer!: CanvasVisualizer;

  ngOnInit() {
    const canvas = this.canvasRef.nativeElement;

    // Initialize visualizer
    this.visualizer = new CanvasVisualizer(canvas);

    // Initialize input handler
    this.inputHandler = new MouseInputHandler({
      sensitivity: 0.005,
      smoothing: 0.15,
    });

    this.inputHandler.onChange((quaternion: any) => {
      this.rotations = synthesize4DRotations(quaternion);
      this.render();
    });

    // Set up event listeners
    window.addEventListener('mouseup', this.handleMouseUp);
    window.addEventListener('mousemove', this.handleMouseMove);

    // Initial render
    this.render();
  }

  ngOnDestroy() {
    window.removeEventListener('mouseup', this.handleMouseUp);
    window.removeEventListener('mousemove', this.handleMouseMove);
  }

  handleMouseDown(e: MouseEvent) {
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    this.inputHandler.handleMouseDown(
      e.clientX - rect.left,
      e.clientY - rect.top
    );
  }

  handleMouseUp = () => {
    this.inputHandler.handleMouseUp();
  };

  handleMouseMove = (e: MouseEvent) => {
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    this.inputHandler.handleMouseMove(
      e.clientX - rect.left,
      e.clientY - rect.top
    );
  };

  handleWheel(e: WheelEvent) {
    e.preventDefault();
    this.inputHandler.handleWheel(e.deltaY);
  }

  handleReset() {
    this.inputHandler.reset();
  }

  render() {
    if (Object.keys(this.rotations).length > 0) {
      this.visualizer.clear();
      this.visualizer.renderTesseract(this.rotations);
    }
  }
}
```

---

## TypeScript Support

Convert classes to TypeScript for better type safety:

`quaternion.ts`:

```typescript
export interface EulerAngles {
  roll: number;
  pitch: number;
  yaw: number;
}

export class Quaternion {
  constructor(
    public x: number = 0,
    public y: number = 0,
    public z: number = 0,
    public w: number = 1
  ) {}

  normalize(): Quaternion {
    const length = Math.sqrt(
      this.x ** 2 + this.y ** 2 + this.z ** 2 + this.w ** 2
    );

    if (length === 0) {
      return new Quaternion(0, 0, 0, 1);
    }

    return new Quaternion(
      this.x / length,
      this.y / length,
      this.z / length,
      this.w / length
    );
  }

  toEuler(): EulerAngles {
    // ... (same implementation)
  }

  static fromEuler(roll: number, pitch: number, yaw: number): Quaternion {
    // ... (same implementation)
  }

  multiply(other: Quaternion): Quaternion {
    // ... (same implementation)
  }
}
```

---

## Best Practices

### 1. Performance Optimization

```javascript
// Throttle canvas updates
let rafId = null;
inputHandler.onChange((quaternion) => {
  if (rafId) cancelAnimationFrame(rafId);

  rafId = requestAnimationFrame(() => {
    currentRotations = synthesize4DRotations(quaternion);
    render();
  });
});
```

### 2. Memory Management

```javascript
// Clean up on component unmount
componentWillUnmount() {
  if (this.inputHandler) {
    this.inputHandler.callbacks = [];
  }
}
```

### 3. Responsive Canvas

```javascript
function resizeCanvas() {
  const canvas = document.getElementById('canvas');
  canvas.width = window.innerWidth * 0.8;
  canvas.height = window.innerHeight * 0.8;
  visualizer.width = canvas.width;
  visualizer.height = canvas.height;
  render();
}

window.addEventListener('resize', resizeCanvas);
```

---

## Resources

- **Complete Demo**: See [demo/](../demo/) folder for working vanilla JS implementation
- **Flutter Web Guide**: [WEB_APP_GUIDE.md](WEB_APP_GUIDE.md)
- **API Reference**: [FLUTTER_README.md](FLUTTER_README.md)

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**

🌟 **Ready to integrate into your web framework!** 🌟
