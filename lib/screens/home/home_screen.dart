import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/mini_player.dart';
import 'stats_tab.dart';
import 'player_tab.dart';
import 'favorites_tab.dart';
import '../biometric_screen.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _tabs = const [StatsTab(), PlayerTab(), FavoritesTab()];

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Sign Out',
            style: TextStyle(color: AppColors.darkGreen)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.deepTeal)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.deepTeal))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.signOut();
      if (mounted) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const BiometricScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deepTeal,
        title: Row(children: [
          ClipOval(
            child: Image.asset(
              'assets/ayat_yaqin.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Yaqin Quran',
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 20)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: _signOut),
        ],
      ),
      body: Column(children: [
        Expanded(child: _tabs[_index]),
        const MiniPlayer(),
      ]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.lightTeal.withOpacity(0.5),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: AppColors.deepTeal),
            selectedIcon: Icon(Icons.bar_chart, color: AppColors.deepTeal),
            label: 'Stats'),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined, color: AppColors.deepTeal),
            selectedIcon: Icon(Icons.library_music, color: AppColors.deepTeal),
            label: 'Library'),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline, color: AppColors.deepTeal),
            selectedIcon: Icon(Icons.favorite, color: AppColors.deepTeal),
            label: 'Favorites'),
        ],
      ),
    );
  }
}

