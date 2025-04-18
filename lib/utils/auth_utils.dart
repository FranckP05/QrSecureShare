import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../database/database_helper.dart';

class AuthResult {
  final bool success;
  final bool requiresPasswordChange;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.requiresPasswordChange = false,
    this.errorMessage,
  });
}

Future<AuthResult> authenticateUser({
  required String username,
  String? password,
  bool forgotPassword = false,
  bool useFingerprint = false,
}) async {
  try {
    if (username.isEmpty) {
      return AuthResult(success: false, errorMessage: 'Username cannot be empty');
    }

    if (useFingerprint || forgotPassword) {
      bool exists = await DatabaseHelper.instance.checkUsernameExists(username);
      if (!exists) {
        return AuthResult(success: false, errorMessage: 'Username not found');
      }

      if (useFingerprint) {
        final localAuth = LocalAuthentication();
        bool canCheckBiometrics = await localAuth.canCheckBiometrics;
        bool isDeviceSupported = await localAuth.isDeviceSupported();
        if (!canCheckBiometrics || !isDeviceSupported) {
          return AuthResult(success: false, errorMessage: 'Fingerprint authentication not supported');
        }

        bool authenticated = await localAuth.authenticate(
          localizedReason: 'Scan your fingerprint to log in',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (!authenticated) {
          return AuthResult(success: false, errorMessage: 'Fingerprint authentication failed');
        }

        await DatabaseHelper.instance.setForcePasswordChange(username, true);
        return AuthResult(success: true, requiresPasswordChange: true);
      }
    }

    if (password == null || password.isEmpty) {
      return AuthResult(success: false, errorMessage: 'Password cannot be empty');
    }
    bool isAuthenticated = await DatabaseHelper.instance.authenticateUser(username, password);
    if (!isAuthenticated) {
      return AuthResult(success: false, errorMessage: 'Invalid username or password');
    }
    bool requiresChange = await DatabaseHelper.instance.getUserForcePasswordChange(username);
    return AuthResult(success: true, requiresPasswordChange: requiresChange);
  } catch (e) {
    return AuthResult(success: false, errorMessage: 'Authentication error: $e');
  }
}