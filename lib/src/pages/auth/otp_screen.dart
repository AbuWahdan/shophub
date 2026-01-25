import 'package:flutter/material.dart';
import '../../themes/light_color.dart';
import '../../themes/theme.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  late List<TextEditingController> _otpControllers;
  late AnimationController _timerController;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (index) => TextEditingController());
    _startTimer();
  }

  void _startTimer() {
    _timerController = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    );

    _timerController.addListener(() {
      setState(() {
        _remainingSeconds = (60 * (1 - _timerController.value)).toInt();
      });
    });

    _timerController.forward();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _timerController.dispose();
    super.dispose();
  }

  void _onOTPChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  String _getOTP() {
    return _otpControllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              Text(
                'Enter Verification Code',
                style: AppTheme.h3Style,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'We\'ve sent a 6-digit code to your email',
                style: AppTheme.subTitleStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _otpControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: LightColor.skyBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onOTPChanged(value, index),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              if (_remainingSeconds > 0)
                Text(
                  'Resend code in ${_remainingSeconds}s',
                  style: TextStyle(color: LightColor.grey, fontSize: 14),
                )
              else
                TextButton(
                  onPressed: () {
                    setState(() {
                      _remainingSeconds = 60;
                      _startTimer();
                    });
                  },
                  child: Text('Resend Code'),
                ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final otp = _getOTP();
                    if (otp.length == 6) {
                      Navigator.of(context).pushReplacementNamed('/main');
                    }
                  },
                  child: Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
