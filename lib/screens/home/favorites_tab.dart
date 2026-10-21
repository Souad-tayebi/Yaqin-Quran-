import 'package:flutter/material.dart';
import '../../models/track_model.dart';
import '../../services/favorites_service.dart';
import '../../services/biometric_service.dart';
import '../../services/audio_player_service.dart';
import '../../main.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrackModel>>(
      stream: FavoritesService.favoritesStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
              color: AppColors.deepTeal));
        }

        final favorites = snap.data ?? [];

        if (favorites.isEmpty) {
          return Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightTeal.withOpacity(0.3),
                ),
                child: const Icon(Icons.favorite_outline,
                    size: 48, color: AppColors.deepTeal),
              ),
              const SizedBox(height: 20),
              const Text('No favorites yet',
                  style: TextStyle(color: AppColors.darkGreen,
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Tap ♥ on any track to add it here',
                  style: TextStyle(color: AppColors.deepTeal, fontSize: 14)),
            ],
          ));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 12, bottom: 120),
          itemCount: favorites.length,
          separatorBuilder: (_, __) =>
              const Divider(color: AppColors.divider, height: 1),
          itemBuilder: (context, i) =>
              _FavoriteTile(track: favorites[i]),
        );
      },
    );
  }
}

class _FavoriteTile extends StatefulWidget {
  final TrackModel track;
  const _FavoriteTile({required this.track});
  @override
  State<_FavoriteTile> createState() => _FavoriteTileState();
}

class _FavoriteTileState extends State<_FavoriteTile> {
  bool _deleting = false;

  Future<void> _delete() async {
    setState(() => _deleting = true);

    final ok = await BiometricService.authenticate(
        reason: 'Authenticate to remove "${widget.track.title}" from favorites');

    if (!mounted) return;

    if (!ok) {
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Authentication required to remove favorites.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    await FavoritesService.removeFavorite(widget.track.id);
    if (mounted) {
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('"${widget.track.title}" removed from favorites'),
        backgroundColor: AppColors.deepTeal,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.deepTeal,
        ),
        child: const Icon(Icons.music_note, color: Colors.white, size: 22),
      ),
      title: Text(widget.track.title,
          style: const TextStyle(color: AppColors.darkGreen,
              fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(widget.track.categoryName,
          style: const TextStyle(
              color: AppColors.deepTeal, fontSize: 12)),
      trailing: _deleting
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(
                  color: AppColors.deepTeal, strokeWidth: 2))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.play_circle_filled,
                    color: AppColors.deepTeal, size: 30),
                onPressed: () => AudioPlayerService.instance
                    .playTrack(widget.track, [widget.track]),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 22),
                tooltip: 'Remove (requires Face ID)',
                onPressed: _delete,
              ),
            ]),
    );
  }
}
