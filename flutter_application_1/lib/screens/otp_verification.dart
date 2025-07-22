import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/create_new_password.dart';
import '../services/api_service.dart';

// screen for OTP verification
class OTPVerificationScreen extends StatefulWidget {
  final String email;
  const OTPVerificationScreen({super.key, required this.email});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  // controller for the OTP text field
  final _otpController = TextEditingController();
  // key for form validation
  final _formKey = GlobalKey<FormState>();
  // loading state flag
  bool _isLoading = false;

  @override
  void dispose() {
    // clean up controller
    _otpController.dispose();
    super.dispose();
  }

  // handle the "Verify OTP" button press
  Future<void> _handleVerifyOTP() async {
    // validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // call API to verify OTP
      final response = await ApiService.verifyOtp(
        email: widget.email,
        otp: _otpController.text,
      );
      if (mounted) {
        if (response['success'] == true) {
          // navigate to create new password screen on success
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewPasswordScreen(email: widget.email, otp: _otpController.text),
            ),
          );
        } else {
          // show error message on failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['message'] ?? 'Invalid OTP'}'),
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
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('An OTP has been sent to ${widget.email}. Please enter it below.'),
              const SizedBox(height: 20),
              // OTP text field
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.length < 4) {
                    return 'Please enter the 4-digit OTP';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),
              // verify OTP button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOTP,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 