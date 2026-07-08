import 'package:flutter/material.dart';
import 'package:sales_app/pages/auth/signup.dart';
import '/core/constants/colors.dart';
// import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // here we  controls whether the password is hidden
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              children: [
                // App Icon
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 90,
                ),

                const SizedBox(height: 20),

                // App Name
                const Text(
                  "Sales and expense Tracker",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 40),

                // White login card
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(24),

                    child: Column(
                      children: [
                        // Email field
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,

                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Enter your email",

                            prefixIcon: const Icon(Icons.email_outlined),

                            filled: true,
                            fillColor: Colors.grey.shade100,

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: passwordController,

                          obscureText: _obscurePassword,

                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Enter your password",

                            prefixIcon: const Icon(Icons.lock_outline),

                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),

                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),

                            filled: true,
                            fillColor: Colors.grey.shade100,

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},

                            child: const Text("Forgot Password?"),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            onPressed: () {
                              //navigate to the home page after login here
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,

                              foregroundColor: Colors.white,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),

                            child: const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Text("Don't have an account?"),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text("Sign Up"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
