import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:themotorwash/blocs/global_auth/global_auth_bloc.dart';
import 'package:themotorwash/blocs/phone_auth/phone_auth_bloc.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/explore/explore_screen.dart';
import 'package:themotorwash/ui/screens/home/home_screen.dart';
import 'package:themotorwash/ui/screens/login/login_screen.dart';
import 'package:themotorwash/utils/utils.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({Key? key, required this.phoneNumber})
      : super(key: key);
  final String phoneNumber;

  static final String route = '/verifyPhoneScreen';

  @override
  _VerifyPhoneScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    return _VerifyPhoneScreenState();
  }
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen>
    with SingleTickerProviderStateMixin {
  late PhoneAuthBloc phoneAuthBloc;
  String enteredOtp = "";
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    phoneAuthBloc = BlocProvider.of<PhoneAuthBloc>(context);

    _animController = AnimationController(
        vsync: this,
        lowerBound: 0,
        upperBound: 30,
        duration: Duration(seconds: 30));
    _animController.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarLoginScreen(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocListener<GlobalAuthBloc, GlobalAuthState>(
            listener: (context, state) {
              // autoaveLog('')
              if (state is Authenticated) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.pushNamedAndRemoveUntil(
                    context, ExploreScreen.route, (route) => false);
              }
            },
            child: BlocListener<PhoneAuthBloc, PhoneAuthState>(
              bloc: phoneAuthBloc,
              listener: (_, state) {
                if (state is SendingOTP) {
                  showSnackbar(context, 'Resending OTP...');
                }
                if (state is FailedToSendOTP) {
                  _animController.reset();
                  showSnackbar(context, 'Failed to send OTP.');
                }
                if (state is OTPSent) {
                  showSnackbar(context, 'OTP Sent..');
                }
                if (state is CheckingOTP) {
                  // showSnackbar(context, 'Verifying OTP..');
                }
                if (state is OTPCheckedPassed) {}

                if (state is OTPCheckFailed) {
                  showSnackbar(context, 'Wrong OTP entered');
                }
              },
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('An OTP is sent to ${widget.phoneNumber}',
                                style: SizeConfig.kStyle16W500
                                    .copyWith(fontWeight: FontWeight.normal)),
                            SizeConfig.kverticalMargin16,
                            Text.rich(
                              TextSpan(
                                  text: 'Not your number? ',
                                  style: SizeConfig.kStyle12
                                      .copyWith(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                LoginScreen.route,
                                                (route) => false),
                                      text: 'Change number',
                                      style: SizeConfig.kStyle12PrimaryColor
                                          .copyWith(
                                              decoration:
                                                  TextDecoration.underline),
                                    )
                                  ]),
                            ),
                            SizeConfig.kverticalMargin16,
                            OTPFieldWidget(onChange: onChanged),
                            SizeConfig.kverticalMargin16,
                            AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return Text.rich(
                                  TextSpan(
                                      text: 'Didn’t recive a Code? ',
                                      style: SizeConfig.kStyle12
                                          .copyWith(color: Colors.black),
                                      children: [
                                        TextSpan(
                                            text: _animController.isAnimating
                                                ? 'Request again (${(30 - _animController.value).ceil()})'
                                                : 'Request Again',
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                if (!_animController
                                                    .isAnimating) {
                                                  _animController.reset();
                                                  _animController.forward();
                                                  phoneAuthBloc.add(SendOTP(
                                                      phoneNumber:
                                                          widget.phoneNumber));
                                                }
                                              },
                                            style: SizeConfig
                                                .kStyle12PrimaryColor
                                                .copyWith(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color: _animController
                                                            .isAnimating
                                                        ? SizeConfig
                                                            .kGreyTextColor
                                                        : SizeConfig
                                                            .kPrimaryColor))
                                      ]),
                                );
                              },
                            ),
                            SizeConfig.kverticalMargin16,
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Container(
                        width: 100.w,
                        height: 50,
                        child: BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
                          bloc: phoneAuthBloc,
                          builder: (context, state) {
                            return TextButton(
                              onPressed: enteredOtp.length == 4 &&
                                      !(state is CheckingOTP)
                                  ? () {
                                      phoneAuthBloc.add(CheckOTP(
                                          otp: enteredOtp,
                                          phoneNumber: widget.phoneNumber));
                                    }
                                  : null,
                              child: state is CheckingOTP
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : Text(
                                      'Verify',
                                      style: TextStyle(color: Colors.white),
                                    ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    enteredOtp.length == 4 &&
                                            !(state is CheckingOTP)
                                        ? SizeConfig.kPrimaryColor
                                        : Colors.grey),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizeConfig.kverticalMargin32
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  onChanged(String pin) {
    setState(() {
      enteredOtp = pin;
    });
  }
}

class OTPFieldWidget extends StatelessWidget {
  final Function(String) onChange;
  const OTPFieldWidget({Key? key, required this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      autoFocus: true,
      appContext: context,
      length: 4,
      onChanged: onChange,
      keyboardType: TextInputType.number,
      mainAxisAlignment: MainAxisAlignment.center,
      pinTheme: PinTheme(
          fieldOuterPadding: EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(4),
          fieldHeight: 50,
          borderWidth: 1,
          shape: PinCodeFieldShape.box,
          activeColor: SizeConfig.kPrimaryColor,
          disabledColor: SizeConfig.kPrimaryColor,
          selectedColor: SizeConfig.kPrimaryColor,
          inactiveColor: SizeConfig.kPrimaryColor),
    );
  }
}
