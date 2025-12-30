/**
 * VIB34D XR Quaternion SDK - Interactive Web Demo
 * Demonstrates quaternion-driven 4D geometric visualization
 */

// ============================================================================
// Quaternion Mathematics (from SDK)
// ============================================================================

class Quaternion {
    constructor(x = 0, y = 0, z = 0, w = 1) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    get length() {
        return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w);
    }

    normalize() {
        const len = this.length;
        if (len === 0) return new Quaternion(0, 0, 0, 1);
        return new Quaternion(
            this.x / len,
            this.y / len,
            this.z / len,
            this.w / len
        );
    }

    toEuler() {
        // Roll (x-axis)
        const sinr = 2.0 * (this.w * this.x + this.y * this.z);
        const cosr = 1.0 - 2.0 * (this.x * this.x + this.y * this.y);
        const roll = Math.atan2(sinr, cosr);

        // Pitch (y-axis)
        const sinp = 2.0 * (this.w * this.y - this.z * this.x);
        const pitch = Math.abs(sinp) >= 1.0
            ? Math.sign(sinp) * Math.PI / 2.0
            : Math.asin(sinp);

        // Yaw (z-axis)
        const siny = 2.0 * (this.w * this.z + this.x * this.y);
        const cosy = 1.0 - 2.0 * (this.y * this.y + this.z * this.z);
        const yaw = Math.atan2(siny, cosy);

        return { roll, pitch, yaw };
    }

    static fromEuler(roll, pitch, yaw) {
        const cy = Math.cos(yaw * 0.5);
        const sy = Math.sin(yaw * 0.5);
        const cp = Math.cos(pitch * 0.5);
        const sp = Math.sin(pitch * 0.5);
        const cr = Math.cos(roll * 0.5);
        const sr = Math.sin(roll * 0.5);

        return new Quaternion(
            sr * cp * cy - cr * sp * sy,
            cr * sp * cy + sr * cp * sy,
            cr * cp * sy - sr * sp * cy,
            cr * cp * cy + sr * sp * sy
        );
    }

    static multiply(a, b) {
        return new Quaternion(
            a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
            a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
            a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
        );
    }

    static conjugate(q) {
        return new Quaternion(-q.x, -q.y, -q.z, q.w);
    }
}

// ============================================================================
// Geometry Library
// ============================================================================

const GEOMETRIES = [
    { name: 'TETRAHEDRON', color: '#ff6b6b', sides: 4 },
    { name: 'HYPERCUBE', color: '#4ecdc4', sides: 8 },
    { name: 'SPHERE', color: '#45b7d1', sides: 32 },
    { name: 'TORUS', color: '#f9ca24', sides: 24 },
    { name: 'KLEIN BOTTLE', color: '#eb4d4b', sides: 20 },
    { name: 'FRACTAL', color: '#6c5ce7', sides: 12 },
    { name: 'WAVE', color: '#a29bfe', sides: 16 },
    { name: 'CRYSTAL', color: '#fd79a8', sides: 6 }
];

// ============================================================================
// 4D Visualization Engine
// ============================================================================

class Visualization {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.width = canvas.width;
        this.height = canvas.height;

        // State
        this.time = 0;
        this.rotationSpeed = 1.0;
        this.currentGeometry = 0;
        this.paused = false;

        // Quaternion state
        this.quaternion = new Quaternion(0, 0, 0, 1);
        this.lastQuaternion = new Quaternion(0, 0, 0, 1);
        this.lastTimestamp = Date.now();
        this.motionEnergy = 0;

        // 4D rotation state
        this.rot4d = {
            XY: 0, XZ: 0, YZ: 0,
            XW: 0, YW: 0, ZW: 0
        };

