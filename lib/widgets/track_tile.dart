import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../services/favorites_service.dart';
import '../services/audio_player_service.dart';
import '../main.dart';

class TrackTile extends StatefulWidget {
  final TrackModel  track;
  final VoidCallback? onTap;
  const TrackTile({super.key, required this.track, this.onTap});
  @override
  State<TrackTile> createState() => _TrackTileState();
}

class _TrackTileState extends State<TrackTile> {
  bool _isFav      = false;
  bool _checkingFav = true;
  bool _toggling   = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
    AudioPlayerService.instance.player.playerStateStream
        .listen((_) { if (mounted) setState(() {}); });
  }

  Future<void> _checkFav() async {
    final f = await FavoritesService.isFavorite(widget.track.id);
    if (mounted) setState(() { _isFav = f; _checkingFav = false; });
  }

  Future<void> _toggleFav() async {
    if (_toggling) return;
    setState(() => _toggling = true);
    final newVal = !_isFav;
    setState(() => _isFav = newVal);
    try {
      if (newVal) {
        await FavoritesService.addFavorite(widget.track);
      } else {
        await FavoritesService.removeFavorite(widget.track.id);
      }
    } catch (_) {
      // Revert on failure
      if (mounted) setState(() => _isFav = !newVal);
    }
    if (mounted) setState(() => _toggling = false);
  }

  bool get _isPlaying =>
      AudioPlayerService.instance.currentTrack?.id == widget.track.id &&
      AudioPlayerService.instance.player.playing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 32, vertical: 2),
      leading: Icon(
        _isPlaying ? Icons.equalizer : Icons.music_note_outlined,
        color: _isPlaying ? AppColors.accent : AppColors.deepTeal,
        size: 22),
      title: Text(widget.track.title,
          style: TextStyle(
            color: _isPlaying ? AppColors.deepTeal : AppColors.darkGreen,
            fontWeight: _isPlaying ? FontWeight.bold : FontWeight.normal,
            fontSize: 14),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _checkingFav || _toggling
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(
                  color: AppColors.deepTeal, strokeWidth: 2))
          : IconButton(
              icon: Icon(
                _isFav ? Icons.favorite : Icons.favorite_border,
                color: _isFav ? Colors.pinkAccent : AppColors.lightTeal,
                size: 22),
              onPressed: _toggleFav),
      onTap: widget.onTap,
    );
  }
}
