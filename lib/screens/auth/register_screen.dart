import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import '../../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  DateTime? _dob;
  bool   _loading = false;
  bool   _obscure = true;
  String? _error;

  @override
  void dispose() {
    for (final c in [_firstNameCtrl, _lastNameCtrl,
                     _emailCtrl, _passCtrl, _confirmCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 16),
      firstDate: DateTime(1920), lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.deepTeal)),
        child: child!),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  int _age(DateTime d) {
    final n = DateTime.now();
    int a = n.year - d.year;
    if (n.month < d.month || (n.month == d.month && n.day < d.day)) a--;
    return a;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) { setState(() => _error = 'Please select your date of birth.'); return; }
    if (_age(_dob!) < 13) { setState(() => _error = 'You must be at least 13 years old.'); return; }
    setState(() { _loading = true; _error = null; });
    final err = await AuthService.signUp(
      email: _emailCtrl.text.trim(), password: _passCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName:  _lastNameCtrl.text.trim(),
      dateOfBirth: _dob!,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    }
  }

  Widget _field({required TextEditingController ctrl, required String label,
      required IconData icon, TextInputType type = TextInputType.text,
      bool obscure = false, Widget? suffix,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl, obscureText: obscure, keyboardType: type,
      style: const TextStyle(color: AppColors.darkGreen),
      decoration: InputDecoration(labelText: label,
          prefixIcon: Icon(icon, color: AppColors.deepTeal),
          suffixIcon: suffix),
      validator: validator,
    );
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create Account',
                    style: TextStyle(color: AppColors.darkGreen,
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Fill in the fields below to get started',
                    style: TextStyle(color: AppColors.deepTeal, fontSize: 14)),
                const SizedBox(height: 28),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(_error!,
                        style: TextStyle(color: Colors.red.shade700)),
                  ),
                  const SizedBox(height: 16),
                ],

                _field(ctrl: _firstNameCtrl, label: 'First Name *',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required' : null),
                const SizedBox(height: 14),
                _field(ctrl: _lastNameCtrl, label: 'Last Name *',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required' : null),
                const SizedBox(height: 14),

                // Date picker
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightTeal),
                    ),
                    child: Row(children: [
                      const Icon(Icons.cake_outlined, color: AppColors.deepTeal),
                      const SizedBox(width: 16),
                      Text(
                        _dob == null ? 'Date of Birth *'
                            : DateFormat('dd / MM / yyyy').format(_dob!),
                        style: TextStyle(
                          color: _dob == null
                              ? AppColors.deepTeal : AppColors.darkGreen,
                          fontSize: 16),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),

                _field(ctrl: _emailCtrl, label: 'Email *',
                    icon: Icons.email_outlined,
                    type: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email' : null),
                const SizedBox(height: 14),

                _field(ctrl: _passCtrl, label: 'Password *',
                    icon: Icons.lock_outline, obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                          color: AppColors.deepTeal),
                      onPressed: () => setState(() => _obscure = !_obscure)),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Min 6 characters' : null),
                const SizedBox(height: 14),

                _field(ctrl: _confirmCtrl, label: 'Confirm Password *',
                    icon: Icons.lock_outline, obscure: _obscure,
                    validator: (v) =>
                        v != _passCtrl.text ? 'Passwords do not match' : null),
                const SizedBox(height: 28),

                _loading
                    ? const Center(child: CircularProgressIndicator(
                        color: AppColors.deepTeal))
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Create Account')),
                const SizedBox(height: 24),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: AppColors.darkGreen)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen())),
                    child: const Text('Sign In',
                        style: TextStyle(color: AppColors.deepTeal,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