        // Performance
        this.fps = 0;
        this.frameTime = 0;
        this.lastFpsUpdate = Date.now();
        this.frameCount = 0;
    }

    updateQuaternion() {
        if (this.paused) return;

        // Simulate rotating AR device
        const roll = Math.sin(this.time * this.rotationSpeed * 0.5) * 0.3;
        const pitch = Math.cos(this.time * this.rotationSpeed * 0.7) * 0.4;
        const yaw = Math.sin(this.time * this.rotationSpeed * 0.3) * 0.5;

        this.quaternion = Quaternion.fromEuler(roll, pitch, yaw).normalize();

        // Compute motion energy (matching SDK)
        this.updateMotionEnergy();

        // Convert to Euler angles
        const euler = this.quaternion.toEuler();

        // Map to 4D rotations (matching ShaderQuaternionSynchronizer)
        const rotationScale = 2.0;
        this.rot4d = {
            XY: (euler.pitch + euler.yaw) * 0.5 * rotationScale,
            XZ: (euler.pitch + euler.roll) * 0.5 * rotationScale,
            YZ: (euler.yaw + euler.roll) * 0.5 * rotationScale,
            XW: euler.pitch * rotationScale,
            YW: euler.yaw * rotationScale,
            ZW: euler.roll * rotationScale
        };

        this.time += 0.016; // 60 FPS
    }

    updateMotionEnergy() {
        const now = Date.now();
        const deltaTime = (now - this.lastTimestamp) / 1000.0;

        // Compute quaternion difference
        const deltaQuat = Quaternion.multiply(
            this.quaternion,
            Quaternion.conjugate(this.lastQuaternion)
        );

        // Compute angle
        const angle = 2.0 * Math.atan2(
            Math.sqrt(deltaQuat.x * deltaQuat.x + deltaQuat.y * deltaQuat.y + deltaQuat.z * deltaQuat.z),
            deltaQuat.w
        );

        // Angular velocity
        const angularVelocity = Math.abs(angle) / Math.max(0.001, deltaTime);

        // Normalize to energy (0-1)
        const velocityReference = 8.0;
        const instantEnergy = Math.min(1.0, angularVelocity / velocityReference);

        // Smooth with EMA (matching SDK)
        const energySmoothing = 0.35;
        this.motionEnergy = this.motionEnergy + (instantEnergy - this.motionEnergy) * energySmoothing;

        this.lastQuaternion = this.quaternion;
        this.lastTimestamp = now;
    }

    render() {
        const startTime = performance.now();

        // Clear canvas
        this.ctx.fillStyle = 'rgba(17, 24, 39, 0.3)';
        this.ctx.fillRect(0, 0, this.width, this.height);

        const centerX = this.width / 2;
        const centerY = this.height / 2;

        // Draw background grid
        this.drawGrid();

        // Get current geometry
        const geo = GEOMETRIES[this.currentGeometry];

        // Draw 4D-projected geometry
        this.draw4DGeometry(centerX, centerY, geo);

        // Draw rotation trails
        this.drawRotationTrails(centerX, centerY);

        // Update performance metrics
        this.frameTime = performance.now() - startTime;
        this.updateFPS();
    }

    drawGrid() {
        this.ctx.strokeStyle = 'rgba(168, 237, 234, 0.1)';
        this.ctx.lineWidth = 1;

        const gridSize = 50;
        for (let x = 0; x < this.width; x += gridSize) {
            this.ctx.beginPath();
            this.ctx.moveTo(x, 0);
            this.ctx.lineTo(x, this.height);
            this.ctx.stroke();
        }

        for (let y = 0; y < this.height; y += gridSize) {
            this.ctx.beginPath();
            this.ctx.moveTo(0, y);
            this.ctx.lineTo(this.width, y);
            this.ctx.stroke();
        }
    }

    draw4DGeometry(cx, cy, geo) {
        const radius = 200;
        const sides = geo.sides;

        // Apply 4D rotations to create dynamic effect
        const offsetX = Math.sin(this.rot4d.XY) * 50;
        const offsetY = Math.cos(this.rot4d.XZ) * 50;

        for (let layer = 0; layer < 3; layer++) {
            const layerDepth = (layer - 1) * 80;
            const layerScale = 1 - Math.abs(layer - 1) * 0.3;
            const alpha = 1 - Math.abs(layer - 1) * 0.5;

            // Project through 4D rotation
            const projection = Math.cos(this.rot4d.XW + layer) * layerScale;

            this.ctx.save();
            this.ctx.translate(cx + offsetX, cy + offsetY);
            this.ctx.rotate(this.rot4d.YZ + layer * 0.5);
            this.ctx.scale(projection, projection);

            // Draw polygon
            this.ctx.beginPath();
            for (let i = 0; i <= sides; i++) {
                const angle = (i / sides) * Math.PI * 2 + this.rot4d.ZW;
                const x = Math.cos(angle) * radius * layerScale;
                const y = Math.sin(angle) * radius * layerScale;

                if (i === 0) {
                    this.ctx.moveTo(x, y);
                } else {
                    this.ctx.lineTo(x, y);
                }
            }

            this.ctx.closePath();
            this.ctx.strokeStyle = geo.color + Math.floor(alpha * 255).toString(16).padStart(2, '0');
            this.ctx.lineWidth = 3;
            this.ctx.stroke();

            // Fill with gradient
            const gradient = this.ctx.createRadialGradient(0, 0, 0, 0, 0, radius * layerScale);
            gradient.addColorStop(0, geo.color + '20');
            gradient.addColorStop(1, geo.color + '00');
            this.ctx.fillStyle = gradient;
            this.ctx.fill();

            this.ctx.restore();
        }

        // Draw center glow (driven by motion energy)
        const glowSize = 20 + this.motionEnergy * 50;
        const gradient = this.ctx.createRadialGradient(cx, cy, 0, cx, cy, glowSize);
        gradient.addColorStop(0, geo.color + 'ff');
        gradient.addColorStop(1, geo.color + '00');
        this.ctx.fillStyle = gradient;
        this.ctx.fillRect(cx - glowSize, cy - glowSize, glowSize * 2, glowSize * 2);
    }

    drawRotationTrails(cx, cy) {
        // Draw trails representing 4D rotation planes
        const trails = [
            { angle: this.rot4d.XY, radius: 250, color: '#667eea' },
            { angle: this.rot4d.YZ, radius: 220, color: '#764ba2' },
            { angle: this.rot4d.ZW, radius: 190, color: '#f093fb' }
        ];

        trails.forEach(trail => {
            const x = cx + Math.cos(trail.angle) * trail.radius;
            const y = cy + Math.sin(trail.angle) * trail.radius;

            const gradient = this.ctx.createRadialGradient(x, y, 0, x, y, 10);
            gradient.addColorStop(0, trail.color + 'ff');
            gradient.addColorStop(1, trail.color + '00');

            this.ctx.fillStyle = gradient;
            this.ctx.beginPath();
            this.ctx.arc(x, y, 10, 0, Math.PI * 2);
            this.ctx.fill();
        });
    }

    updateFPS() {
        this.frameCount++;
        const now = Date.now();
        const elapsed = now - this.lastFpsUpdate;

        if (elapsed >= 1000) {
            this.fps = Math.round((this.frameCount * 1000) / elapsed);
            this.frameCount = 0;
            this.lastFpsUpdate = now;
        }
    }
}

