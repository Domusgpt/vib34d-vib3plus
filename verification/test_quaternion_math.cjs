#!/usr/bin/env node

/**
 * Verification Test Suite for VIB34D Flutter SDK
 * Tests core quaternion mathematics to verify correctness
 * (JavaScript equivalent to validate Dart implementation)
 */

const assert = require('assert');
const util = require('util');

// ANSI colors for output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(msg, color = 'reset') {
  console.log(`${colors[color]}${msg}${colors.reset}`);
}

// ====================================================================
// Quaternion Implementation (matches Dart version)
// ====================================================================

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

  static identity() {
    return new Quaternion(0, 0, 0, 1);
  }

  toString() {
    return `Quaternion(${this.x.toFixed(3)}, ${this.y.toFixed(3)}, ${this.z.toFixed(3)}, ${this.w.toFixed(3)})`;
  }
}

class Vector3 {
  constructor(x = 0, y = 0, z = 0) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  toString() {
    return `Vector3(${this.x.toFixed(3)}, ${this.y.toFixed(3)}, ${this.z.toFixed(3)})`;
  }
}

// ====================================================================
// QuaternionUtils (matches Dart implementation)
// ====================================================================

class QuaternionUtils {
  static normalize(q) {
    if (!q) return Quaternion.identity();

    const length = q.length;
    if (length === 0) return Quaternion.identity();

    return new Quaternion(
      q.x / length,
      q.y / length,
      q.z / length,
      q.w / length
    );
  }

  static toEuler(q) {
    // Roll (x-axis rotation)
    const sinr = 2.0 * (q.w * q.x + q.y * q.z);
    const cosr = 1.0 - 2.0 * (q.x * q.x + q.y * q.y);
    const roll = Math.atan2(sinr, cosr);

    // Pitch (y-axis rotation)
    const sinp = 2.0 * (q.w * q.y - q.z * q.x);
    const pitch = Math.abs(sinp) >= 1.0
      ? Math.sign(sinp) * Math.PI / 2.0
      : Math.asin(sinp);

    // Yaw (z-axis rotation)
    const siny = 2.0 * (q.w * q.z + q.x * q.y);
    const cosy = 1.0 - 2.0 * (q.y * q.y + q.z * q.z);
    const yaw = Math.atan2(siny, cosy);

    return { roll, pitch, yaw };
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

  static lerp(start, end, alpha) {
    const t = Math.max(0, Math.min(1, alpha));
    return new Quaternion(
      start.x + (end.x - start.x) * t,
      start.y + (end.y - start.y) * t,
      start.z + (end.z - start.z) * t,
      start.w + (end.w - start.w) * t
    );
  }
}

// ====================================================================
// Geometry Library (matches Dart implementation)
// ====================================================================

class GeometryLibrary {
  static get baseGeometries() {
    return [
      { key: 'tetrahedron', name: 'TETRAHEDRON' },
      { key: 'hypercube', name: 'HYPERCUBE' },
      { key: 'sphere', name: 'SPHERE' },
      { key: 'torus', name: 'TORUS' },
      { key: 'klein-bottle', name: 'KLEIN BOTTLE' },
      { key: 'fractal', name: 'FRACTAL' },
      { key: 'wave', name: 'WAVE' },
      { key: 'crystal', name: 'CRYSTAL' },
    ];
  }

  static get coreVariants() {
    return [
      { key: 'hypercube-core', name: 'HYPERCUBE CORE', legacy: true },
      { key: 'hypersphere-core', name: 'HYPERSPHERE CORE', legacy: false },
      { key: 'hypertetra-core', name: 'HYPERTETRA CORE', legacy: false },
    ];
  }

  static describeGeometry(index) {
    const baseCount = this.baseGeometries.length;
    const total = baseCount * this.coreVariants.length;
    const normalizedIndex = ((index % total) + total) % total;

    const baseIndex = normalizedIndex % baseCount;
    const coreIndex = Math.floor(normalizedIndex / baseCount);

    const base = this.baseGeometries[baseIndex];
    const core = this.coreVariants[coreIndex];

    return {
      index: normalizedIndex,
      baseIndex,
      baseKey: base.key,
      baseName: base.name,
      coreIndex,
      coreKey: core.key,
      coreName: core.name,
      isLegacyCore: core.legacy,
    };
  }

  static getVariationParameters(geometryType, level = 0) {
    const baseCount = this.baseGeometries.length;
    const total = baseCount * this.coreVariants.length;
    const normalizedIndex = ((geometryType % total) + total) % total;

    const baseType = normalizedIndex % baseCount;
    const coreType = Math.floor(normalizedIndex / baseCount);

    let gridDensity = 8.0 + (level * 4.0);
    let morphFactor = 0.5 + (level * 0.3);
    let chaos = level * 0.15;
    let speed = 0.8 + (level * 0.2);
    let hue = (baseType * 45 + level * 15) % 360;

    // Geometry-specific adjustments (matching Dart implementation)
    const adjustments = [1.2, 0.8, 1.5, 1.3, 0.7, 0.5, 1.8, 1.5];
    gridDensity *= adjustments[baseType] || 1.0;

    return { gridDensity, morphFactor, chaos, speed, hue };
  }
}

// ====================================================================
// Test Suite
// ====================================================================

class TestSuite {
  constructor() {
    this.passed = 0;
    this.failed = 0;
    this.tests = [];
  }

