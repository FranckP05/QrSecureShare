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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GradientContainer(
          colors:
              Theme.of(context).brightness == Brightness.light
                  ? [const Color(0xFFE6F0FA), const Color(0xFFD1E3FF)]
                  : [const Color(0xFF1A2A44), const Color(0xFF2A3A5A)],
          child: Column(
            children: [
              // Top section with Lottie animation and toggle button
              SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                    0.48, 
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
              // Bottom section with form
              Expanded(
                child: GradientContainer(
                  colors:
                    Theme.of(context).brightness == Brightness.light
                        ? [const Color(0xFF2178dd), const Color(0xFF020344)]
                        : [const Color(0xFF1A3A6A), const Color(0xFF010A2A)],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
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
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Username cannot be empty'
                                      : null,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          obscureText: true,
                          validator:
                              (value) =>
                                  value!.isEmpty
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
                          
                              // Input validation
                              if (username.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Username cannot be empty!',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                return;
                              }
                              if (password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password cannot be empty!',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                return;
                              }
                              if (username.length > 50 ||
                                  password.length > 50) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Username or password too long!',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                return;
                              }
                          
                              try {
                                bool userCreated = await DatabaseHelper.instance
                                    .createUser(username, password);
                                if (userCreated) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Account created successfully!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      backgroundColor: Colors.greenAccent,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  usernameController.clear();
                                  passwordController.clear();
                                  navigateTo(
                                    context,
                                    HomeNavigator(toggleTheme: toggleTheme, username: username,),
                                  ); // Fixed to HomePage
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'User already exists, move to login!',
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Signup error: $e'); // Already present
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Error creating account. Please try again.',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF032153),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
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
                          onPressed:
                              () => navigateTo(
                                context,
                                Login(toggleTheme: toggleTheme),
                              ),
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
