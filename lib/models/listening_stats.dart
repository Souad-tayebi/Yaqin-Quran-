class ListeningStats {
  final String trackId;
  final String trackTitle;
  final String userId;
  final DateTime timestamp;
  final int durationSeconds;

  ListeningStats({
    required this.trackId,
    required this.trackTitle,
    required this.userId,
    required this.timestamp,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() => {
        'trackId': trackId,
        'trackTitle': trackTitle,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
        'durationSeconds': durationSeconds,
      };

  factory ListeningStats.fromMap(Map<String, dynamic> map) => ListeningStats(
        trackId: map['trackId'] ?? '',
        trackTitle: map['trackTitle'] ?? '',
        userId: map['userId'] ?? '',
        timestamp: DateTime.parse(map['timestamp']),
        durationSeconds: map['durationSeconds'] ?? 0,
      );
}
