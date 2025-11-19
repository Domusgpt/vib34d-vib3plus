import 'package:flutter_test/flutter_test.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

void main() {
  group('GeometryLibrary', () {
    test('has 8 base geometries', () {
      expect(GeometryLibrary.baseGeometries.length, equals(8));
    });

    test('has 3 core variants', () {
      expect(GeometryLibrary.coreVariants.length, equals(3));
    });

    test('baseIndexFromKey returns correct index', () {
      expect(GeometryLibrary.baseIndexFromKey('tetrahedron'), equals(0));
      expect(GeometryLibrary.baseIndexFromKey('hypercube'), equals(1));
      expect(GeometryLibrary.baseIndexFromKey('sphere'), equals(2));
      expect(GeometryLibrary.baseIndexFromKey('crystal'), equals(7));
    });

    test('baseIndexFromKey is case-insensitive', () {
      expect(GeometryLibrary.baseIndexFromKey('TETRAHEDRON'), equals(0));
      expect(GeometryLibrary.baseIndexFromKey('Hypercube'), equals(1));
    });

    test('coreIndexFromKey returns correct index', () {
      expect(GeometryLibrary.coreIndexFromKey('hypercube-core'), equals(0));
      expect(GeometryLibrary.coreIndexFromKey('hypersphere-core'), equals(1));
      expect(GeometryLibrary.coreIndexFromKey('hypertetra-core'), equals(2));
    });

    test('normalizeGeometryIndex handles negative values', () {
      final result = GeometryLibrary.normalizeGeometryIndex(-1);
      expect(result, equals(23)); // Wraps to last geometry
    });

    test('normalizeGeometryIndex handles values beyond range', () {
      final result = GeometryLibrary.normalizeGeometryIndex(24);
      expect(result, equals(0)); // Wraps to first geometry
    });

    test('encodeGeometryIndex combines base and core correctly', () {
      // First base, first core
      expect(GeometryLibrary.encodeGeometryIndex(0, 0), equals(0));

      // Second base, first core
      expect(GeometryLibrary.encodeGeometryIndex(1, 0), equals(1));

      // First base, second core
      expect(GeometryLibrary.encodeGeometryIndex(0, 1), equals(8));

      // Last base, last core
      expect(GeometryLibrary.encodeGeometryIndex(7, 2), equals(23));
    });

    test('resolveGeometryIndex works with geometry parameter', () {
      final result = GeometryLibrary.resolveGeometryIndex(geometry: 5);
      expect(result, equals(5));
    });

    test('resolveGeometryIndex works with baseKey and coreKey', () {
      final result = GeometryLibrary.resolveGeometryIndex(
        baseKey: 'sphere',
        coreKey: 'hypersphere-core',
      );
      expect(result, equals(10)); // sphere (2) + hypersphere core (1) * 8
    });

    test('getGeometryNames returns 24 entries', () {
      final names = GeometryLibrary.getGeometryNames();
      expect(names.length, equals(24));
    });

    test('getGeometryName returns correct name', () {
      expect(GeometryLibrary.getGeometryName(0), equals('TETRAHEDRON'));
      expect(GeometryLibrary.getGeometryName(1), equals('HYPERCUBE'));
    });

    test('describeGeometry returns complete metadata', () {
      final metadata = GeometryLibrary.describeGeometry(0);
      expect(metadata, isNotNull);
      expect(metadata!.index, equals(0));
      expect(metadata.baseIndex, equals(0));
      expect(metadata.baseKey, equals('tetrahedron'));
      expect(metadata.coreIndex, equals(0));
      expect(metadata.coreKey, equals('hypercube-core'));
      expect(metadata.isLegacyCore, isTrue);
    });

    test('describeByComponents works correctly', () {
      final metadata = GeometryLibrary.describeByComponents(
        baseKey: 'torus',
        coreKey: 'hypertetra-core',
      );
      expect(metadata, isNotNull);
      expect(metadata!.baseKey, equals('torus'));
      expect(metadata.coreKey, equals('hypertetra-core'));
    });

    test('listGeometryMetadata returns 24 entries', () {
      final list = GeometryLibrary.listGeometryMetadata();
      expect(list.length, equals(24));
      expect(list[0].index, equals(0));
      expect(list[23].index, equals(23));
    });

    test('getVariationParameters returns valid parameters', () {
      final params = GeometryLibrary.getVariationParameters(0, 0);
      expect(params.gridDensity, greaterThan(0));
      expect(params.morphFactor, greaterThan(0));
      expect(params.chaos, greaterThanOrEqualTo(0));
      expect(params.speed, greaterThan(0));
      expect(params.hue, greaterThanOrEqualTo(0));
      expect(params.hue, lessThan(360));
    });

    test('getVariationParameters scales with level', () {
      final level0 = GeometryLibrary.getVariationParameters(0, 0);
      final level1 = GeometryLibrary.getVariationParameters(0, 1);
      final level2 = GeometryLibrary.getVariationParameters(0, 2);

      expect(level1.gridDensity, greaterThan(level0.gridDensity));
      expect(level2.gridDensity, greaterThan(level1.gridDensity));
      expect(level1.morphFactor, greaterThan(level0.morphFactor));
    });
  });
}
