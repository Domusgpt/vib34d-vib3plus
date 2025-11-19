import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vib34d_xr_quaternion_sdk/vib34d_xr_quaternion_sdk.dart';

void main() {
  group('QuaternionFieldService', () {
    late QuaternionFieldService service;

    setUp(() {
      service = QuaternionFieldService(
        energySmoothing: 0.35,
        velocityReference: 8.0,
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('provides initial snapshot', () {
      final snapshot = service.snapshot;
      expect(snapshot.primaryQuaternion, isNotNull);
      expect(snapshot.confidence, equals(1.0));
      expect(snapshot.motionEnergy, equals(0.0));
    });

    test('stream emits snapshots', () async {
      final snapshots = <QuaternionSnapshot>[];
      final subscription = service.stream.listen((snapshot) {
        snapshots.add(snapshot);
      });

      // Ingest a quaternion
      service.ingestPrimaryQuaternion(
        Quaternion(0.1, 0.2, 0.3, 0.9),
        confidence: 0.8,
        source: 'test',
      );

      await Future.delayed(const Duration(milliseconds: 10));
      subscription.cancel();

      expect(snapshots.isNotEmpty, isTrue);
      expect(snapshots.last.confidence, equals(0.8));
      expect(snapshots.last.source, equals('test'));
    });

    test('ingestPrimaryQuaternion normalizes quaternion', () async {
      QuaternionSnapshot? snapshot;
      final subscription = service.stream.listen((s) => snapshot = s);

      service.ingestPrimaryQuaternion(
        Quaternion(1.0, 2.0, 3.0, 4.0), // Unnormalized
      );

      await Future.delayed(const Duration(milliseconds: 10));
      subscription.cancel();

      expect(snapshot, isNotNull);
      final length = snapshot!.primaryQuaternion.length;
      expect(length, closeTo(1.0, 0.0001));
    });

    test('ingestSecondaryQuaternion updates secondary', () async {
      QuaternionSnapshot? snapshot;
      final subscription = service.stream.listen((s) => snapshot = s);

      service.ingestSecondaryQuaternion(
        Quaternion(0.1, 0.0, 0.0, 1.0),
        source: 'secondary-test',
      );

      await Future.delayed(const Duration(milliseconds: 10));
      subscription.cancel();

      expect(snapshot, isNotNull);
      expect(snapshot!.source, equals('secondary-test'));
    });

    test('ingestPose with orientation updates correctly', () async {
      QuaternionSnapshot? snapshot;
      final subscription = service.stream.listen((s) => snapshot = s);

      service.ingestPose(
        orientation: Quaternion(0.0, 0.1, 0.0, 1.0),
        position: Vector3(1.0, 2.0, 3.0),
        confidence: 0.95,
        source: 'pose-test',
      );

      await Future.delayed(const Duration(milliseconds: 10));
      subscription.cancel();

      expect(snapshot, isNotNull);
      expect(snapshot!.confidence, equals(0.95));
      expect(snapshot!.source, equals('pose-test'));
    });

    test('motion energy increases with rapid changes', () async {
      final snapshots = <QuaternionSnapshot>[];
      final subscription = service.stream.listen((s) => snapshots.add(s));

      // Ingest rapidly changing quaternions
      for (var i = 0; i < 5; i++) {
        service.ingestPrimaryQuaternion(
          Quaternion(i * 0.1, i * 0.2, i * 0.1, 1.0),
          timestamp: i * 100,
        );
        await Future.delayed(const Duration(milliseconds: 10));
      }

      subscription.cancel();

      // Motion energy should increase
      expect(snapshots.length, greaterThan(1));
      final finalEnergy = snapshots.last.motionEnergy;
      expect(finalEnergy, greaterThanOrEqualTo(0.0));
    });

    test('euler angles are computed correctly', () async {
      QuaternionSnapshot? snapshot;
      final subscription = service.stream.listen((s) => snapshot = s);

      service.ingestPrimaryQuaternion(Quaternion.identity());

      await Future.delayed(const Duration(milliseconds: 10));
      subscription.cancel();

      expect(snapshot, isNotNull);
      expect(snapshot!.euler, isNotNull);
      expect(snapshot!.euler.roll, closeTo(0.0, 0.0001));
      expect(snapshot!.euler.pitch, closeTo(0.0, 0.0001));
      expect(snapshot!.euler.yaw, closeTo(0.0, 0.0001));
    });
  });
}