// ============================================================================
// UI Controller
// ============================================================================

class UIController {
    constructor(viz) {
        this.viz = viz;
        this.setupControls();
        this.updateUI();
    }

    setupControls() {
        // Geometry buttons
        document.querySelectorAll('.geometry-btn').forEach((btn, index) => {
            btn.addEventListener('click', () => {
                this.viz.currentGeometry = index;
                this.updateGeometryButtons();
            });
        });

        // Random geometry
        document.getElementById('randomGeometry').addEventListener('click', () => {
            this.viz.currentGeometry = Math.floor(Math.random() * GEOMETRIES.length);
            this.updateGeometryButtons();
        });

        // Rotation speed
        document.getElementById('rotationSpeed').addEventListener('input', (e) => {
            this.viz.rotationSpeed = parseFloat(e.target.value);
        });

        // Reset view
        document.getElementById('resetView').addEventListener('click', () => {
            this.viz.time = 0;
            this.viz.motionEnergy = 0;
            this.viz.quaternion = new Quaternion(0, 0, 0, 1);
        });

        // Pause/resume
        document.getElementById('pauseAnimation').addEventListener('click', (e) => {
            this.viz.paused = !this.viz.paused;
            e.target.textContent = this.viz.paused ? '▶️ Resume' : '⏸ Pause';
        });

        this.updateGeometryButtons();
    }

    updateGeometryButtons() {
        document.querySelectorAll('.geometry-btn').forEach((btn, index) => {
            btn.classList.toggle('active', index === this.viz.currentGeometry);
        });
    }

    updateUI() {
        // FPS and frame time
        document.getElementById('fps').textContent = `${this.viz.fps} FPS`;
        document.getElementById('frameTime').textContent = `${this.viz.frameTime.toFixed(1)}ms`;

        // Current geometry
        document.getElementById('currentGeometry').textContent =
            `${this.viz.currentGeometry + 1}/24`;

        // Rotation speed
        document.getElementById('speedValue').textContent =
            `${this.viz.rotationSpeed.toFixed(1)}x`;

        // Motion energy
        const energyPercent = (this.viz.motionEnergy * 100).toFixed(1);
        document.getElementById('energyValue').textContent = `${energyPercent}%`;
        document.getElementById('energyBar').style.width = `${energyPercent}%`;

        // 4D rotations
        document.getElementById('rot4dXY').textContent = this.viz.rot4d.XY.toFixed(3);
        document.getElementById('rot4dXZ').textContent = this.viz.rot4d.XZ.toFixed(3);
        document.getElementById('rot4dYZ').textContent = this.viz.rot4d.YZ.toFixed(3);
        document.getElementById('rot4dXW').textContent = this.viz.rot4d.XW.toFixed(3);
        document.getElementById('rot4dYW').textContent = this.viz.rot4d.YW.toFixed(3);
        document.getElementById('rot4dZW').textContent = this.viz.rot4d.ZW.toFixed(3);

        // Quaternion state
        document.getElementById('qx').textContent = this.viz.quaternion.x.toFixed(3);
        document.getElementById('qy').textContent = this.viz.quaternion.y.toFixed(3);
        document.getElementById('qz').textContent = this.viz.quaternion.z.toFixed(3);
        document.getElementById('qw').textContent = this.viz.quaternion.w.toFixed(3);

        // Euler angles
        const euler = this.viz.quaternion.toEuler();
        const toDeg = (rad) => (rad * 180 / Math.PI).toFixed(1);
        document.getElementById('eulerRoll').textContent = `${toDeg(euler.roll)}°`;
        document.getElementById('eulerPitch').textContent = `${toDeg(euler.pitch)}°`;
        document.getElementById('eulerYaw').textContent = `${toDeg(euler.yaw)}°`;
    }
}

// ============================================================================
// Main Application
// ============================================================================

const canvas = document.getElementById('canvas');
const viz = new Visualization(canvas);
const ui = new UIController(viz);

// Animation loop
function animate() {
    viz.updateQuaternion();
    viz.render();
    ui.updateUI();
    requestAnimationFrame(animate);
}

animate();

console.log('🌀 VIB34D XR Quaternion SDK Demo');
console.log('Interactive quaternion-driven 4D visualization active');
console.log('Adjust controls in the sidebar to explore the geometry');
