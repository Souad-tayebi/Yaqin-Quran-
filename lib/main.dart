import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/audio_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.yaqinquaran.channel',
    androidNotificationChannelName: 'Yaqin Quran Playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AudioPlayerService.instance.init();
  runApp(const SecureAudioApp());
}

// ── App-wide color tokens ──────────────────────────────────────────────────
class AppColors {
  static const darkGreen  = Color(0xFF12231D);
  static const deepTeal   = Color(0xFF005047);
  static const lightTeal  = Color(0xFF9ECDC3);
  static const accent     = Color(0xFFD6E264);
  static const background = Color(0xFFF2F8F6);
  static const card       = Colors.white;
  static const divider    = Color(0xFFDDEDE9);
}

class SecureAudioApp extends StatelessWidget {
  const SecureAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yaqin Quran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary:    AppColors.deepTeal,
          secondary:  AppColors.lightTeal,
          tertiary:   AppColors.accent,
          surface:    AppColors.card,
          onPrimary:  Colors.white,
          onSurface:  AppColors.darkGreen,
        ),
        cardColor: AppColors.card,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.deepTeal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 14),
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightTeal),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightTeal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.deepTeal, width: 2),
          ),
          labelStyle:
              const TextStyle(color: AppColors.deepTeal),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.lightTeal.withOpacity(0.4),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
                color: AppColors.darkGreen, fontWeight: FontWeight.w600),
          ),
        ),
        dividerColor: AppColors.divider,
      ),
      home: const SplashScreen(),
    );
  }
}

