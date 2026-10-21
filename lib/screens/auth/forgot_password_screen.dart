import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../main.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool   _loading  = false;
  String? _message;
  bool   _success  = false;

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _message = 'Please enter a valid email.');
      return;
    }
    setState(() { _loading = true; _message = null; });
    final err = await AuthService.resetPassword(email);
    if (!mounted) return;
    setState(() {
      _loading = false; _success = err == null;
      _message = err ?? 'A reset link has been sent to $email.\nCheck your inbox.';
    });
  }

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 72, height: 72,
              margin: const EdgeInsets.only(bottom: 20),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.deepTeal),
              child: const Icon(Icons.lock_reset,
                  size: 36, color: AppColors.accent),
            ),
            const Text('Reset Password',
                style: TextStyle(color: AppColors.darkGreen,
                    fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text(
              "Enter the email address linked to your account and we'll send a reset link.",
              style: TextStyle(color: AppColors.deepTeal, height: 1.5),
              textAlign: TextAlign.center),
            const SizedBox(height: 36),

            if (_message != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (_success
                      ? Colors.green.shade50 : Colors.red.shade50),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _success
                      ? Colors.green.shade300 : Colors.red.shade300),
                ),
                child: Text(_message!,
                    style: TextStyle(height: 1.5,
                        color: _success
                            ? Colors.green.shade800 : Colors.red.shade700)),
              ),
              const SizedBox(height: 20),
            ],

            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.darkGreen),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.deepTeal)),
            ),
            const SizedBox(height: 28),

            _loading
                ? const Center(child: CircularProgressIndicator(
                    color: AppColors.deepTeal))
                : ElevatedButton(
                    onPressed: _success ? null : _send,
                    child: const Text('Send Reset Link')),

            if (_success) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Sign In',
                    style: TextStyle(color: AppColors.deepTeal))),
            ],
          ],
        ),
      ),
    );
  }
}
