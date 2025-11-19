/// VIB3 Geometry Library
/// 8 geometric types with 4D polytopal mathematics integration
///
/// Provides geometry definitions, encoding/decoding, and variation parameters
/// for 4D polytope visualization systems

/// Base geometry types
class BaseGeometry {
  final String key;
  final String name;

  const BaseGeometry({required this.key, required this.name});
}

/// Core variant types (4D polytopes)
class CoreVariant {
  final String key;
  final String name;
  final String suffix;
  final bool legacy;

  const CoreVariant({
    required this.key,
    required this.name,
    this.suffix = '',
    this.legacy = false,
  });
}

/// Geometry metadata descriptor
class GeometryMetadata {
  final int index;
  final String name;
  final int baseIndex;
  final String baseKey;
  final String baseName;
  final int coreIndex;
  final String coreKey;
  final String coreName;
  final bool isLegacyCore;

  const GeometryMetadata({
    required this.index,
    required this.name,
    required this.baseIndex,
    required this.baseKey,
    required this.baseName,
    required this.coreIndex,
    required this.coreKey,
    required this.coreName,
    required this.isLegacyCore,
  });

  @override
  String toString() => 'GeometryMetadata($name, base: $baseName, core: $coreName)';
}

/// Variation parameters for geometry rendering
class VariationParameters {
  final double gridDensity;
  final double morphFactor;
  final double chaos;
  final double speed;
  final double hue;

  const VariationParameters({
    required this.gridDensity,
    required this.morphFactor,
    required this.chaos,
    required this.speed,
    required this.hue,
  });

  @override
  String toString() =>
      'VariationParameters(grid: $gridDensity, morph: $morphFactor, chaos: $chaos, speed: $speed, hue: $hue)';
}

/// Geometry library for 4D polytope systems
class GeometryLibrary {
  /// 8 base geometric types
  static const List<BaseGeometry> baseGeometries = [
    BaseGeometry(key: 'tetrahedron', name: 'TETRAHEDRON'),
    BaseGeometry(key: 'hypercube', name: 'HYPERCUBE'),
    BaseGeometry(key: 'sphere', name: 'SPHERE'),
    BaseGeometry(key: 'torus', name: 'TORUS'),
    BaseGeometry(key: 'klein-bottle', name: 'KLEIN BOTTLE'),
    BaseGeometry(key: 'fractal', name: 'FRACTAL'),
    BaseGeometry(key: 'wave', name: 'WAVE'),
    BaseGeometry(key: 'crystal', name: 'CRYSTAL'),
  ];

  /// 3 core 4D polytope variants
  static const List<CoreVariant> coreVariants = [
    CoreVariant(
      key: 'hypercube-core',
      name: 'HYPERCUBE CORE',
      suffix: '',
      legacy: true,
    ),
    CoreVariant(key: 'hypersphere-core', name: 'HYPERSPHERE CORE'),
    CoreVariant(key: 'hypertetra-core', name: 'HYPERTETRA CORE'),
  ];

  static final Map<String, int> _baseIndexByKey = {
    for (var i = 0; i < baseGeometries.length; i++)
      baseGeometries[i].key: i,
  };

  static final Map<String, int> _coreIndexByKey = {
    for (var i = 0; i < coreVariants.length; i++)
      coreVariants[i].key: i,
  };

  /// Get base geometry index from key
  static int? baseIndexFromKey(String? key) {
    if (key == null) return null;
    final lower = key.trim().toLowerCase();
    return _baseIndexByKey[key] ?? _baseIndexByKey[lower];
  }

  /// Get core variant index from key
  static int? coreIndexFromKey(String? key) {
    if (key == null) return null;
    final lower = key.trim().toLowerCase();
    return _coreIndexByKey[key] ?? _coreIndexByKey[lower];
  }

  /// Normalize geometry index to valid range
  static int? normalizeGeometryIndex(int? index) {
    if (index == null) return null;
    final total = baseGeometries.length * coreVariants.length;
    if (total == 0) return null;
    return ((index % total) + total) % total;
  }

  /// Encode base and core indices into combined geometry index
  static int? encodeGeometryIndex(int baseIndex, [int coreIndex = 0]) {
    final baseCount = baseGeometries.length;
    final coreCount = coreVariants.length;

    if (baseCount == 0 || coreCount == 0) return null;
    if (baseIndex < 0 || baseIndex >= baseCount) return null;
    if (coreIndex < 0 || coreIndex >= coreCount) return null;

    return coreIndex * baseCount + baseIndex;
  }

