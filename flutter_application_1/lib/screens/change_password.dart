import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// screen for changing password
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // controllers for text fields
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // status flags for validation
  bool _isNewPasswordValid = false;
  bool _doPasswordsMatch = false;
  bool _isLoading = false;
  String? _errorMessage;

  // for password visibility
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // password requirements 
  static const String passwordRequirement =
      'Password must be at least 8 characters, include uppercase, lowercase, number, and special character.';

  @override
  void initState() {
    super.initState();
    // to validate password
    _newPasswordController.addListener(_validateNewPassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  // check if new password is valid 
  void _validateNewPassword() {
    final password = _newPasswordController.text;
    setState(() {
      _isNewPasswordValid = _isPasswordValid(password);
      _doPasswordsMatch = password == _confirmPasswordController.text && password.isNotEmpty;
    });
  }

  // check if passwords match
  void _validateConfirmPassword() {
    setState(() {
      _doPasswordsMatch = _newPasswordController.text == _confirmPasswordController.text && _newPasswordController.text.isNotEmpty;
    });
  }

  // password validation rules
  bool _isPasswordValid(String password) {
    return password.length >= 8 &&
        RegExp(r'(?=.*[a-z])').hasMatch(password) &&    // has lowercase
        RegExp(r'(?=.*[A-Z])').hasMatch(password) &&    // has uppercase
        RegExp(r'(?=.*[0-9])').hasMatch(password) &&    // has number
        RegExp(r'(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(password);  // has special char
  }

  // handles the change password button 
  Future<void> _handleChangePassword() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // check if all fields are valid
    if (_currentPasswordController.text.isEmpty ||
        !_isNewPasswordValid ||
        !_doPasswordsMatch) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // call API to change password
      final response = await ApiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (response['success'] == true) {
        // show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.green,
            ),
          );
        }
        // clear all fields after success 
        setState(() {
          _errorMessage = null;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _isNewPasswordValid = false;
          _doPasswordsMatch = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? response.toString();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // clean up controllers
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showGreenReq = _isNewPasswordValid && _newPasswordController.text.isNotEmpty;
    final bool showGreenMatch = _doPasswordsMatch && _confirmPasswordController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0057B8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xFF0057B8),
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Current Password:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _currentPasswordController,
              obscureText: !_showCurrentPassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                errorText: _currentPasswordController.text.isEmpty ? 'Required' : null,
                suffixIcon: IconButton(
                  icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'New Password:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                errorText: null,
                suffixIcon: IconButton(
                  icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
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
                  color: showGreenReq
                      ? Colors.green
                      : (_isNewPasswordValid || _newPasswordController.text.isEmpty ? Colors.grey[700] : Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Confirm Password:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                errorText: null,
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            if (_confirmPasswordController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 2.0),
                child: Text(
                  showGreenMatch ? 'Passwords match' : 'Passwords do not match',
                  style: TextStyle(
                    fontSize: 12,
                    color: showGreenMatch ? Colors.green : Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 220,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isNewPasswordValid && _doPasswordsMatch && _currentPasswordController.text.isNotEmpty && !_isLoading)
                        ? const Color(0xFF0057B8)
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (_isNewPasswordValid && _doPasswordsMatch && _currentPasswordController.text.isNotEmpty && !_isLoading)
                      ? _handleChangePassword
                      : null,
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
                          'Change Password',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
