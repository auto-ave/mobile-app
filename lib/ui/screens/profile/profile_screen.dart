import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:themotorwash/blocs/profile/profile_bloc.dart';
import 'package:themotorwash/data/models/user_profile.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/explore/explore_screen.dart';
import 'package:themotorwash/utils.dart';

class ProfileScreen extends StatefulWidget {
  static final String route = '/profileScreen';
  final bool showSkip;
  const ProfileScreen({Key? key, required this.showSkip}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
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
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        bloc: _profileBloc,
        builder: (context, state) {
          return Scaffold(
              persistentFooterButtons:
                  state is LoadingProfile || state is FailedToLoadProfile
                      ? null
                      : [
                          TextButton(
                            child: state is UpdatingProfile
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                : Text('Save',
                                    style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              if (!(state is LoadingProfile ||
                                  state is UpdatingProfile)) {
                                if (_formKey.currentState!.validate()) {
                                  _profileBloc.add(UpdateProfile(
                                      userProfileEntity: UserProfileEntity(
                                          email: emailController.text,
                                          firstName: firstNameController.text,
                                          lastName: lastNameController.text)));
                                }
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(kPrimaryColor)),
                          )
                        ],
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: kPrimaryColor),
                actions: widget.showSkip
                    ? [
                        // Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0, right: 16.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  ExploreScreen.route,
                                  (route) => false),
                              child: Text(
                                'skip',
                                style: kStyle16PrimaryColor,
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

                    firstNameController.text = userProfile!.firstName;
                    lastNameController.text = userProfile.lastName;
                    emailController.text = userProfile.email;
                  }
                },
                builder: (context, state) {
                  if (state is LoadingProfile) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is FailedToLoadProfile) {
                    return Center(
                      child: Text('Failed To Load Profile'),
                    );
                  }
                  if (state is ProfileLoaded ||
                      state is ProfileUpdated ||
                      state is UpdatingProfile ||
                      state is FailedToUpdateProfile) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50.0)),
                                    border: Border.all(
                                        color: kPrimaryColor, width: 2)),
                                child: Image.asset('assets/images/avatar.png'),
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
                              //         color: kPrimaryColor),
                              //   ),
                              //   bottom: 0,
                              //   right: 0,
                              // )
                            ],
                          ),
                          kverticalMargin16,
                          kverticalMargin8,
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ProfileTextField(
                                    fieldName: 'First Name',
                                    fieldController: firstNameController),
                                kverticalMargin16,
                                ProfileTextField(
                                    fieldName: 'Last Name',
                                    fieldController: lastNameController),
                                kverticalMargin16,
                                ProfileTextField(
                                    validator: (string) {
                                      if (string != null) {
                                        if (EmailValidator.validate(string)) {
                                          return null;
                                        }
                                        return 'Enter a valid email';
                                      }
                                      return 'Enter a valid email';
                                    },
                                    fieldName: 'Email',
                                    fieldController: emailController),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ));
        });
  }
}

class ProfileTextField extends StatelessWidget {
  final String fieldName;
  final TextEditingController fieldController;
  final String? Function(String?)? validator;
  const ProfileTextField({
    Key? key,
    required this.fieldName,
    required this.fieldController,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffF2F8FF),
      child: TextFormField(
        validator: validator,
        controller: fieldController,
        style: kStyle14W500,
        decoration: InputDecoration(
          labelText: fieldName,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: kPrimaryColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: kPrimaryColor)),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: kPrimaryColor),
          ),
        ),
      ),
    );
  }
}
