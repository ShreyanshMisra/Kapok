import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';

/// Represents a live map snapshot stored in Firestore
class MapSnapshot {
  final double centerLat;
  final double centerLng;
  final int zoomMin;
  final int zoomMax;
  final double northEastLat;
  final double northEastLon;
  final double southWestLat;
  final double southWestLon;
  final DateTime lastUpdatedAt;

  MapSnapshot({
    required this.centerLat,
    required this.centerLng,
    required this.zoomMin,
    required this.zoomMax,
    required this.northEastLat,
    required this.northEastLon,
    required this.southWestLat,
    required this.southWestLon,
    required this.lastUpdatedAt,
  });

  factory MapSnapshot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MapSnapshot(
      centerLat: data['centerLat'] as double,
      centerLng: data['centerLng'] as double,
      zoomMin: data['zoomMin'] as int,
      zoomMax: data['zoomMax'] as int,
      northEastLat: data['northEastLat'] as double,
      northEastLon: data['northEastLon'] as double,
      southWestLat: data['southWestLat'] as double,
      southWestLon: data['southWestLon'] as double,
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'centerLat': centerLat,
      'centerLng': centerLng,
      'zoomMin': zoomMin,
      'zoomMax': zoomMax,
      'northEastLat': northEastLat,
      'northEastLon': northEastLon,
      'southWestLat': southWestLat,
      'southWestLon': southWestLon,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }
}

/// FirebaseMapSnapshotSource handles Firestore operations for live map snapshots
/// Whenever we download a new offline region, we also publish its metadata to Firestore
/// so other devices can snap to the same view and prewarm their caches.
class FirebaseMapSnapshotSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'mapSnapshots';

  /// Saves or updates a map snapshot for a user/team
  Future<void> saveSnapshot(String userIdOrTeamId, MapSnapshot snapshot) async {
    try {
      Logger.firebase('Saving map snapshot for: $userIdOrTeamId');
      await _firestore
          .collection(_collection)
          .doc(userIdOrTeamId)
          .set(snapshot.toFirestore());
      Logger.firebase('Map snapshot saved successfully');
    } catch (e) {
      Logger.firebase('Error saving map snapshot', error: e);
      throw DatabaseException(
        message: 'Failed to save map snapshot',
        originalError: e,
      );
    }
  }

  /// Gets a map snapshot for a user/team
  Future<MapSnapshot?> getSnapshot(String userIdOrTeamId) async {
    try {
      Logger.firebase('Getting map snapshot for: $userIdOrTeamId');
      final doc = await _firestore
          .collection(_collection)
          .doc(userIdOrTeamId)
          .get();

      if (doc.exists) {
        return MapSnapshot.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      Logger.firebase('Error getting map snapshot', error: e);
      throw DatabaseException(
        message: 'Failed to get map snapshot',
        originalError: e,
      );
    }
  }

  /// Streams map snapshot changes for a user/team
  /// This allows the map widget to automatically center when the snapshot changes
  Stream<MapSnapshot?> getSnapshotStream(String userIdOrTeamId) {
    Logger.firebase('Listening to map snapshot stream for: $userIdOrTeamId');
    return _firestore
        .collection(_collection)
        .doc(userIdOrTeamId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return MapSnapshot.fromFirestore(doc);
          }
          return null;
        });
  }

  /// Deletes a map snapshot
  Future<void> deleteSnapshot(String userIdOrTeamId) async {
    try {
      Logger.firebase('Deleting map snapshot for: $userIdOrTeamId');
      await _firestore.collection(_collection).doc(userIdOrTeamId).delete();
      Logger.firebase('Map snapshot deleted successfully');
    } catch (e) {
      Logger.firebase('Error deleting map snapshot', error: e);
      throw DatabaseException(
        message: 'Failed to delete map snapshot',
        originalError: e,
      );
    }
  }
}
