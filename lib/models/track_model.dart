class TrackModel {
  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final String audioUrl;
  final String? imageUrl;
  final int? durationSeconds;

  TrackModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.audioUrl,
    this.imageUrl,
    this.durationSeconds,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'audioUrl': audioUrl,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  factory TrackModel.fromMap(Map<String, dynamic> map) => TrackModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        categoryId: map['categoryId'] ?? '',
        categoryName: map['categoryName'] ?? '',
        audioUrl: map['audioUrl'] ?? '',
        imageUrl: map['imageUrl'],
      );
}
