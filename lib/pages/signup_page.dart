import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:secure_share/pages/HomePageNavigator.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_container.dart';
import '../utils/navigation.dart';
import 'login_page.dart';
import "package:secure_share/database/database_helper.dart";

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key, required this.toggleTheme});
  final VoidCallback toggleTheme;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void showCustomSnackBar(
      BuildContext context, String message, Color bgColor, Color textColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GradientContainer(
          colors: isDark
              ? [const Color(0xFF1A2A44), const Color(0xFF2A3A5A)]
              : [const Color(0xFFE6F0FA), const Color(0xFFD1E3FF)],
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.48,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/welcome.json',
                          width: double.infinity,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ThemeToggleButton(toggleTheme: toggleTheme),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GradientContainer(
                  colors: isDark
                      ? [const Color(0xFF1A3A6A), const Color(0xFF010A2A)]
                      : [const Color(0xFF2178dd), const Color(0xFF020344)],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Let's Go!",
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          controller: usernameController,
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          validator: (value) => value!.isEmpty
                              ? 'Username cannot be empty'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          obscureText: true,
                          validator: (value) => value!.isEmpty
                              ? 'Password cannot be empty'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final username = usernameController.text.trim();
                              final password = passwordController.text.trim();

                              if (username.isEmpty) {
                                showCustomSnackBar(
                                  context,
                                  'Username cannot be empty!',
                                  Colors.redAccent,
                                  isDark ? Colors.black : Colors.white,
                                );
                                return;
                              }

                              if (password.isEmpty) {
                                showCustomSnackBar(
                                  context,
                                  'Password cannot be empty!',
                                  Colors.redAccent,
                                  isDark ? Colors.black : Colors.white,
                                );
                                return;
                              }

                              if (username.length > 50 ||
                                  password.length > 50) {
                                showCustomSnackBar(
                                  context,
                                  'Username or password too long!',
                                  Colors.redAccent,
                                  isDark ? Colors.black : Colors.white,
                                );
                                return;
                              }

                              try {
                                bool userCreated = await DatabaseHelper.instance
                                    .createUser(username, password);
                                if (userCreated) {
                                  showCustomSnackBar(
                                    context,
                                    'Account created successfully!',
                                    Colors.green,
                                    Colors.white,
                                  );
                                  usernameController.clear();
                                  passwordController.clear();
                                  navigateTo(
                                      context,
                                      HomeNavigator(
                                          toggleTheme: toggleTheme,
                                          username: username));
                                } else {
                                  showCustomSnackBar(
                                    context,
                                    'User already exists, move to login!',
                                    Colors.amber,
                                    Colors.black,
                                  );
                                }
                              } catch (e) {
                                showCustomSnackBar(
                                  context,
                                  'Error creating account. Please try again.',
                                  Colors.red,
                                  Colors.white,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF032153),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'WorkSans',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => navigateTo(
                              context, Login(toggleTheme: toggleTheme)),
                          child: const Text(
                            "Already have an account? Sign In",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
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