  /// Resolve geometry index from various criteria
  static int? resolveGeometryIndex({
    int? geometry,
    int? baseIndex,
    String? baseKey,
    int? coreIndex,
    String? coreKey,
  }) {
    if (geometry != null) {
      return normalizeGeometryIndex(geometry);
    }

    int? resolvedBase = baseIndex ?? baseIndexFromKey(baseKey);
    if (resolvedBase == null) return null;

    int resolvedCore = coreIndex ?? coreIndexFromKey(coreKey) ?? 0;

    return encodeGeometryIndex(resolvedBase, resolvedCore);
  }

  /// Get all geometry names (24 total)
  static List<String> getGeometryNames() {
    final hypersphere = baseGeometries
        .map((g) => '${g.name} • ${coreVariants[1].name}')
        .toList();
    final hypertetra = baseGeometries
        .map((g) => '${g.name} • ${coreVariants[2].name}')
        .toList();

    return [
      ...baseGeometries.map((g) => g.name),
      ...hypersphere,
      ...hypertetra,
    ];
  }

  /// Get geometry name by index
  static String getGeometryName(int type) {
    final names = getGeometryNames();
    return (type >= 0 && type < names.length) ? names[type] : 'UNKNOWN';
  }

  /// Describe geometry by index
  static GeometryMetadata? describeGeometry(int index) {
    final baseCount = baseGeometries.length;
    if (baseCount == 0) return null;

    final total = baseCount * coreVariants.length;
    final normalizedIndex = ((index % total) + total) % total;

    final baseIndex = normalizedIndex % baseCount;
    final coreIndex = normalizedIndex ~/ baseCount;

    final base = baseGeometries[baseIndex];
    final core = coreVariants[coreIndex];

    return GeometryMetadata(
      index: normalizedIndex,
      name: getGeometryName(normalizedIndex),
      baseIndex: baseIndex,
      baseKey: base.key,
      baseName: base.name,
      coreIndex: coreIndex,
      coreKey: core.key,
      coreName: core.name,
      isLegacyCore: core.legacy,
    );
  }

  /// Describe geometry by component criteria
  static GeometryMetadata? describeByComponents({
    int? geometry,
    int? baseIndex,
    String? baseKey,
    int? coreIndex,
    String? coreKey,
  }) {
    final index = resolveGeometryIndex(
      geometry: geometry,
      baseIndex: baseIndex,
      baseKey: baseKey,
      coreIndex: coreIndex,
      coreKey: coreKey,
    );

    return index != null ? describeGeometry(index) : null;
  }

  /// List all geometry metadata (24 entries)
  static List<GeometryMetadata> listGeometryMetadata() {
    final total = baseGeometries.length * coreVariants.length;
    return List.generate(
      total,
      (index) => describeGeometry(index)!,
    );
  }

  /// Get variation parameters for specific geometry and level
  static VariationParameters getVariationParameters(
    int geometryType, [
    int level = 0,
  ]) {
    final baseCount = baseGeometries.length;
    if (baseCount == 0) {
      return const VariationParameters(
        gridDensity: 8.0,
        morphFactor: 0.5,
        chaos: 0.0,
        speed: 0.8,
        hue: 0.0,
      );
    }

    final total = baseCount * coreVariants.length;
    final normalizedIndex = ((geometryType % total) + total) % total;

    final baseType = normalizedIndex % baseCount;
    final coreType = normalizedIndex ~/ baseCount;

    double gridDensity = 8.0 + (level * 4.0);
    double morphFactor = 0.5 + (level * 0.3);
    double chaos = level * 0.15;
    double speed = 0.8 + (level * 0.2);
    double hue = ((baseType * 45 + level * 15) % 360).toDouble();

    // Geometry-specific adjustments
    switch (baseType) {
      case 0: // Tetrahedron
        gridDensity *= 1.2;
        break;
      case 1: // Hypercube
        morphFactor *= 0.8;
        break;
      case 2: // Sphere
        chaos *= 1.5;
        break;
      case 3: // Torus
        speed *= 1.3;
        break;
      case 4: // Klein Bottle
        gridDensity *= 0.7;
        morphFactor *= 1.4;
        break;
      case 5: // Fractal
        gridDensity *= 0.5;
        chaos *= 2.0;
        break;
      case 6: // Wave
        speed *= 1.8;
        chaos *= 0.5;
        break;
      case 7: // Crystal
        gridDensity *= 1.5;
        morphFactor *= 0.6;
        break;
    }

    // Core-specific adjustments
    if (coreType == 1) {
      // Hypersphere
      gridDensity *= 1.1;
      morphFactor *= 1.25;
      chaos *= 1.2;
      speed *= 0.95;
    } else if (coreType == 2) {
      // Hypertetra
      gridDensity *= 0.95;
      morphFactor *= 1.35;
      chaos *= 1.15;
      speed *= 1.1;
    }

    return VariationParameters(
      gridDensity: gridDensity,
      morphFactor: morphFactor,
      chaos: chaos,
      speed: speed,
      hue: hue,
    );
  }
}
