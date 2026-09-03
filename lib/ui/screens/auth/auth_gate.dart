import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/main.dart';
import 'package:rawang_melodies/viewmodels/auth_view_model.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    if (!auth.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.isLoggedIn) {
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
