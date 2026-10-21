import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listening_stats.dart';

class StatsService {
  static final _db = FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  static CollectionReference get _col =>
      _db.collection('listening_stats').doc(_uid).collection('records');

  /// Record a listening session for the current user.
  static Future<void> recordListening({
    required String trackId,
    required String trackTitle,
    required int durationSeconds,
  }) async {
    if (_uid.isEmpty || durationSeconds < 5) return;
    await _col.add(ListeningStats(
      trackId: trackId,
      trackTitle: trackTitle,
      userId: _uid,
      timestamp: DateTime.now(),
      durationSeconds: durationSeconds,
    ).toMap());
  }

  /// Returns all records for the current calendar month.
  static Future<List<ListeningStats>> _monthRecords() async {
    if (_uid.isEmpty) return [];
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    try {
      final snap = await _col
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .get();
      return snap.docs
          .map((d) => ListeningStats.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// {day → totalMinutes} for every day of the current month (days with 0 included).
  static Future<Map<int, int>> dailyMinutesThisMonth() async {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final map = {for (int d = 1; d <= daysInMonth; d++) d: 0};

    for (final s in await _monthRecords()) {
      final day = s.timestamp.day;
      map[day] = (map[day] ?? 0) + (s.durationSeconds ~/ 60);
    }
    return map;
  }

  /// Total listening seconds this month.
  static Future<int> totalSecondsThisMonth() async {
    final records = await _monthRecords();
    return records.fold<int>(0, (acc, s) => acc + s.durationSeconds);
  }

  /// Top-5 most-listened tracks this month → {title: totalSeconds}.
  static Future<Map<String, int>> topTracksThisMonth() async {
    final records = await _monthRecords();
    final map = <String, int>{};
    for (final s in records) {
      map[s.trackTitle] = (map[s.trackTitle] ?? 0) + s.durationSeconds;
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }
}
