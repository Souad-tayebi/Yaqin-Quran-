import 'package:flutter/material.dart';
import 'biometric_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.5, end: 1.0));
    _fade  = _ctrl.drive(Tween(begin: 0.0, end: 1.0));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), _go);
  }

  void _go() {
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const BiometricScreen()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepTeal,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/ayat_yaqin.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                 ),
                ),
                const SizedBox(height: 28),
                const Text('Yaqin Quran',
                    style: TextStyle(
                        color: Colors.white, fontSize: 34,
                        fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 8),
                Text('Secure · Simple · Sound',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 14)),
                const SizedBox(height: 60),
                const CircularProgressIndicator(
                    color: AppColors.accent, strokeWidth: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
