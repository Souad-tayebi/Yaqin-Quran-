import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/track_model.dart';
import 'stats_service.dart';

/// Singleton audio player service with background playback support.
class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  final AudioPlayer player = AudioPlayer();

  TrackModel? _currentTrack;
  List<TrackModel> _playlist = [];
  int _currentIndex = 0;
  DateTime? _playStart;
  bool _isRepeat = false;

  TrackModel? get currentTrack => _currentTrack;
  bool get isRepeat => _isRepeat;
  List<TrackModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  void init() {
    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && !_isRepeat) {
        _saveStats();
        _autoPlayNext();
      }
    });
  }

  Future<void> playTrack(TrackModel track, List<TrackModel> playlist) async {
    _saveStats();
    _currentTrack = track;
    _playlist = playlist;
    _currentIndex = playlist.indexWhere((t) => t.id == track.id);
    _playStart = DateTime.now();

    try {
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(track.audioUrl),
          tag: MediaItem(
            id: track.id,
            title: track.title,
            album: track.categoryName,
            artUri: Uri.parse(
              'https://via.placeholder.com/300/6C63FF/FFFFFF?text=SA',
            ),
          ),
        ),
      );
      await player.play();
    } catch (e) {
      // ignore: avoid_print
      print('AudioPlayerService play error: $e');
    }
  }

  Future<void> togglePlayPause() async {
    player.playing ? await player.pause() : await player.play();
  }

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    _saveStats();
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await playTrack(_playlist[_currentIndex], _playlist);
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    _saveStats();
    _currentIndex =
        (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await playTrack(_playlist[_currentIndex], _playlist);
  }

  Future<void> toggleRepeat() async {
    _isRepeat = !_isRepeat;
    await player.setLoopMode(_isRepeat ? LoopMode.one : LoopMode.off);
  }

  void _autoPlayNext() {
    if (_playlist.isNotEmpty) {
      playNext();
    }
  }

  void _saveStats() {
    if (_currentTrack != null && _playStart != null) {
      final secs = DateTime.now().difference(_playStart!).inSeconds;
      StatsService.recordListening(
        trackId: _currentTrack!.id,
        trackTitle: _currentTrack!.title,
        durationSeconds: secs,
      );
      _playStart = null;
    }
  }

  void dispose() {
    _saveStats();
    player.dispose();
  }
}
