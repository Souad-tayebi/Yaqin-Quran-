import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometric hardware exists
  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Check if any biometrics are enrolled on the device
  static Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate({
    String reason = 'Verify your identity to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Biometric error: ${e.code} - ${e.message}');
      return false;
    }
  }


  static Future<void> openBiometricSettings() async {
    try {
      const platform = MethodChannel('secure_audio/settings');
      await platform.invokeMethod('openBiometricSettings');
    } catch (_) {
    }
  }
}
