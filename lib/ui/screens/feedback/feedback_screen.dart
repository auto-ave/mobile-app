import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:themotorwash/ui/screens/explore/explore_screen.dart';
import 'package:themotorwash/ui/widgets/or_divider_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:themotorwash/blocs/feedback/bloc/feedback_bloc.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/feedback/contact_option_button.dart';
import 'package:themotorwash/ui/screens/profile/profile_screen.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/utils/utils.dart';

class FeedbackScreen extends StatefulWidget {
  final bool isFeedback;
  final String? orderNumber;
  const FeedbackScreen({
    Key? key,
    required this.isFeedback,
    required this.orderNumber,
  }) : super(key: key);
  static final String route = '/feedbackScreen';

  @override
  _FeedbackScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    return _FeedbackScreenState();
  }
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final FeedbackBloc _feedbackBloc;

  @override
  void initState() {
    super.initState();
    _feedbackBloc =
        FeedbackBloc(repository: RepositoryProvider.of<Repository>(context));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _feedbackBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarWithBackButton(
          context: context,
          title: Text(
            widget.isFeedback ? 'Feedback' : 'Cancellation Request',
            style: SizeConfig.kStyleAppBarTitle,
          )),
      body: BlocConsumer<FeedbackBloc, FeedbackState>(
          bloc: _feedbackBloc,
          listener: (context, state) {
            if (state is FeedbackSent) {
              showSnackbar(
                  context,
                  widget.isFeedback
                      ? 'Thank you for your valuable feedback.'
                      : 'We have received your request.');
            }
            if (state is FeedbackError) {
              showSnackbar(
                  context,
                  widget.isFeedback
                      ? 'Error sending feedback. Please try again later'
                      : 'Error sending request. Please try again later');
            }
          },
          builder: (context, state) {
            // return Container(
            //   color: Colors.amber,
            //   child: Column(
            //     children: [Text('Hello')],
            //   ),
            // );
            if (state is FeedbackSent) {
              return SizedBox(
                child: FeedbackSentWidget(
                  isFeedback: widget.isFeedback,
                ),
                width: 100.w,
              );
            }
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // CommonTextField(
                      //   fieldName: 'Email',
                      //   fieldController: emailController,
                      //   validator: validateEmail,
                      // ),
                      // SizeConfig.kverticalMargin16,
                      // CommonTextField(
                      //   fieldName: 'Phone',
                      //   fieldController: phoneController,
                      //   validator: validatePhone,
                      // ),
                      // SizeConfig.kverticalMargin16,
                      widget.isFeedback
                          ? FeedbackTextWidget()
                          : OrderSupportTextWidget(),
                      SizeConfig.kverticalMargin8,
                      Text(
                        'If you have any questions, feedback or any problems please contact us. We are happy to hear from you',
                        style: SizeConfig.kStyle12
                            .copyWith(color: SizeConfig.kGreyTextColor),
                      ),
                      widget.isFeedback
                          ? Container()
                          : OrderSupportNumberWidget(
                              orderNumber: widget.orderNumber ?? 'NA'),
                      SizeConfig.kverticalMargin16,
                      Text(
                        'Your message',
                        style: SizeConfig.kStyle12W500,
                      ),
                      SizeConfig.kverticalMargin8,
                      SizedBox(
                        height: 20.h,
                        child: CommonTextField(
                          fieldController: messageController,
                          validator: (string) {
                            if (string != null) {
                              if (string.trim().isEmpty) {
                                return 'field cannot be empty';
                              }
                              return null;
                            }
                            return 'field cannot be empty';
                          },
                          maxLines: 100,
                          filled: false,
                        ),
                      ),
                      SizeConfig.kverticalMargin16,
                      CommonTextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _feedbackBloc.add(SendFeedback(
                                email: 'suryansh@gmail.com',
                                phone: '+917000037559',
                                message: messageController.text));
                          }
                        },
                        child: state is FeedbackLoading
                            ? SizedBox(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor: Colors.white,
                                ),
                                width: 25,
                                height: 25,
                              )
                            : Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                        backgroundColor: SizeConfig.kPrimaryColor,
                        buttonSemantics: widget.isFeedback
                            ? 'Submit Feedback'
                            : 'Submit Order Support',
                      ),

                      SizeConfig.kverticalMargin24,
                      ORWithDividerWidget(),
                      SizeConfig.kverticalMargin24,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ContactOptionButton(
                            onTap: () {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: 'support@autoave.in',
                                query: encodeQueryParameters(<String, String>{
                                  'subject': widget.isFeedback
                                      ? 'Feedback'
                                      : 'Order number : ${widget.orderNumber}'
                                }),
                              );

                              launch(emailLaunchUri.toString());
                            },
                            text: 'Mail us',
                            svgAsset: 'assets/icons/mail.svg',
                            buttonSemantics: 'Mail Us Click',
                          ),
                          ContactOptionButton(
                            onTap: () {
                              final Uri telLaunchUri = Uri(
                                scheme: 'tel',
                                path: '+917000037559',
                              );

                              launch(telLaunchUri.toString());
                            },
                            text: 'Call us',
                            svgAsset: 'assets/icons/phone.svg',
                            buttonSemantics: 'Call us Click',
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class FeedbackTextWidget extends StatelessWidget {
  const FeedbackTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'We did love to hear from you',
      style: SizeConfig.kStyle16W500,
    );
  }
}

class OrderSupportTextWidget extends StatelessWidget {
  const OrderSupportTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Having any problems regarding the order?',
      style: SizeConfig.kStyle16W500,
    );
  }
}

class OrderSupportNumberWidget extends StatelessWidget {
  final String orderNumber;
  const OrderSupportNumberWidget({
    Key? key,
    required this.orderNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizeConfig.kverticalMargin8,
        Divider(),
        SizeConfig.kverticalMargin8,
        Text.rich(TextSpan(children: [
          TextSpan(
              text: 'ORDER NUMBER: ',
              style: SizeConfig.kStyle12W500.copyWith(
                  letterSpacing: 1.8, color: SizeConfig.kGreyTextColor)),
          TextSpan(
              text: orderNumber,
              style: SizeConfig.kStyle16PrimaryColor
                  .copyWith(fontWeight: FontWeight.w500))
        ])),
      ],
    );
  }
}

class FeedbackSentWidget extends StatelessWidget {
  final bool isFeedback;
  const FeedbackSentWidget({Key? key, required this.isFeedback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Stack(
          // crossAxisAlignment: CrossAxisAlignment.end,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 100.w,
              child: Column(
                children: [
                  Text(
                    isFeedback ? 'Feedback Sent' : 'Request Sent',
                    style: SizeConfig.kStyle20W500,
                  ),
                  SizeConfig.kverticalMargin4,
                  Text(
                    isFeedback
                        ? 'We have recieved your feedback.'
                        : 'We have recieved your request.',
                    style: SizeConfig.kStyle14
                        .copyWith(color: SizeConfig.kGreyTextColor),
                  ),
                  Text(
                    'We will get back to you soon.',
                    style: SizeConfig.kStyle14
                        .copyWith(color: SizeConfig.kGreyTextColor),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Image.asset('assets/images/victory.png'),
              right: 0,
              bottom: 0,
            ),
          ],
        ),
        Spacer(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 100.w,
              child: CommonTextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, ExploreScreen.route, (route) => false);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Home',
                    style: SizeConfig.kStyle14.copyWith(color: Colors.white),
                  ),
                ),
                backgroundColor: SizeConfig.kPrimaryColor,
                buttonSemantics: 'Feedback Sent Home',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
