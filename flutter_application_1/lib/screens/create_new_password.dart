import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'sign_in.dart';

// screen for creating new password
class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const CreateNewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  // key for validation
  final _formKey = GlobalKey<FormState>();
  // controllers for text fields
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // status flags
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isNewPasswordValid = false;
  bool _doPasswordsMatch = false;
  // password requirements text
  static const String passwordRequirement =
      'Password must be at least 8 characters, include uppercase, lowercase, number, and special character.';

  @override
  void initState() {
    super.initState();
    // to validate password
    _passwordController.addListener(_validateNewPassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  // to check if new password is valid
  void _validateNewPassword() {
    final password = _passwordController.text;
    setState(() {
      _isNewPasswordValid = _isPasswordValid(password);
      _doPasswordsMatch = password == _confirmPasswordController.text && password.isNotEmpty;
    });
  }

  // check if password matched
  void _validateConfirmPassword() {
    setState(() {
      _doPasswordsMatch = _passwordController.text == _confirmPasswordController.text && _passwordController.text.isNotEmpty;
    });
  }

  // password validation rules
  bool _isPasswordValid(String password) {
    return password.length >= 8 &&
        RegExp(r'(?=.*[a-z])').hasMatch(password) &&
        RegExp(r'(?=.*[A-Z])').hasMatch(password) &&
        RegExp(r'(?=.*[0-9])').hasMatch(password) &&
        RegExp(r'(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(password);
  }

  @override
  void dispose() {
    // clean up controllers
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    // validate form key
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // call API to reset passwprd
      final response = await ApiService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: _passwordController.text,
      );
      if (mounted) {
        if (response['success'] == true) {
          // display success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successful!'),
              backgroundColor: Colors.green,
            ),
          );
          // redirect to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          // display error 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter your new password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (!_isPasswordValid(value)) {
                    return 'Password does not meet requirements';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 2.0),
                child: Text(
                  passwordRequirement,
                  style: TextStyle(
                    fontSize: 12,
                    color: _isNewPasswordValid && _passwordController.text.isNotEmpty
                        ? Colors.green
                        : (_passwordController.text.isEmpty ? Colors.grey[700] : Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              if (_confirmPasswordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 2.0),
                  child: Text(
                    _doPasswordsMatch ? 'Passwords match' : 'Passwords do not match',
                    style: TextStyle(
                      fontSize: 12,
                      color: _doPasswordsMatch
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0057B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleResetPassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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