import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/main.dart';
import 'package:rawang_melodies/viewmodels/auth_view_model.dart';
import 'login_screen.dart';
import 'renew_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    if (!auth.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = auth.currentUser;
    if (auth.isLoggedIn && user != null) {
      // Paywall: past the grace period, streaming stops until renewal.
      if (!user.isSubscriptionActive && !user.inGracePeriod) {
        return const RenewScreen();
      }
      return const MainScreen();
    }
    return LoginScreen(
      onLoginSuccess: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
      },
      onGuest: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
      },
    );
  }
}
