import 'track_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? arabicName;
  final List<TrackModel> tracks;

  CategoryModel({
    required this.id,
    required this.name,
    this.arabicName,
    required this.tracks,
  });
}
