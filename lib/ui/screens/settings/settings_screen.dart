import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/ui/screens/auth/login_screen.dart';
import 'package:rawang_melodies/viewmodels/auth_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  bool _showPw = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    super.dispose();
  }

  String _planLabel(SubscriptionPlan p) {
    switch (p) {
      case SubscriptionPlan.oneMonth:
        return '1 Month';
      case SubscriptionPlan.threeMonths:
        return '3 Months';
      case SubscriptionPlan.oneYear:
        return '1 Year';
      default:
        return 'Free 4 years';
    }
  }

  String _formatExpiry(int ms) {
    try {
      return DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(ms));
    } catch (_) {
      return '—';
    }
  }

  Future<void> _contactAdmin() async {
    final uri = Uri.parse('tel:+95900000000');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _changePassword() async {
    if (_oldCtrl.text.length < 6 || _newCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords must be >=6 chars'), backgroundColor: Colors.red));
      return;
    }
    try {
      await context.read<AuthViewModel>().changePassword(_oldCtrl.text, _newCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed'), backgroundColor: Colors.green));
      _oldCtrl.clear();
      _newCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red.shade700));
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You will need to login again to access favorites.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout'))],
      ),
    );
    if (ok != true) return;
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    final user = auth.currentUser;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Account, subscription & heritage', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        // Profile card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))]),
          child: user == null
              ? Column(
                  children: [
                    Icon(Icons.account_circle, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    const Text('Not logged in', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const Text('Login to save favorites & offline', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Login'),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginScreen(onLoginSuccess: () => Navigator.of(context).pop(), onGuest: () => Navigator.of(context).pop()))),
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: theme.colorScheme.primary, child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w800, fontSize: 22))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                              Text(user.phone, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                              if (user.email != null) Text(user.email!, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: user.isSubscriptionActive ? Colors.green.shade600 : Colors.orange.shade600, borderRadius: BorderRadius.circular(20)),
                          child: Text(user.isSubscriptionActive ? 'Active' : 'Expired', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.card_membership, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('Plan: ${_planLabel(user.subscriptionPlan)}', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      const Spacer(),
                      Text(_formatExpiry(user.subscriptionExpiresAt), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 6),
                    Text('Role: ${user.role.name}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    if (user.mustChangePassword) ...[
                      const SizedBox(height: 8),
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)), child: Row(children: [Icon(Icons.warning_amber, size: 16, color: Colors.orange.shade700), const SizedBox(width: 6), Expanded(child: Text('Please change your temporary password', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)))])),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 16),
        // Subscription info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary), const SizedBox(width: 6), Text('Subscription', style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface))]),
              const SizedBox(height: 6),
              const Text('Free for 3-4 years for ~1000 users. After that 1m/3m/1y paid via bank transfer - admin activates in portal.', style: TextStyle(fontSize: 12, height: 1.4)),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(icon: const Icon(Icons.support_agent, size: 18), label: const Text('Contact admin to renew'), onPressed: _contactAdmin, style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Change password (only when logged in)
        if (user != null) ...[
          Text('Change password', style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06))),
            child: Column(
              children: [
                TextField(controller: _oldCtrl, obscureText: !_showPw, decoration: InputDecoration(labelText: 'Old password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_showPw ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showPw = !_showPw)))),
                const SizedBox(height: 10),
                TextField(controller: _newCtrl, obscureText: !_showPw, decoration: const InputDecoration(labelText: 'New password', prefixIcon: Icon(Icons.lock))),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(onPressed: auth.isLoading ? null : _changePassword, style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: auth.isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update password')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _logout,
            ),
          ),
        ] else ...[
          // Guest also can login from settings
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(icon: const Icon(Icons.login), label: const Text('Go to Login'), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginScreen(onLoginSuccess: () => Navigator.of(context).pop(), onGuest: () => Navigator.of(context).pop()))), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          ),
        ],
        const SizedBox(height: 12),
        Center(child: Text('Rawang Melodies • heritage preservation', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant))),
      ],
    );
  }
}
