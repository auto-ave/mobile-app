import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';

import 'package:themotorwash/blocs/profile/profile_bloc.dart';
import 'package:themotorwash/data/models/user_profile.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/explore/explore_screen.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  static final String route = '/profileScreen';
  final bool showSkip;
  const ProfileScreen({Key? key, required this.showSkip}) : super(key: key);

  @override
  _ProfileScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  late ProfileBloc _profileBloc;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _profileBloc =
        ProfileBloc(repository: RepositoryProvider.of<Repository>(context));
    _profileBloc.add(GetProfile());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _profileBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        bloc: _profileBloc,
        builder: (context, state) {
          return Scaffold(
              // persistentFooterButtons:

              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: SizeConfig.kPrimaryColor),
                actions: widget.showSkip
                    ? [
                        // Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0, right: 16.0),
                          child: Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  ExploreScreen.route,
                                  (route) => false),
                              child: Text(
                                'skip',
                                style: SizeConfig.kStyle16PrimaryColor,
                              ),
                            ),
                          ),
                        )
                      ]
                    : null,
              ),
              body: BlocConsumer<ProfileBloc, ProfileState>(
                bloc: _profileBloc,
                listener: (_, state) {
                  if (state is ProfileLoaded || state is ProfileUpdated) {
                    if (state is FailedToUpdateProfile) {
                      showSnackbar(context, 'Failed to update profile');
                    }
                    UserProfile? userProfile;
                    if (state is ProfileLoaded) {
                      userProfile = state.userProfile;
                    }
                    if (state is ProfileUpdated) {
                      userProfile = state.userProfile;
                      showSnackbar(context, 'Profile Updated');
                    }

                    firstNameController.text = userProfile!.firstName ?? "";
                    lastNameController.text = userProfile.lastName ?? "";
                    emailController.text = userProfile.email ?? "";
                  }
                },
                builder: (context, state) {
                  if (state is LoadingProfile) {
                    return Center(
                      child: loadingAnimation(),
                    );
                  }
                  if (state is FailedToLoadProfile) {
                    return Center(
                      child: ErrorScreen(
                        ctaType: ErrorCTA.reload,
                        onCTAPressed: () {
                          _profileBloc.add(GetProfile());
                        },
                      ),
                    );
                  }
                  if (state is ProfileLoaded ||
                      state is ProfileUpdated ||
                      state is UpdatingProfile ||
                      state is FailedToUpdateProfile) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50.0)),
                                            border: Border.all(
                                                color: SizeConfig.kPrimaryColor,
                                                width: 2)),
                                        child: Image.asset(
                                            'assets/images/avatar.png'),
                                      ),
                                      // Positioned(
                                      //   child: Container(
                                      //     height: 24,
                                      //     width: 24,
                                      //     child: Center(
                                      //       child: Icon(
                                      //         Icons.edit,
                                      //         color: Colors.white,
                                      //         size: 12,
                                      //       ),
                                      //     ),
                                      //     decoration: BoxDecoration(
                                      //         borderRadius: BorderRadius.circular(4),
                                      //         color: SizeConfig.kPrimaryColor),
                                      //   ),
                                      //   bottom: 0,
                                      //   right: 0,
                                      // )
                                    ],
                                  ),
                                  SizeConfig.kverticalMargin16,
                                  SizeConfig.kverticalMargin8,
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CommonTextField(
                                          fieldName: 'First Name',
                                          fieldController: firstNameController,
                                          maxLines: 1,
                                        ),
                                        SizeConfig.kverticalMargin16,
                                        CommonTextField(
                                          fieldName: 'Last Name',
                                          fieldController: lastNameController,
                                          maxLines: 1,
                                        ),
                                        SizeConfig.kverticalMargin16,
                                        CommonTextField(
                                          validator: validateEmail,
                                          fieldName: 'Email',
                                          fieldController: emailController,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: state is LoadingProfile ||
                                    state is FailedToLoadProfile
                                ? SizedBox.shrink()
                                : CommonTextButton(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: state is UpdatingProfile
                                        ? SizedBox(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              backgroundColor: Colors.white,
                                            ),
                                            width: 25,
                                            height: 25,
                                          )
                                        : Text('Save',
                                            style:
                                                TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      if (!(state is LoadingProfile ||
                                          state is UpdatingProfile)) {
                                        if (_formKey.currentState!.validate()) {
                                          _profileBloc.add(UpdateProfile(
                                              userProfileEntity:
                                                  UserProfileEntity(
                                                      email:
                                                          emailController.text,
                                                      firstName:
                                                          firstNameController
                                                              .text,
                                                      lastName:
                                                          lastNameController
                                                              .text)));
                                        }
                                      }
                                    },
                                    backgroundColor: SizeConfig.kPrimaryColor,
                                    buttonSemantics: 'Profile Save',
                                  ))
                      ],
                    );
                  }
                  return Center(
                    child: loadingAnimation(),
                  );
                },
              ));
        });
  }
}

class CommonTextField extends StatelessWidget {
  final String? fieldName;
  final String? hintText;
  final TextEditingController fieldController;
  final String? Function(String?)? validator;
  final bool filled;
  final int? maxLines;
  const CommonTextField({
    Key? key,
    this.fieldName,
    this.hintText,
    required this.fieldController,
    this.validator,
    this.filled = true,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: fieldController,
      style: SizeConfig.kStyle14W500,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: filled,
        fillColor: Color(0xffF2F8FF),
        labelText: fieldName,
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: SizeConfig.kPrimaryColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: SizeConfig.kPrimaryColor)),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: SizeConfig.kPrimaryColor),
        ),
      ),
    );
  }
}
