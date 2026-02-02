import 'package:flutter/material.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../../shared/validation/auth_validators.dart';
import '../../shared/widgets/app_button.dart';
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
  final _formKey = GlobalKey<FormState>();
  static const int _otpLength = 6;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (index) => TextEditingController());
    _startTimer();
  }

  void _startTimer() {
    _timerController = AnimationController(
      duration: const Duration(seconds: 60),
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l10n.otpEnterCode,
                  style: AppTextStyles.headlineSmall(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.otpSubtitle,
                  style: AppTextStyles.bodyMedium(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.jumbo),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    _otpLength,
                    (index) => SizedBox(
                      width: AppSpacing.buttonMd,
                      height: AppSpacing.buttonLg,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        validator: (value) => AuthValidators.otp(
                          value,
                          length: 1,
                          emptyMessage: l10n.validationOtpRequired,
                          invalidMessage: l10n.validationOtpInvalid,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: AppSpacing.borderThick,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onOTPChanged(value, index),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (_remainingSeconds > 0)
                  Text(
                    l10n.otpResendIn(_remainingSeconds),
                    style: AppTextStyles.bodySmall(context),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _remainingSeconds = 60;
                        _startTimer();
                      });
                    },
                    child: Text(l10n.otpResend),
                  ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.otpVerify,
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final otp = _getOTP();
                    final validation = AuthValidators.otp(
                      otp,
                      length: _otpLength,
                      emptyMessage: l10n.validationOtpRequired,
                      invalidMessage: l10n.validationOtpInvalidLength,
                    );
                    if (validation == null) {
                      Navigator.of(context).pushReplacementNamed('/main');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