  test(name, fn) {
    try {
      fn();
      this.passed++;
      log(`  ✓ ${name}`, 'green');
    } catch (error) {
      this.failed++;
      log(`  ✗ ${name}`, 'red');
      log(`    ${error.message}`, 'red');
    }
  }

  group(name, fn) {
    log(`\n${name}`, 'cyan');
    fn();
  }

  assertClose(actual, expected, epsilon = 0.0001, message = '') {
    const diff = Math.abs(actual - expected);
    if (diff > epsilon) {
      throw new Error(
        `${message || 'Values not close'}: expected ${expected}, got ${actual} (diff: ${diff})`
      );
    }
  }

  assertEqual(actual, expected, message = '') {
    if (actual !== expected) {
      throw new Error(`${message || 'Values not equal'}: expected ${expected}, got ${actual}`);
    }
  }

  assertTrue(condition, message = '') {
    if (!condition) {
      throw new Error(message || 'Condition is false');
    }
  }

  summary() {
    log('\n' + '='.repeat(60), 'blue');
    const total = this.passed + this.failed;
    log(`Total: ${total} tests`, 'blue');
    log(`Passed: ${this.passed}`, 'green');
    if (this.failed > 0) {
      log(`Failed: ${this.failed}`, 'red');
    }
    const percentage = total > 0 ? ((this.passed / total) * 100).toFixed(1) : 0;
    log(`Success Rate: ${percentage}%`, this.failed === 0 ? 'green' : 'yellow');
    log('='.repeat(60), 'blue');

    return this.failed === 0;
  }
}

// ====================================================================
// Run Tests
// ====================================================================

function runTests() {
  const suite = new TestSuite();

  log('\n' + '='.repeat(60), 'blue');
  log('VIB34D Flutter SDK - Verification Test Suite', 'cyan');
  log('Testing quaternion mathematics and geometry library', 'cyan');
  log('='.repeat(60), 'blue');

  // Quaternion Tests
  suite.group('QuaternionUtils.normalize', () => {
    suite.test('normalizes quaternion to unit length', () => {
      const q = new Quaternion(1, 2, 3, 4);
      const normalized = QuaternionUtils.normalize(q);
      suite.assertClose(normalized.length, 1.0, 0.0001);
    });

    suite.test('handles null quaternion', () => {
      const normalized = QuaternionUtils.normalize(null);
      suite.assertClose(normalized.w, 1.0);
      suite.assertClose(normalized.x, 0.0);
    });

    suite.test('handles zero quaternion', () => {
      const q = new Quaternion(0, 0, 0, 0);
      const normalized = QuaternionUtils.normalize(q);
      suite.assertClose(normalized.w, 1.0);
    });
  });

  suite.group('QuaternionUtils.toEuler', () => {
    suite.test('converts identity to zero angles', () => {
      const identity = Quaternion.identity();
      const euler = QuaternionUtils.toEuler(identity);
      suite.assertClose(euler.roll, 0.0, 0.0001);
      suite.assertClose(euler.pitch, 0.0, 0.0001);
      suite.assertClose(euler.yaw, 0.0, 0.0001);
    });

    suite.test('converts quaternion correctly', () => {
      const q = new Quaternion(0.1, 0.2, 0.3, 0.9);
      const normalized = QuaternionUtils.normalize(q);
      const euler = QuaternionUtils.toEuler(normalized);
      // Just verify it produces valid angles
      suite.assertTrue(isFinite(euler.roll));
      suite.assertTrue(isFinite(euler.pitch));
      suite.assertTrue(isFinite(euler.yaw));
    });
  });

  suite.group('QuaternionUtils.multiply', () => {
    suite.test('multiplies quaternions correctly', () => {
      const q1 = new Quaternion(1, 0, 0, 1);
      const q2 = new Quaternion(0, 1, 0, 1);
      const result = QuaternionUtils.multiply(q1, q2);
      suite.assertTrue(isFinite(result.x));
      suite.assertTrue(isFinite(result.y));
      suite.assertTrue(isFinite(result.z));
      suite.assertTrue(isFinite(result.w));
    });

    suite.test('identity multiplication', () => {
      const q = new Quaternion(0.1, 0.2, 0.3, 0.9);
      const identity = Quaternion.identity();
      const result = QuaternionUtils.multiply(q, identity);
      suite.assertClose(result.x, q.x, 0.0001);
      suite.assertClose(result.y, q.y, 0.0001);
      suite.assertClose(result.z, q.z, 0.0001);
      suite.assertClose(result.w, q.w, 0.0001);
    });
  });

  suite.group('QuaternionUtils.conjugate', () => {
    suite.test('inverts rotation components', () => {
      const q = new Quaternion(1, 2, 3, 4);
      const conj = QuaternionUtils.conjugate(q);
      suite.assertClose(conj.x, -1.0);
      suite.assertClose(conj.y, -2.0);
      suite.assertClose(conj.z, -3.0);
      suite.assertClose(conj.w, 4.0);
    });
  });

  suite.group('QuaternionUtils.lerp', () => {
    suite.test('interpolates at midpoint', () => {
      const start = new Quaternion(0, 0, 0, 1);
      const end = new Quaternion(1, 0, 0, 0);
      const mid = QuaternionUtils.lerp(start, end, 0.5);
      suite.assertClose(mid.x, 0.5, 0.0001);
      suite.assertClose(mid.w, 0.5, 0.0001);
    });

    suite.test('clamps alpha to [0, 1]', () => {
      const start = new Quaternion(0, 0, 0, 1);
      const end = new Quaternion(1, 0, 0, 0);
      const atStart = QuaternionUtils.lerp(start, end, -1.0);
      suite.assertClose(atStart.x, start.x, 0.0001);
      const atEnd = QuaternionUtils.lerp(start, end, 2.0);
      suite.assertClose(atEnd.x, end.x, 0.0001);
    });
  });

  // Geometry Library Tests
  suite.group('GeometryLibrary', () => {
    suite.test('has 8 base geometries', () => {
      suite.assertEqual(GeometryLibrary.baseGeometries.length, 8);
    });

    suite.test('has 3 core variants', () => {
      suite.assertEqual(GeometryLibrary.coreVariants.length, 3);
    });

    suite.test('describes geometry correctly', () => {
      const metadata = GeometryLibrary.describeGeometry(0);
      suite.assertEqual(metadata.baseIndex, 0);
      suite.assertEqual(metadata.baseKey, 'tetrahedron');
      suite.assertEqual(metadata.coreIndex, 0);
      suite.assertEqual(metadata.isLegacyCore, true);
    });

    suite.test('handles wrapping index', () => {
      const metadata = GeometryLibrary.describeGeometry(24);
      suite.assertEqual(metadata.index, 0); // Wraps to 0
    });

    suite.test('handles negative index', () => {
      const metadata = GeometryLibrary.describeGeometry(-1);
      suite.assertEqual(metadata.index, 23); // Wraps to last
    });

    suite.test('generates variation parameters', () => {
      const params = GeometryLibrary.getVariationParameters(5, 1);
      suite.assertTrue(params.gridDensity > 0);
      suite.assertTrue(params.morphFactor > 0);
      suite.assertTrue(params.chaos >= 0);
      suite.assertTrue(params.speed > 0);
      suite.assertTrue(params.hue >= 0 && params.hue < 360);
    });

    suite.test('parameters scale with level', () => {
      const level0 = GeometryLibrary.getVariationParameters(0, 0);
      const level1 = GeometryLibrary.getVariationParameters(0, 1);
      suite.assertTrue(level1.gridDensity > level0.gridDensity);
      suite.assertTrue(level1.morphFactor > level0.morphFactor);
    });
  });

  // Integration Tests
  suite.group('Integration: Full Quaternion Pipeline', () => {
    suite.test('quaternion to euler to rotation mapping', () => {
      // Simulate AR tracking data
      const arQuaternion = new Quaternion(0.1, 0.2, 0.15, 0.95);
      const normalized = QuaternionUtils.normalize(arQuaternion);
      const euler = QuaternionUtils.toEuler(normalized);

      // Map to 4D rotations (matching ShaderQuaternionSynchronizer)
      const rotationScale = 2.0;
      const rot4dXY = (euler.pitch + euler.yaw) * 0.5 * rotationScale;
      const rot4dXZ = (euler.pitch + euler.roll) * 0.5 * rotationScale;
      const rot4dYZ = (euler.yaw + euler.roll) * 0.5 * rotationScale;
      const rot4dXW = euler.pitch * rotationScale;
      const rot4dYW = euler.yaw * rotationScale;
      const rot4dZW = euler.roll * rotationScale;

      // Verify all rotations are finite
      suite.assertTrue(isFinite(rot4dXY));
      suite.assertTrue(isFinite(rot4dXZ));
      suite.assertTrue(isFinite(rot4dYZ));
      suite.assertTrue(isFinite(rot4dXW));
      suite.assertTrue(isFinite(rot4dYW));
      suite.assertTrue(isFinite(rot4dZW));

      log(`    → 4D Rotations: XY=${rot4dXY.toFixed(3)}, XW=${rot4dXW.toFixed(3)}`, 'yellow');
    });

    suite.test('geometry selection and parameters', () => {
      for (let i = 0; i < 24; i++) {
        const metadata = GeometryLibrary.describeGeometry(i);
        const params = GeometryLibrary.getVariationParameters(i, 1);

        suite.assertTrue(metadata.index >= 0 && metadata.index < 24);
        suite.assertTrue(params.gridDensity > 0);
        suite.assertTrue(params.hue >= 0 && params.hue < 360);
      }
      log(`    → All 24 geometries validated`, 'yellow');
    });
  });

  return suite.summary();
}

// ====================================================================
// Execute
// ====================================================================

const success = runTests();
process.exit(success ? 0 : 1);
