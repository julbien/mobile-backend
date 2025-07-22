import 'package:flutter/material.dart';
import 'change_password.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

// screen for viewing and editing user profile
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // controllers for text fields
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  // flags to control editing state
  bool _isEditingUsername = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  // loading and error states
  bool _isLoading = false;
  String? _errorMessage;
  // original user data to revert changes
  late String _originalUsername;
  late String _originalEmail;
  late String _originalPhone;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    _originalUsername = '';
    _originalEmail = '';
    _originalPhone = '';
    // load user data when the screen is initialized
    _loadUserData();
  }

  // fetch and load user data into controllers
  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    setState(() {
      usernameController.text = userData['username'] ?? '';
      emailController.text = userData['email'] ?? '';
      phoneController.text = userData['phone'] ?? '';
      _originalUsername = userData['username'] ?? '';
      _originalEmail = userData['email'] ?? '';
      _originalPhone = userData['phone'] ?? '';
    });
  }

  @override
  void dispose() {
    // clean up controllers
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // show confirmation dialog before updating
  Future<bool> _showConfirmationDialog(String field, String newValue) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Do you want to update your $field to "$newValue"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0057B8)),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  // show OTP dialog (if needed for email change, currently not used)
  Future<String?> _showOtpDialog(String email) async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('An OTP has been sent to $email.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0057B8)),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  // handle saving the updated field
  Future<void> _handleSaveField(String field) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      String? username;
      String? email;
      String? phone;
      String newValue = '';
      if (field == 'username') {
        username = usernameController.text;
        newValue = username;
      }
      if (field == 'email') {
        email = emailController.text;
        newValue = email;
      }
      if (field == 'phone') {
        phone = phoneController.text;
        newValue = phone;
      }
      // show confirmation dialog
      final confirmed = await _showConfirmationDialog(field, newValue);
      if (!confirmed) {
        setState(() { _isLoading = false; });
        return;
      }
      // proceed with update by calling API
      final response = await ApiService.updateProfile(
        username: username,
        email: email,
        phone: phone,
      );
      if (response['success'] == true) {
        // save updated user data locally
        final currentUserData = await AuthService.getUserData();
        await AuthService.saveUserData(
          userId: currentUserData['userId'] ?? '',
          email: email ?? currentUserData['email'] ?? '',
          username: username ?? currentUserData['username'] ?? '',
          phone: phone ?? currentUserData['phone'] ?? '',
        );
        // update UI and exit editing mode
        setState(() {
          if (field == 'username') {
            _originalUsername = usernameController.text;
            _isEditingUsername = false;
          }
          if (field == 'email') {
            _originalEmail = emailController.text;
            _isEditingEmail = false;
          }
          if (field == 'phone') {
            _originalPhone = phoneController.text;
            _isEditingPhone = false;
          }
          _errorMessage = null;
        });
        // show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // show error message from API
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      // show general error message
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // stop loading indicator
      setState(() {
        _isLoading = false;
      });
    }
  }

  // handle canceling the edit
  void _handleCancelEdit(String field) {
    setState(() {
      if (field == 'username') {
        usernameController.text = _originalUsername;
        _isEditingUsername = false;
      }
      if (field == 'email') {
        emailController.text = _originalEmail;
        _isEditingEmail = false;
      }
      if (field == 'phone') {
        phoneController.text = _originalPhone;
        _isEditingPhone = false;
      }
      _errorMessage = null;
    });
  }

  // reusable widget for profile fields
  Widget buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onCancel,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              readOnly: !isEditing,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0057B8), width: 2),
                ),
              ),
            ),
            if (!isEditing)
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF0057B8)),
                onPressed: onEdit,
                splashRadius: 22,
              ),
            if (isEditing)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: isLoading ? null : onSave,
                    splashRadius: 22,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: isLoading ? null : onCancel,
                    splashRadius: 22,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[900]),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xFF0057B8),
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Column(
                      children: [
                        buildProfileField(
                          label: 'Username:',
                          controller: usernameController,
                          isEditing: _isEditingUsername,
                          isLoading: _isLoading && _isEditingUsername,
                          onEdit: () {
                            setState(() {
                              _isEditingUsername = true;
                              _isEditingEmail = false;
                              _isEditingPhone = false;
                            });
                          },
                          onSave: () => _handleSaveField('username'),
                          onCancel: () => _handleCancelEdit('username'),
                        ),
                        const SizedBox(height: 18),
                        buildProfileField(
                          label: 'Email Address:',
                          controller: emailController,
                          isEditing: _isEditingEmail,
                          isLoading: _isLoading && _isEditingEmail,
                          onEdit: () {
                            setState(() {
                              _isEditingUsername = false;
                              _isEditingEmail = true;
                              _isEditingPhone = false;
                            });
                          },
                          onSave: () => _handleSaveField('email'),
                          onCancel: () => _handleCancelEdit('email'),
                        ),
                        const SizedBox(height: 18),
                        buildProfileField(
                          label: 'Phone Number:',
                          controller: phoneController,
                          isEditing: _isEditingPhone,
                          isLoading: _isLoading && _isEditingPhone,
                          onEdit: () {
                            setState(() {
                              _isEditingUsername = false;
                              _isEditingEmail = false;
                              _isEditingPhone = true;
                            });
                          },
                          onSave: () => _handleSaveField('phone'),
                          onCancel: () => _handleCancelEdit('phone'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057B8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 