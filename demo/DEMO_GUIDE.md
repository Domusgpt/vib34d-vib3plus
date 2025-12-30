# VIB34D XR Quaternion SDK - Interactive Demo Guide

## 🎯 Overview

This interactive web demo demonstrates the **complete quaternion data flow** from the VIB34D Flutter SDK in real-time. It simulates AR/VR device tracking and shows how quaternion mathematics drive 4D geometric visualizations.

---

## 🚀 Quick Start

### Running the Demo

1. **Option 1: Local File**
   ```bash
   # Open in browser
   open demo/index.html
   # or
   firefox demo/index.html
   ```

2. **Option 2: Local Server** (recommended)
   ```bash
   cd demo
   python3 -m http.server 8000
   # Visit: http://localhost:8000
   ```

3. **Option 3: Live Server** (VS Code)
   - Install "Live Server" extension
   - Right-click `index.html` → "Open with Live Server"

---

## 🎨 What You'll See

### Main Visualization Area

The center canvas displays a **4D geometric projection** that responds to quaternion rotations:

- **Layered Polygons**: Multiple depth layers creating 4D effect
- **Rotation Trails**: Colored dots showing 4D rotation planes
- **Center Glow**: Pulsates based on motion energy
- **Dynamic Morphing**: Geometry shape changes with quaternion state

### Sidebar Controls

Complete control panel showing live SDK state and interactive controls.

---

## 🎮 Controls & Features

### 1. **Status Panel**

**Real-time Performance Metrics:**
- 🟢 **Pipeline Active**: Indicates quaternion processing is running
- **FPS Counter**: Current frames per second (target: 60 FPS)
- **Frame Time**: Milliseconds per frame (target: <16.67ms)

**What it shows:**
- Green pulsing indicator = System running
- FPS should be stable at 60
- Frame time should stay below 16.67ms for smooth 60 FPS

---

### 2. **Geometry Selection**

**8 Base Geometries Available:**

| Button | Geometry | Characteristics |
|--------|----------|-----------------|
| Tetrahedron | 4-sided | Simple, fast |
| Hypercube | 8-sided | Classic 4D shape |
| Sphere | 32-sided | Smooth, circular |
| Torus | 24-sided | Donut shape |
| Klein | 20-sided | Complex topology |
| Fractal | 12-sided | Self-similar patterns |
| Wave | 16-sided | Undulating motion |
| Crystal | 6-sided | Angular, faceted |

**Controls:**
- **Click geometry buttons**: Switch between geometries instantly
- **🎲 Random Geometry**: Randomly select a new geometry
- **Current badge**: Shows "X/24" (current index out of 24 total)

**How it works:**
1. Click a geometry button
2. Visualization instantly switches to new shape
3. All quaternion calculations continue seamlessly
4. 4D rotations apply to new geometry

---

### 3. **Quaternion Simulation**

**Rotation Speed Slider:**
- **Range**: 0.0x to 5.0x
- **Default**: 1.0x
- **What it does**: Controls how fast the simulated AR device rotates

**Effect on visualization:**
- **Slower (0.5x)**: Gentle, meditative rotation
- **Normal (1.0x)**: Standard AR tracking simulation
- **Faster (2.5x)**: Rapid, energetic motion

**Motion Energy Bar:**
- **Color**: Blue gradient progress bar
- **Range**: 0% to 100%
- **Updates**: Real-time based on angular velocity
- **Algorithm**: Exponential moving average (EMA) smoothing

**How Motion Energy Works:**
```
1. Compute angular difference between frames
2. Calculate angular velocity (rad/s)
3. Normalize to 0-1 scale (reference: 8 rad/s)
4. Smooth with EMA (α = 0.35)
5. Display as percentage
```

---

### 4. **4D Rotation Parameters**

**Six Rotation Planes:**

| Plane | Description | Visual Effect |
|-------|-------------|---------------|
| **XY** | Combined pitch + yaw | Horizontal swirl |
| **XZ** | Combined pitch + roll | Vertical tilt |
| **YZ** | Combined yaw + roll | Diagonal twist |
| **XW** | Pure pitch in 4D | Forward/back rotation |
| **YW** | Pure yaw in 4D | Left/right rotation |
| **ZW** | Pure roll in 4D | Clockwise/counter rotation |

**Display Format:**
- Monospace font for precision
- 3 decimal places (e.g., `0.732`)
- Values range from `-6.28` to `+6.28` (±2π radians)
- Updates 60 times per second

**What This Shows:**
This panel demonstrates **exactly** how the `ShaderQuaternionSynchronizer` converts quaternion data to 4D rotation parameters in the Flutter SDK.

---

### 5. **Quaternion State**

**Raw Quaternion Components:**

