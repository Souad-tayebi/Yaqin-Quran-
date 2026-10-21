import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import '../main.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});
  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with SingleTickerProviderStateMixin {
  final _sfx   = AudioPlayer();
  late AnimationController _pulse;

  String _status    = 'Authenticate with Face ID or Touch ID';
  bool   _loading   = true;
  bool   _failed    = false;
  bool   _noFinger  = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
        lowerBound: 0.88,
        upperBound: 1.0)
      ..repeat(reverse: true);
    _run();
  }

  Future<void> _run() async {
    setState(() { _loading = true; _failed = false; _noFinger = false; });

    final available = await BiometricService.isAvailable();
    if (!available) { _proceed(); return; }

    final enrolled = await BiometricService.hasEnrolledBiometrics();
    if (!enrolled) {
      setState(() {
        _noFinger = true; _loading = false;
        _status = 'No Face ID / Touch ID enrolled.\n'
            'Go to Settings → Face ID & Passcode to set it up.';
      });
      return;
    }

    final ok = await BiometricService.authenticate(
        reason: 'Authenticate to access Yaqin Quran');
    if (ok) {
      try { await _sfx.play(AssetSource('sounds/success.mp3')); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 600));
      _proceed();
    } else {
      setState(() {
        _failed = true; _loading = false;
        _status = 'Authentication failed. Tap below to retry.';
      });
    }
  }

  void _proceed() {
    if (!mounted) return;
    final user = AuthService.currentUser;
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (_) =>
                user != null ? const HomeScreen() : const LoginScreen()));
  }

  @override
  void dispose() { _pulse.dispose(); _sfx.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/ayat_yaqin.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 6),
                const Text('Yaqin Quran',
                    style: TextStyle(color: AppColors.darkGreen,
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 56),

                // Fingerprint / Face ID icon
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) => Transform.scale(
                    scale: _loading ? _pulse.value : 1.0, child: child),
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(
                        color: (_failed
                            ? Colors.red
                            : AppColors.deepTeal).withOpacity(0.25),
                        blurRadius: 30, spreadRadius: 6,
                      )],
                    ),
                    child: Icon(Icons.fingerprint, size: 90,
                      color: _failed  ? Colors.red
                           : _noFinger? Colors.orange
                           : AppColors.deepTeal),
                  ),
                ),
                const SizedBox(height: 36),

                Text(_status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 16, height: 1.5)),
                const SizedBox(height: 36),

                if (_loading)
                  const CircularProgressIndicator(color: AppColors.deepTeal),

                if (_failed)
                  ElevatedButton.icon(
                      onPressed: _run,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again')),

                if (_noFinger) ...[
                  ElevatedButton.icon(
                      onPressed: BiometricService.openBiometricSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text('Open Settings')),
                  const SizedBox(height: 12),
                  TextButton(
                      onPressed: _run,
                      child: const Text('Try Again',
                          style: TextStyle(color: AppColors.deepTeal))),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
