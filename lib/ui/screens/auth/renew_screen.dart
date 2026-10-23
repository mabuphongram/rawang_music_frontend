import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/ui/components/auth_background.dart';
import 'package:rawang_melodies/ui/components/glass_auth.dart';
import 'package:rawang_melodies/ui/components/support_contact.dart';
import 'package:rawang_melodies/viewmodels/auth_view_model.dart';

/// Shown when access expired beyond the grace period.
/// Neutral by design: status + support contact only, no payment language.
class RenewScreen extends StatelessWidget {
  const RenewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final expiry = user == null
        ? '—'
        : DateFormat.yMMMd().format(
            DateTime.fromMillisecondsSinceEpoch(user.subscriptionExpiresAt),
          );

    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 56),
              const Text(
                'Access expired',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your free access ended on $expiry.',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'What to do',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Contact support and mention your registered phone number. Support will help restore your access.',
                      style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: contactSupport,
                        icon: const Icon(Icons.support_agent),
                        label: const Text('Contact support'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      supportEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.read<AuthViewModel>().logout(),
                      child: const Text(
                        'Log out',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Your downloads still play offline.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
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
