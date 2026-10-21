import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/track_model.dart';
import '../../services/api_service.dart';
import '../../services/audio_player_service.dart';
import '../../widgets/track_tile.dart';
import '../../main.dart';

class PlayerTab extends StatefulWidget {
  const PlayerTab({super.key});
  @override
  State<PlayerTab> createState() => _PlayerTabState();
}

class _PlayerTabState extends State<PlayerTab> {
  List<CategoryModel> _categories = [];
  bool   _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cats = await ApiService.fetchCategories();
      if (!mounted) return;
      setState(() { _categories = cats; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load library. Check your connection.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: Column(
        mainAxisSize: MainAxisSize.min, children: [
      CircularProgressIndicator(color: AppColors.deepTeal),
      SizedBox(height: 16),
      Text('Loading library…',
          style: TextStyle(color: AppColors.deepTeal)),
    ]));

    if (_error != null) return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off, size: 64, color: AppColors.lightTeal),
        const SizedBox(height: 16),
        Text(_error!, textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.deepTeal)),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: _load,
            icon: const Icon(Icons.refresh), label: const Text('Retry')),
      ]),
    ));

    return RefreshIndicator(
      color: AppColors.deepTeal,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 120),
        itemCount: _categories.length,
        itemBuilder: (context, i) => _CategorySection(
          category: _categories[i],
          onPlay: (track, cat) =>
              AudioPlayerService.instance.playTrack(track, cat.tracks),
        ),
      ),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final CategoryModel category;
  final void Function(TrackModel, CategoryModel) onPlay;
  const _CategorySection({required this.category, required this.onPlay});
  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.deepTeal,
                ),
                child: Center(child: Text(widget.category.id,
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 12))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.category.name,
                      style: const TextStyle(color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (widget.category.arabicName != null)
                    Text(widget.category.arabicName!,
                        style: const TextStyle(
                            color: AppColors.deepTeal, fontSize: 13)),
                ],
              )),
              Icon(_expanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
                  color: AppColors.deepTeal),
            ]),
          ),
        ),

        if (_expanded)
          Container(
            color: AppColors.lightTeal.withOpacity(0.08),
            child: Column(
              children: widget.category.tracks.map((track) => TrackTile(
                track: track,
                onTap: () => widget.onPlay(track, widget.category),
              )).toList(),
            ),
          ),

        const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
}
