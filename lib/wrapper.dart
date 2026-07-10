import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_app/pages/auth/login.dart';
import 'package:sales_app/pages/home/home_screen.dart';
import 'package:sales_app/services/auth_service.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        // If the snapshot has data, the user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          // Otherwise, the user is not logged in
          return const LoginScreen();
        }
      },
    );
  }
}
