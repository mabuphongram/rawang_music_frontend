import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/ui/components/auth_background.dart';
import 'package:rawang_melodies/ui/components/glass_auth.dart';
import 'package:rawang_melodies/ui/components/support_contact.dart';
import 'package:rawang_melodies/viewmodels/auth_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _message;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    try {
      final msg = await vm.forgot(_phoneCtrl.text.trim());
      setState(() => _message = msg);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green.shade700));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700));
    }
  }

  Future<void> _contactAdmin() async {
    final uri = Uri.parse('tel:+95900000000'); // TODO replace with real admin
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Row(children: [IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop())]),
              const SizedBox(height: 12),
              const Text('Forgot password', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('We will help you reset via admin', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_reset, size: 48, color: Colors.white70),
                      const SizedBox(height: 12),
                      const Text('Enter your phone', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 6),
                      const Text('Admin will reset within 24h.\nIf you added email, we can send a link.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: glassTextStyle,
                        decoration: glassInput(label: 'Phone', prefix: Icons.phone, hint: '09xxxxxxxx'),
                        validator: (v) => (v == null || v.trim().length < 7) ? 'Enter valid phone' : null,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: vm.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: vm.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Send reset request'),
                        ),
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                          child: Text(_message!, style: TextStyle(color: Colors.green.shade800, fontSize: 12)),
                        ),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _contactAdmin,
                        icon: const Icon(Icons.support_agent),
                        label: const Text('Contact Admin (09xxx)'),
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back to login'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
