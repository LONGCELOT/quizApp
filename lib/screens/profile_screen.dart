import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../widgets/auth_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  UserProfile? _userProfile;
  
  // Controllers for editing
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  
  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _fetchUserProfile();
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final profileData = await ApiService.getUserProfile(token);
      final profile = UserProfile.fromJson(profileData);

      setState(() {
        _userProfile = profile;
        _firstNameController.text = profile.firstName ?? '';
        _lastNameController.text = profile.lastName ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        _errorMessage = 'Failed to load profile. Please try again.';
        _isLoading = false;
        // Create a mock profile as fallback
        _userProfile = UserProfile(
          id: 0,
          countryCode: '855',
          phone: '123456789',
          firstName: 'Demo',
          lastName: 'User',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
      });
    }
  }
  
  Future<void> _toggleEdit() async {
    if (_isEditing) {
      // Save changes
      if (_formKey.currentState!.validate()) {
        await _updateProfile();
      }
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await ApiService.updateUserProfile(
        token: token,
        firstName: _firstNameController.text.isEmpty ? null : _firstNameController.text,
        lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
      );

      // Refresh profile data after update
      await _fetchUserProfile();
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onPasswordChanged: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Clear the stored token
                await TokenService.clearStorage();
                
                if (mounted) {
                  // Close the dialog
                  Navigator.of(context).pop();
                  
                  // Navigate to AuthWrapper which will show LoginScreen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                    (route) => false,
                  );
                }
              } catch (e) {
                print('Error signing out: $e');
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to sign out. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white),
              onPressed: _toggleEdit,
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchUserProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'No profile data available',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Profile Header Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                // Profile Picture and Basic Info
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Text(
                                        _userProfile!.displayName.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _userProfile!.displayName,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _userProfile!.fullPhoneNumber,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (_errorMessage != null)
                                            Container(
                                              margin: const EdgeInsets.only(top: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                              ),
                                              child: const Text(
                                                'Demo Mode',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 20),
                                
                                // Account Information Section
                                _buildSection(
                                  'Account Information',
                                  [
                                    _buildInfoField(
                                      'First Name',
                                      _userProfile!.firstName,
                                      _firstNameController,
                                      Icons.person,
                                      _isEditing,
                                    ),
                                    _buildInfoField(
                                      'Last Name',
                                      _userProfile!.lastName,
                                      _lastNameController,
                                      Icons.person_outline,
                                      _isEditing,
                                    ),
                                    _buildReadOnlyField(
                                      'Phone Number',
                                      _userProfile!.fullPhoneNumber,
                                      Icons.phone,
                                    ),
                                    _buildReadOnlyField(
                                      'User ID',
                                      _userProfile!.id.toString(),
                                      Icons.badge,
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Account Actions
                                _buildSection(
                                  'Account Actions',
                                  [
                                    ListTile(
                                      leading: Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
                                      title: const Text('Change Password'),
                                      subtitle: const Text('Update your account password'),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onTap: _changePassword,
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.logout, color: Colors.red),
                                      title: const Text('Sign Out'),
                                      subtitle: const Text('Sign out of your account'),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onTap: _signOut,
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Account Details
                                _buildSection(
                                  'Account Details',
                                  [
                                    _buildReadOnlyField(
                                      'Member Since',
                                      _formatDate(_userProfile!.createdAt),
                                      Icons.calendar_today,
                                    ),
                                    _buildReadOnlyField(
                                      'Last Updated',
                                      _formatDate(_userProfile!.updatedAt),
                                      Icons.update,
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
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoField(
    String label,
    String? value,
    TextEditingController controller,
    IconData icon,
    bool isEditing,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                // Optional validation - only username/names can be empty
                return null;
              },
            )
          : ListTile(
              leading: Icon(icon, color: Colors.grey.shade600),
              title: Text(label),
              subtitle: Text(value?.isEmpty == true ? 'Not set' : value ?? 'Not set'),
              contentPadding: EdgeInsets.zero,
            ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(label),
      subtitle: Text(value),
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

// Change Password Dialog
class ChangePasswordDialog extends StatefulWidget {
  final VoidCallback? onPasswordChanged;
  
  const ChangePasswordDialog({
    super.key,
    this.onPasswordChanged,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await ApiService.changePassword(
        token: token,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPasswordChanged?.call();
      }
    } catch (e) {
      print('Error changing password: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: ${e.toString()}'),
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
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter new password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}