```
x: 0.123   ← Rotation around X axis
y: 0.456   ← Rotation around Y axis
z: 0.789   ← Rotation around Z axis
w: 0.987   ← Scalar/real component
```

**Properties:**
- Always normalized (length = 1.0)
- Updates every frame
- Direct representation of 3D rotation

**How to Read:**
- **(0, 0, 0, 1)** = Identity (no rotation)
- **w close to 1** = Small rotation
- **w close to 0** = Large rotation (near 180°)

---

### 6. **Euler Angles**

**Human-Readable Rotation:**

```
Roll:  12.3°   ← Rotation around forward axis (lean)
Pitch: 45.6°   ← Rotation around side axis (nod)
Yaw:   78.9°   ← Rotation around up axis (turn)
```

**Conversion Process:**
1. Take normalized quaternion (x, y, z, w)
2. Apply `QuaternionUtils.toEuler()` algorithm
3. Convert radians to degrees
4. Display with 1 decimal precision

**Why Both Quaternion & Euler?**
- **Quaternion**: Efficient, no gimbal lock, used internally
- **Euler**: Intuitive, human-readable, used for display

---

### 7. **Action Buttons**

**🔄 Reset View:**
- Resets time to 0
- Clears motion energy
- Returns quaternion to identity
- Visualization returns to neutral state

**⏸ Pause / ▶️ Resume:**
- Freezes quaternion updates
- Visualization holds current state
- Useful for examining specific rotations
- Button text toggles to show current state

---

## 🔬 How It Works: Data Flow

### The Complete Pipeline

```
┌─────────────────────────────────────────────────────┐
│ 1. SIMULATION                                       │
│    Generate rotating Euler angles                   │
│    (simulates AR device movement)                   │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 2. QUATERNION CONVERSION                            │
│    Euler → Quaternion                               │
│    Quaternion.fromEuler(roll, pitch, yaw)          │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 3. NORMALIZATION                                    │
│    Ensure unit length                               │
│    quaternion.normalize()                           │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 4. MOTION ENERGY CALCULATION                        │
│    - Compute angular difference                     │
│    - Calculate angular velocity                     │
│    - Smooth with EMA                                │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 5. EULER CONVERSION                                 │
│    Quaternion → Euler                               │
│    quaternion.toEuler()                             │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 6. 4D ROTATION MAPPING                              │
│    ShaderQuaternionSynchronizer algorithm:          │
│    rot4dXY = (pitch + yaw) / 2 * scale             │
│    rot4dXZ = (pitch + roll) / 2 * scale            │
│    rot4dYZ = (yaw + roll) / 2 * scale              │
│    rot4dXW = pitch * scale                          │
│    rot4dYW = yaw * scale                            │
│    rot4dZW = roll * scale                           │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 7. VISUALIZATION                                    │
│    - Apply 4D rotations to geometry                │
│    - Project to 2D canvas                           │
│    - Render with motion blur and trails            │
└─────────────────────────────────────────────────────┘
```

---

## 🎓 What This Demonstrates

### SDK Concepts Visualized

1. **Quaternion Mathematics**
   - ✅ Normalization
   - ✅ Euler conversion
   - ✅ Motion energy computation

2. **Data Flow**
   - ✅ Sensor input simulation
   - ✅ Quaternion processing
   - ✅ 4D rotation synthesis

3. **Geometry System**
   - ✅ 8 base geometries (24 total with cores)
   - ✅ Real-time geometry switching
   - ✅ Procedural rendering

4. **Performance**
   - ✅ 60 FPS target
   - ✅ Sub-16ms frame time
   - ✅ Smooth quaternion updates

---

## 🧪 Experiments to Try

### 1. **Observe Motion Energy**

**Steps:**
1. Start with default speed (1.0x)
2. Watch motion energy bar
3. Increase speed to 3.0x
4. Notice energy increases

**Expected:**
- Higher rotation speed = higher motion energy
- Energy smooths out over time (EMA effect)
- Visualization glow intensifies with energy

---

### 2. **Compare Geometries**

**Steps:**
1. Select "Sphere" (32 sides)
2. Observe smooth rotation
3. Select "Tetrahedron" (4 sides)
4. Compare rotation appearance

**Expected:**
- Sphere: Smooth, circular motion
- Tetrahedron: Angular, faceted motion
- Same quaternion data, different visual result

---

### 3. **Pause and Examine**

**Steps:**
1. Let visualization run for a few seconds
2. Click "⏸ Pause"
3. Read all quaternion values
4. Note 4D rotation parameters

**Expected:**
- Frozen quaternion state
- Can examine exact rotation values
- Understand quaternion-to-rotation mapping

---

### 4. **Reset and Compare**

**Steps:**
1. Run for 10 seconds
2. Note quaternion and Euler values
3. Click "🔄 Reset View"
4. Observe return to identity

