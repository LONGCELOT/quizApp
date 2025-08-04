import 'package:flutter/material.dart';
import '../utils/password_change_test_helper.dart';

class PasswordTestButton extends StatelessWidget {
  const PasswordTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Test password change API
        await PasswordChangeTestHelper.testPasswordChange();

        // Close loading
        if (context.mounted) {
          Navigator.of(context).pop();
          
          // Show completion message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password change test completed. Check console for results.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      child: const Text('Test Password Change API'),
    );
  }
}
