import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/colors.dart';
import 'wrapper.dart';

// main() to be async
void main() async {
  //  Required to ensure plugin services are initialized before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Then we Initialize Firebase using the generated firebase_options.dart file
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PesaTrack());
}

class PesaTrack extends StatelessWidget {
  const PesaTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const Wrapper(),
    );
  }
}
