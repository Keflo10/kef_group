import 'package:flutter/material.dart';
import 'package:sales_app/pages/auth/login.dart';
import 'core/constants/colors.dart';

void main() {
  runApp(const PesaTrack());
}

class PesaTrack extends StatelessWidget {
  const PesaTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,

        fontFamily: "Poppins",
      ),

      home: LoginScreen(),
    );
  }
}
