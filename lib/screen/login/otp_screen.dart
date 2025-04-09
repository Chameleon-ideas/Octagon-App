import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/main.dart';
import 'package:octagon/networking/model/response_model/login_response_model.dart';
import 'package:octagon/screen/login/bloc/login_bloc.dart';
import 'package:octagon/screen/login/bloc/login_event.dart';
import 'package:octagon/screen/login/bloc/login_state.dart';
import 'package:octagon/screen/login/login_screen.dart';
import 'package:octagon/screen/sport/sport_selection_screen.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:resize/resize.dart';

import '../term_selection/team_selection.dart';

class OTPScreen extends StatefulWidget {
  // final ThemeNotifier? model;
  String email = "";
  bool isFromLogin = false;
  OTPScreen(/*this.model,*/ this.email, {this.isFromLogin = false, Key? key})
      : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  AutovalidateMode isValidate = AutovalidateMode.disabled;
  final TextEditingController _otpTextController = TextEditingController();
  LoginBloc loginBloc = LoginBloc();

  bool isLoading = false;

  List<Sports> sportDataList = [];
  LoginResponseModel? loginResponseModel;

  @override
  void initState() {
    loginBloc = LoginBloc();
    // otpVerifyBloc = OtpVerifyBloc();
    // otpVerifyBloc.otpVerifyStream.listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       break;
    //     case Status.COMPLETED:
    //       loginResponseModel = event.data;
    //       if(loginResponseModel!.error!=null){
    //         showToast(message: loginResponseModel?.error??"");
    //         // Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPScreen(/*widget.model*/_emailController.text.trim(), isFromLogin: true,)));
    //       }else{
    //         ///todo todo parth copy this in verify otp screen.
    //         storage.write("current_uid", loginResponseModel!.success!.userId);
    //         storage.write('token', loginResponseModel!.success!.token.toString());
    //         storage.write('country', loginResponseModel!.success!.country.toString());
    //         storage.write('user_name', loginResponseModel!.success!.name.toString());
    //         storage.write('image_url', loginResponseModel!.success!.photo.toString());
    //         storage.write('email', loginResponseModel!.success!.email.toString());
    //
    //         storage.write(userData, loginResponseModel!.success!.toJson());
    //
    //         setAmplitudeUserProperties();
    //
    //         // Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection(widget.model)));
    //
    //         if(loginResponseModel?.success?.sportInfo==null ||
    //             loginResponseModel!.success!.sportInfo!.isEmpty ||
    //             loginResponseModel?.success?.sportInfo?.first.team == null || loginResponseModel!.success!.sportInfo!.first.team!.isEmpty){
    //           if(loginResponseModel?.success?.sportInfo?.isEmpty ?? false){
    //
    //             Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection(/*widget.model*/)));
    //
    //           }else{
    //             sportDataList = [];
    //             for (var element in loginResponseModel!.success!.sportInfo!) {
    //               sportDataList.add(Sports(
    //                   "${element.strSport}",
    //                   element.id!.toInt(),
    //                   element.idSport!.toInt(),
    //                   element.strSportThumb.toString(),
    //                   selected: true));
    //             }
    //
    //             Navigator.push(context, MaterialPageRoute(
    //                 builder: (context) => TeamSelectionScreen(/*
    //                   widget.model,*/ sportDataList
    //                 )));
    //           }
    //
    //         }else{
    //           ///first team flag
    //           storage.write('userDefaultTeam', loginResponseModel!.success!.sportInfo!.first.team!.first.strTeamLogo.toString());
    //           storage.write('userDefaultTeamName', loginResponseModel!.success!.sportInfo!.first.team!.first.toJson());
    //
    //           List<Map<String, dynamic>> data = [];
    //           event.data!.success!.sportInfo?.forEach((element) {
    //             data.add(element.toJson());
    //           });
    //
    //           storage.write(sportInfo, data);
    //
    //           Get.snackbar("Octagon", "You logged in as ${loginResponseModel!.success!.name}");
    //
    //           Navigator.pushReplacement(context,
    //               MaterialPageRoute(builder: (context) => TabScreen()));
    //         }
    //       }
    //
    //       // Navigator.pushReplacement(context, MaterialPageRoute(
    //       //     builder: (context) => LoginScreen(/*widget.model*/)));
    //       break;
    //     case Status.ERROR:
    //       print(Status.ERROR);
    //       Get.snackbar("otp", event.data);
    //       break;
    //   }
    // });
    //

    if (widget.isFromLogin) {
      showToast(message: "Your account was not verified yet!");
      loginBloc.add(ResendOtpEvent(email: widget.email));
    }
    //
     publishAmplitudeEvent(eventType: 'OTP $kScreenView');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appBgColor,
      child: SafeArea(
        child: BlocConsumer(
            bloc: loginBloc,
            listener: (context, state) {
              if(state is LoginLoadingBeginState){
                // onLoading(context);
                setState(() {
                  isLoading = true;
                });
              }

              if (state is VerifyOtpState) {
                setState(() {
                  isLoading = false;
                });
                // stopLoader(context);
                loginResponseModel = state.responseModel;
                if (loginResponseModel!.error != null) {
                  showToast(message: loginResponseModel?.error ?? "");
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPScreen(/*widget.model*/_emailController.text.trim(), isFromLogin: true,)));
                } else {
                  ///todo todo parth copy this in verify otp screen.
                  storage.write(
                      "current_uid", loginResponseModel!.success!.userId);
                  storage.write(
                      'token', loginResponseModel!.success!.token.toString());
                  if(loginResponseModel?.success?.country!=null){
                    storage.write('country',
                        loginResponseModel!.success!.country.toString());
                  }

                  if(loginResponseModel?.success?.name!=null){
                    storage.write('user_name',
                        loginResponseModel!.success!.name.toString());
                  }

                  if(loginResponseModel?.success?.bio!=null){
                    storage.write('bio', loginResponseModel?.success?.bio.toString());
                  }

                  if(loginResponseModel?.success?.photo!=null){
                    storage.write('image_url',
                        loginResponseModel!.success!.photo.toString());
                  }
                  if(loginResponseModel?.success?.email!=null){
                    storage.write(
                        'email', loginResponseModel!.success!.email.toString());
                  }

                  storage.write(
                      userData, loginResponseModel!.success!.toJson());

                  setAmplitudeUserProperties();

                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> TabScreen()));

                  if (loginResponseModel?.success?.sportInfo == null ||
                      loginResponseModel!.success!.sportInfo!.isEmpty ||
                      loginResponseModel?.success?.sportInfo?.first.team ==
                          null ||
                      loginResponseModel!
                          .success!.sportInfo!.first.team!.isEmpty) {
                    if (loginResponseModel?.success?.sportInfo?.isEmpty ??
                        false) {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection()));
                    } else {
                      sportDataList = [];
                      for (var element
                          in loginResponseModel!.success!.sportInfo!) {
                        sportDataList.add(Sports(
                            "${element.strSport}",
                            element.id!.toInt(),
                            element.idSport!.toInt(),
                            element.strSportThumb.toString(),
                            selected: true));
                      }
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => TeamSelectionScreen(sportDataList)));
                    }
                  } else {
                    ///first team flag
                    storage.write(
                        'userDefaultTeam',
                        loginResponseModel!
                            .success!.sportInfo!.first.team!.first.strTeamLogo
                            .toString());
                    storage.write('userDefaultTeamName', loginResponseModel!.success!.sportInfo!.first.team!.first.toJson());

                    List<Map<String, dynamic>> data = [];
                    state.responseModel.success!.sportInfo?.forEach((element) {
                      data.add(element.toJson());
                    });

                    storage.write(sportInfo, data);

                    Get.snackbar("Octagon",
                        "You logged in as ${loginResponseModel!.success!.name}");

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => TabScreen()));
                  }
                }
              }
              if (state is ResendOtpState) {
                // stopLoader(context);
                showToast(message: "Otp sent to your email please verify!");
                setState(() {
                  isLoading = false;
                });
              }
              if (state is LoginErrorState) {
                setState(() {
                  isLoading = false;
                });
                // stopLoader(context);
                Get.snackbar("otp", state.exception.toString());
              }
            },
            builder: (context, _) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 4.vh,
                      ),
                      Text(
                        "We have sent an OTP to\nyour Email address",
                        textAlign: TextAlign.center,
                        style: whiteColor24BoldTextStyle,
                      ),
                      Text(
                        "Please check your Email to complete your signup!.",
                        textAlign: TextAlign.center,
                        style: greyColor12TextStyle,
                      ),
                      SizedBox(
                        height: 4.vh,
                      ),
                      Form(
                        autovalidateMode: isValidate,
                        child: Column(
                          children: [
                            PinCodeTextField(
                              autofocus: true,
                              controller: _otpTextController,
                              hideCharacter: false,
                              highlight: true,
                              isCupertino: true,

                              pinBoxOuterPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              // highlightColor: whiteColor,
                              hasUnderline: false,

                              // defaultBorderColor:
                              // widget.model!.mode ? lightBlueColor : blueColor,
                              hasTextBorderColor: Colors.transparent,
                              highlightPinBoxColor: darkGreyColor,
                              pinBoxRadius: 10.0,
                              maxLength: 6,
                              pinBoxBorderWidth: 1,
                              onTextChanged: (text) {
                                setState(() {
                                  // hasError = false;
                                });
                              },
                              onDone: (text) {
                                print("DONE $text");
                                print(
                                    "DONE CONTROLLER ${_otpTextController.text}");
                              },
                              pinBoxWidth: 12.vw,
                              pinBoxHeight: 6.vh,
                              wrapAlignment: WrapAlignment.spaceEvenly,

                              //pinBoxRadius: 10,
                              pinBoxDecoration: ProvidedPinBoxDecoration
                                  .defaultPinBoxDecoration,
                              pinTextStyle: /*widget.model!.mode*/
                                  /*?*/ whiteColor20BoldTextStyle /*
                                : blueColor20BoldTextStyle*/
                              ,
                              pinTextAnimatedSwitcherTransition:
                                  ProvidedPinBoxTextAnimation.scalingTransition,
                              pinTextAnimatedSwitcherDuration:
                                  Duration(milliseconds: 200),
                              highlightAnimation: true,
                              highlightAnimationBeginColor: greyColor,
                              pinBoxColor: greyColor,
                              highlightAnimationEndColor: darkGreyColor,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              //highlightColor: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 4.vh,
                      ),
                      FilledButtonWidget(isLoading: isLoading,/*widget.model,*/ "Next", () {
                        if (_otpTextController.text.trim().length != 6) {
                          Get.snackbar(AppName, "Please enter valid OTP");
                        } else {
                          loginBloc.add(VerifyOtpEvent(
                              email: widget.email,
                              otp: _otpTextController.text));
                        }
                      }, 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                loginBloc
                                    .add(ResendOtpEvent(email: widget.email));
                              },
                              child: RichText(
                                text: TextSpan(
                                    text: "Resend ",
                                    style: whiteColor14BoldTextStyle,
                                    children: [
                                      TextSpan(
                                          text: "OTP",
                                          style: whiteColor14TextStyle),
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
