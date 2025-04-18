import 'package:flutter/material.dart';
import 'package:secure_share/pages/HomePageNavigator.dart';
import '../database/database_helper.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_container.dart';
import '../utils/navigation.dart';

class ChangePasswordPage extends StatefulWidget {
  final String username;
  final VoidCallback toggleTheme;

  const ChangePasswordPage({
    super.key,
    required this.username,
    required this.toggleTheme,
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final passwordController = TextEditingController();
  String get currentUser => widget.username;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GradientContainer(
          colors:
              Theme.of(context).brightness == Brightness.light
                  ? [const Color(0xFFF7FBFF), const Color(0xFFEFF5FF)]
                  : [const Color(0xFF1A2A44), const Color(0xFF2A3A5A)],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 50),
              const Text(
                "Change Your Password",
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              GradientContainer(
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
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Enter a new password",
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        labelText: 'New Password',
                        hintText: 'Enter your new password',
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
                            final newPassword = passwordController.text.trim();
                            if (newPassword.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password cannot be empty',
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
                              return;
                            }
                            if (newPassword.length > 50) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password too long',
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
                              return;
                            }
                            try {
                              bool updated = await DatabaseHelper.instance
                                  .updatePassword(widget.username, newPassword);
                              if (updated) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password updated successfully!',
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
                                passwordController.clear();
                                navigateTo(
                                  context,
                                  HomeNavigator(toggleTheme: widget.toggleTheme, username: currentUser,),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to update password',
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
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error updating password: $e',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 1),
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
                            "Update Password",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'WorkSans',
                            ),
                          ),
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
}
