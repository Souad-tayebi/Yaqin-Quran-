import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/track_model.dart';

class FavoritesService {
  static final _db = FirebaseFirestore.instance;

  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  static DocumentReference get _userDoc =>
      _db.collection('favorites').doc(_uid);

  static CollectionReference get _col => _userDoc.collection('tracks');

  static Future<void> addFavorite(TrackModel track) async {
    if (_uid.isEmpty) return;
    try {
      await _col.doc(track.id).set(track.toMap());
    } catch (e) {
      // ignore: avoid_print
      print('addFavorite error: $e');
    }
  }

  static Future<void> removeFavorite(String trackId) async {
    if (_uid.isEmpty) return;
    try {
      await _col.doc(trackId).delete();
    } catch (e) {
      // ignore: avoid_print
      print('removeFavorite error: $e');
    }
  }

  static Future<bool> isFavorite(String trackId) async {
    if (_uid.isEmpty) return false;
    try {
      final doc = await _col.doc(trackId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Real-time stream — emits [] when user is not logged in.
  static Stream<List<TrackModel>> favoritesStream() {
    final uid = _uid;
    if (uid.isEmpty) return Stream.value([]);

    return _db
        .collection('favorites')
        .doc(uid)
        .collection('tracks')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                TrackModel.fromMap(d.data()))
            .toList())
        .handleError((_) => <TrackModel>[]);
  }
}
