import 'package:flutter/material.dart';
import 'package:secure_share/database/database_helper.dart';
import 'package:secure_share/pages/HomePageNavigator.dart';
import 'package:local_auth/local_auth.dart'; // Import for local authentication
import '../widgets/theme_toggle_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_container.dart';
import '../utils/navigation.dart';
import 'signup_page.dart';

class Login extends StatefulWidget {
  final VoidCallback toggleTheme;
  const Login({super.key, required this.toggleTheme});

  @override
  State<Login> createState() => _LoginState();
}

final userController = TextEditingController();
final passwordController = TextEditingController();

class _LoginState extends State<Login> {
  final LocalAuthentication auth = LocalAuthentication(); // LocalAuth instance

  // Method to authenticate the user with biometric authentication
  Future<bool> _authenticateWithBiometrics() async {
    try {
      bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          biometricOnly: true, // Only biometric authentication (fingerprint)
        ),
      );
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GradientContainer(
          colors: Theme.of(context).brightness == Brightness.light
              ? [const Color(0xFFF7FBFF), const Color(0xFFEFF5FF)]
              : [const Color(0xFF1A2A44), const Color(0xFF2A3A5A)],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ThemeToggleButton(toggleTheme: widget.toggleTheme),
                ),
              ),
              Image.asset(
                'assets/images/login.png',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              GradientContainer(
                colors: Theme.of(context).brightness == Brightness.light
                    ? [const Color(0xFF2178dd), const Color(0xFF020344)]
                    : [const Color(0xFF1A3A6A), const Color(0xFF010A2A)],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Sign in to your account",
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: userController,
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a valid username'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: passwordController,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        obscureText: true,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a valid password'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            String username = userController.text.trim();
                            String password = passwordController.text.trim();
                            if (username.isNotEmpty && password.isNotEmpty) {
                              try {
                                bool userAuth = await DatabaseHelper.instance
                                    .authenticateUser(username, password);
                                if (userAuth) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Login successful!',
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
                                  userController.clear();
                                  passwordController.clear();
                                  navigateTo(
                                    context,
                                    HomeNavigator(
                                      toggleTheme: widget.toggleTheme,
                                      username: username,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Your password or Username doesn't work!",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      backgroundColor: Colors.yellowAccent,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Error creating account. Please try again.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please enter both username and password",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  duration: Duration(seconds: 1),
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
                            "Sign In",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'WorkSans',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(
                              toggleTheme: widget.toggleTheme,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () async {
                          bool isAuthenticated =
                              await _authenticateWithBiometrics();
                          if (isAuthenticated) {
                            // Proceed to ask the user if they want to change their password
                            bool changePassword = await _askToChangePassword();
                            if (changePassword) {
                              // Code to update password in the database
                              // Make sure to touch the database only here
                              _updatePasswordInDatabase();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Biometric authentication failed.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Forgot your password?",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _askToChangePassword() async {
    // Show a dialog asking the user if they want to change their password
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: const Text('Do you want to change your password?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // No change
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Yes change
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _updatePasswordInDatabase() {
    // Implement the logic to update the user's password
    // in the database, only if the user chooses to change it
    // Update the password in the database
  }
}
