import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_player_service.dart';
import '../main.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});
  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final _svc = AudioPlayerService.instance;

  @override
  void initState() {
    super.initState();
    _svc.player.playerStateStream
        .listen((_) { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    final track = _svc.currentTrack;
    if (track == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.deepTeal,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: AppColors.deepTeal.withOpacity(0.3),
          blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seek bar
          StreamBuilder<Duration?>(
            stream: _svc.player.durationStream,
            builder: (_, durSnap) => StreamBuilder<Duration>(
              stream: _svc.player.positionStream,
              builder: (_, posSnap) {
                final dur = durSnap.data ?? Duration.zero;
                final pos = posSnap.data ?? Duration.zero;
                final ratio = dur.inMilliseconds > 0
                    ? (pos.inMilliseconds / dur.inMilliseconds)
                        .clamp(0.0, 1.0)
                    : 0.0;
                return SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12),
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor:
                        Colors.white.withOpacity(0.25),
                    thumbColor: AppColors.accent,
                  ),
                  child: Slider(
                    value: ratio,
                    onChanged: (v) {
                      if (dur.inMilliseconds > 0) {
                        _svc.seek(Duration(
                            milliseconds:
                                (v * dur.inMilliseconds).toInt()));
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/ayat_yaqin.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(track.title,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(track.categoryName,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              )),

              IconButton(
                icon: const Icon(Icons.skip_previous,
                    color: Colors.white70, size: 22),
                onPressed: _svc.playPrevious,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),

              StreamBuilder<PlayerState>(
                stream: _svc.player.playerStateStream,
                builder: (_, snap) {
                  final playing = snap.data?.playing ?? false;
                  final loading = snap.data?.processingState ==
                      ProcessingState.loading;
                  return IconButton(
                    icon: loading
                        ? const SizedBox(width: 28, height: 28,
                            child: CircularProgressIndicator(
                                color: AppColors.accent, strokeWidth: 2))
                        : Icon(
                            playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: AppColors.accent, size: 36),
                    onPressed: _svc.togglePlayPause,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints());
                },
              ),

              IconButton(
                icon: const Icon(Icons.skip_next,
                    color: Colors.white70, size: 22),
                onPressed: _svc.playNext,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),

              IconButton(
                icon: Icon(Icons.repeat_one,
                    color: _svc.isRepeat
                        ? AppColors.accent : Colors.white38,
                    size: 20),
                onPressed: _svc.toggleRepeat,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),
            ]),
          ),
        ],
      ),
    );
  }
}