**Expected:**
- Quaternion: (0, 0, 0, 1)
- Euler: (0°, 0°, 0°)
- All 4D rotations: 0.000

---

## 📊 Performance Monitoring

### What to Watch

**Good Performance:**
- FPS: 58-60 (stable)
- Frame Time: 8-16ms
- Motion Energy: Smooth transitions

**Poor Performance:**
- FPS: Below 30 (choppy)
- Frame Time: Above 20ms
- Motion Energy: Erratic jumps

### Optimization Tips

1. **Reduce Geometry Complexity**
   - Use Tetrahedron (4 sides) instead of Sphere (32 sides)

2. **Lower Rotation Speed**
   - Slower speed = less computation

3. **Close Other Tabs**
   - Free up browser resources

---

## 🔍 Code Walkthrough

### Key Components

**1. Quaternion Class** (`demo.js:10-95`)
```javascript
class Quaternion {
    normalize() { /* Ensure unit length */ }
    toEuler() { /* Convert to Euler angles */ }
    static fromEuler() { /* Create from Euler */ }
}
```

**2. Visualization Class** (`demo.js:110-320`)
```javascript
class Visualization {
    updateQuaternion() { /* Simulate AR tracking */ }
    updateMotionEnergy() { /* Compute energy */ }
    render() { /* Draw to canvas */ }
}
```

**3. UI Controller** (`demo.js:325-410`)
```javascript
class UIController {
    setupControls() { /* Wire up buttons */ }
    updateUI() { /* Refresh displays */ }
}
```

---

## 🎯 Learning Outcomes

After using this demo, you understand:

1. ✅ **How quaternions represent 3D rotations**
2. ✅ **Quaternion-to-Euler conversion process**
3. ✅ **4D rotation parameter synthesis**
4. ✅ **Motion energy computation from angular velocity**
5. ✅ **Real-time data flow in XR applications**
6. ✅ **Performance considerations for 60 FPS**

---

## 🔗 Relation to Flutter SDK

### Direct Equivalents

| Demo Component | Flutter SDK Equivalent |
|----------------|------------------------|
| `Quaternion` class | `lib/src/core/quaternion.dart` |
| `updateMotionEnergy()` | `QuaternionFieldService.computeMotionEnergy()` |
| `rot4d` mapping | `ShaderQuaternionSynchronizer._applyNormalizedOrientation()` |
| UI updates | Flutter `StreamBuilder` widgets |
| Geometry switching | `GeometryLibrary.describeGeometry()` |

### Same Algorithms

The demo uses **identical mathematics** to the Flutter SDK:
- Quaternion normalization formula
- Euler conversion algorithm
- Motion energy EMA smoothing (α=0.35)
- 4D rotation mapping equations
- Velocity reference (8.0 rad/s)

---

## 💡 Next Steps

### Integrate with Real AR

To use this with actual ARCore/ARKit:

1. **Replace simulation** with real tracking:
   ```javascript
   // Instead of:
   const roll = Math.sin(this.time * 0.5) * 0.3;

   // Use:
   arSession.onPoseUpdate = (pose) => {
       this.quaternion = pose.orientation;
   };
   ```

2. **Feed real data** to the pipeline
3. **Everything else stays the same!**

### Extend the Visualization

Ideas to try:
- Add more geometry types
- Implement different 4D projection methods
- Add particle effects driven by motion energy
- Create VR/AR overlay mode

---

## 🐛 Troubleshooting

### Problem: Low FPS

**Solutions:**
- Close other browser tabs
- Reduce geometry complexity (use Tetrahedron)
- Lower rotation speed
- Check browser hardware acceleration

### Problem: Quaternion Not Updating

**Check:**
- Animation not paused (button should say "⏸ Pause")
- Browser tab is active (animations pause when hidden)
- No JavaScript errors in console (F12)

### Problem: Values Show NaN

**Fix:**
- Click "🔄 Reset View"
- Refresh page
- This shouldn't happen with normalized quaternions

---

## 📚 References

- **Flutter SDK**: See `FLUTTER_README.md`
- **Quaternion Math**: See `docs/architecture/QUATERNION_FLOW.md`
- **Performance**: See `docs/PERFORMANCE.md`
- **ARCore Integration**: See `docs/guides/ARCORE_INTEGRATION.md`

---

## ✨ Enjoy Exploring!

This demo brings the VIB34D Flutter SDK to life in your browser. Every value you see represents actual SDK calculations happening in real-time.

**Questions?** Check the main documentation or open an issue on GitHub.

**Ready for Flutter?** See `QUICKSTART.md` to integrate into your app.

---

**Built with the VIB34D XR Quaternion SDK**
© 2025 Paul Phillips - Clear Seas Solutions LLC
