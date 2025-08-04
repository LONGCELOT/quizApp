import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/otp_service.dart';
import 'complete_signup_screen.dart';
import 'new_password_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber; // Full phone number for display
  final String countryCode; // Country code for API calls
  final String phone; // Phone number without country code for API calls
  final String otpType; // 'signup' or 'reset'
  final String? debugOTP; // For testing purposes

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    required this.phone,
    required this.otpType,
    this.debugOTP,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  Timer? _timer;
  int _remainingTime = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Auto-fill for testing (remove in production)
    if (widget.debugOTP != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        final otp = widget.debugOTP!;
        for (int i = 0; i < otp.length && i < 6; i++) {
          _controllers[i].text = otp[i];
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    if (_controllers.every((controller) => controller.text.isNotEmpty)) {
      _verifyOTP();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _controllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (mounted) {
        // Navigate to the appropriate screen with the OTP
        if (widget.otpType == 'signup') {
          // Navigate to complete signup with the OTP
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteSignUpScreen(
                phoneNumber: widget.phoneNumber,
                countryCode: widget.countryCode,
                phone: widget.phone,
                otp: otp,
              ),
            ),
          );
        } else if (widget.otpType == 'reset') {
          // Navigate to new password screen with the OTP
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NewPasswordScreen(
                phoneNumber: widget.phoneNumber,
                countryCode: widget.countryCode,
                phone: widget.phone,
                otp: otp,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Clear OTP fields on error
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the real API service for resending OTP
      await OtpService.resendOTP(
        countryCode: widget.countryCode,
        phone: widget.phone,
      );

      if (mounted) {
        // Clear current OTP
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        
        // Restart timer
        _timer?.cancel();
        _remainingTime = 300;
        _startTimer();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP: ${e.toString()}'),
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Header Section
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.message,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verify Your Phone',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // OTP Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              onChanged: (value) => _onOTPChanged(value, index),
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Timer and Resend
                      if (_remainingTime > 0)
                        Text(
                          'Code expires in $_formattedTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _isLoading ? null : _resendOTP,
                          child: const Text(
                            'Resend Code',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Verify Code',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Debug info (remove in production)
              if (widget.debugOTP != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow.shade300),
                  ),
                  child: Text(
                    'DEBUG: OTP is ${widget.debugOTP}',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
