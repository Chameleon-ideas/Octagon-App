import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:octagon/main.dart';
import 'package:octagon/networking/model/response_model/login_response_model.dart';
import 'package:octagon/screen/login/bloc/login_bloc.dart';
import 'package:octagon/screen/login/bloc/login_event.dart';
import 'package:octagon/screen/login/bloc/login_state.dart';
import 'package:octagon/screen/login/mobile_number_screen.dart';
import 'package:octagon/screen/login/otp_screen.dart';
import 'package:octagon/screen/sign_up/sign_up_screen.dart';
import 'package:octagon/screen/sport/bloc/sport_bloc.dart';
import 'package:octagon/screen/sport/bloc/sport_event.dart';
import 'package:octagon/screen/sport/bloc/sport_state.dart';
import 'package:octagon/screen/sport/sport_selection_screen.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../networking/model/response_model/sport_list_response_model.dart';
import '../../networking/model/user_response_model.dart';
import '../../widgets/common_login_button.dart';
import '../edit_profile/edit_profile.dart';
import '../sign_up/signup_step.dart';
import '../tabs_screen.dart';
import '../term_selection/team_selection.dart';

class LoginScreen extends StatefulWidget {
  // final ThemeNotifier? model;
  bool isTeam = false;

  LoginScreen(/*this.model,*/ {Key? key,  this. isTeam = false}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class Sports {
  bool selected;
  String sportsName;
  int sportsId;
  int sportApiId;
  String sportsImage;

  Sports(
    this.sportsName,
    this.sportsId,
    this.sportApiId,
    this.sportsImage, {
    this.selected = false,
  });
}

class _LoginScreenState extends State<LoginScreen> {
  AutovalidateMode isValidate = AutovalidateMode.disabled;
  final TextEditingController _emailController =
      TextEditingController(text: "");
  final TextEditingController _passwordController =
      TextEditingController(text: "");

  LoginBloc loginBloc = LoginBloc();
  SportBloc sportBloc = SportBloc();
  // late RegisterBloc registerBloc;
  LoginResponseModel? loginResponseModel;
  // RegisterResponseModel? registerResponseModel;
  List<Sports> sportDataList = [];
  AuthorizationCredentialAppleID? appleLoginData;

  List<SportListResponseModelData> sportListResponseModel = [];

  bool isLoading = false;

  @override
  void initState() {
    loginBloc = LoginBloc();
    sportBloc = SportBloc();


    sportBloc.add(GetSportListEvent());
    // registerBloc = RegisterBloc();

    FirebaseMessaging.instance.deleteToken().then((value) {
      FirebaseMessaging.instance.getToken().then((token) {
        print(token);
        storage.write("fcm_token", token);
      });
    });

    /*loginBloc.loginStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          loginResponseModel = event.data;
          if(loginResponseModel!.error!=null){
            showToast(message: loginResponseModel?.error??"");
            Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPScreen(*/ /*widget.model*/ /*_emailController.text.trim(), isFromLogin: true,)));
          }else{
            ///todo todo parth copy this in verify otp screen.
            storage.write("current_uid", event.data!.success!.userId);
            storage.write('token', event.data!.success!.token.toString());
            storage.write('country', event.data!.success!.country.toString());
            storage.write('user_name', event.data!.success!.name.toString());
            storage.write('image_url', event.data!.success!.photo.toString());
            storage.write('email', event.data!.success!.email.toString());

            storage.write(userData, event.data!.success!.toJson());

            setAmplitudeUserProperties();

            // Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection(widget.model)));

            if(event.data?.success?.sportInfo==null ||
                event.data!.success!.sportInfo!.isEmpty ||
                event.data?.success?.sportInfo?.first.team == null || event.data!.success!.sportInfo!.first.team!.isEmpty){
              if(event.data?.success?.sportInfo?.isEmpty ?? false){

                Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection(*/ /*widget.model*/ /*)));

              }else{
                sportDataList = [];
                for (var element in event.data!.success!.sportInfo!) {
                  sportDataList.add(Sports(
                      "${element.strSport}",
                      element.id!.toInt(),
                      element.idSport!.toInt(),
                      element.strSportThumb.toString(),
                      selected: true));
                }

                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => TeamSelectionScreen(*/ /*
                      widget.model,*/ /* sportDataList
                    )));
              }

            }else{
              ///first team flag
              storage.write('userDefaultTeam', event.data!.success!.sportInfo!.first.team!.first.strTeamLogo.toString());
              storage.write('userDefaultTeamName', event.data!.success!.sportInfo!.first.team!.first.toJson());

              List<Map<String, dynamic>> data = [];
              event.data!.success!.sportInfo?.forEach((element) {
                data.add(element.toJson());
              });

              storage.write(sportInfo, data);

              Get.snackbar("Octagon", "You logged in as ${event.data!.success!.name}");

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => TabScreen()));
            }
          }

          break;
        case Status.ERROR:
          print(Status.ERROR);
          Get.snackbar("Login", "invalid email or password");
          break;
        case null:
        // TODO: Handle this case.
      }
    });*/

    // registerBloc.registerStream.listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       break;
    //     case Status.COMPLETED:
    //       registerResponseModel = event.data;
    //       if(registerResponseModel!.error!=null){
    //         // storage.write('token', registerResponseModel!.success!.token.toString());
    //         showToast(message: registerResponseModel?.error??"");
    //         Navigator.pop(context);
    //         // Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPScreen(/*widget.model*/_emailController.text.trim())));
    //       }else{
    //         storage.write('token', registerResponseModel!.success!.token.toString());
    //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> OTPScreen(/*widget.model*/_emailController.text.trim())));
    //         print(event.data);
    //       }
    //       break;
    //     case Status.ERROR:
    //       print(Status.ERROR);
    //       Get.snackbar("Signup", event.message!);
    //       break;
    //   }
    // });

    publishAmplitudeEvent(eventType: 'login $kScreenView');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appBgColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                BlocConsumer(
                    bloc: sportBloc,
                    listener: (context,state){
                      if(state is GetSportListSate){

                          sportListResponseModel = state.sportListResponseModel.data??[];
                          for (SportListResponseModelData element in state.sportListResponseModel.data??[]) {
                            if(element.strSport!=null && element.strSport!.isNotEmpty){
                              sportBloc.add(GetTeamListEvent(term: [element.strSport??""]));
                            }
                          }

                      }
                    },
                    builder: (context,_) {
                    return Text(
                      "${widget.isTeam? "Team ":""}Login",
                      style: whiteColor24BoldTextStyle,
                    );
                  }
                ),
                Text(
                  "Add your details to login",
                  style: greyColor12TextStyle,
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  autovalidateMode: isValidate,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormBox(
                        textEditingController: _emailController,
                        hintText: "Email",
                        suffixIcon: Icon(
                          Icons.email_outlined,
                          color: whiteColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormBox(
                        textEditingController: _passwordController,
                        hintText: "Password",
                        passwordVisible: 1,
                        suffixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: whiteColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                BlocConsumer(
                    bloc: loginBloc,
                    listener: (context, state) {
                      if(state is LoginLoadingBeginState){
                        // onLoading(context);
                        isLoading = true;
                        setState(() {

                        });
                      }
                      if (state is LoginUserState) {
                        // stopLoader(context);
                        isLoading = false;
                        loginResponseModel = state.responseModel;

                        setState(() {

                        });

                        if (loginResponseModel!.error != null) {
                          showToast(message: "Invalid email or Password!");

                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => OTPScreen(
                          //               /*widget.model*/ _emailController.text
                          //                   .trim(),
                          //               isFromLogin: true,
                          //             )));
                        } else if(state.responseModel.success?.name==null){
                          ///social login/register flow
                          storage.write("current_uid",
                              state.responseModel.success!.userId);
                          storage.write('token',
                              state.responseModel.success!.token.toString());

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(
                                        profileData: UserModel(email: state.responseModel.success?.email??""),
                                        isUpdate: false, update: (UserModel data){

                                      },)));

                          ///todo open edit profile screen
                        } else {
                          ///todo parth copy this in verify otp screen.
                          storage.write("current_uid",
                              state.responseModel.success!.userId);
                          storage.write('token',
                              state.responseModel.success!.token.toString());
                          storage.write('country',
                              state.responseModel.success!.country.toString());
                          storage.write('user_name',
                              state.responseModel.success!.name.toString());
                          if(state.responseModel.success?.bio!=null){
                            storage.write('bio', state.responseModel.success!.bio.toString());
                          }

                          storage.write('image_url',
                              state.responseModel.success!.photo.toString());
                          storage.write('email',
                              state.responseModel.success!.email.toString());

                          storage.write(
                              userData, state.responseModel.success!.toJson());

                          setAmplitudeUserProperties();

                          // Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection(widget.model)));

                          if (state.responseModel.success?.sportInfo == null ||
                              state.responseModel.success!.sportInfo!.isEmpty ||
                              state.responseModel.success?.sportInfo?.first
                                      .team ==
                                  null ||
                              state.responseModel.success!.sportInfo!.first
                                  .team!.isEmpty) {
                            if (state.responseModel.success?.sportInfo
                                    ?.isEmpty ??
                                false) {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection(/*widget.model*/)));
                            } else {
                              sportDataList = [];
                              for (var element
                                  in state.responseModel.success!.sportInfo!) {
                                sportDataList.add(Sports(
                                    "${element.strSport}",
                                    element.id!.toInt(),
                                    element.idSport!.toInt(),
                                    element.strSportThumb.toString(),
                                    selected: true));
                              }
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => TeamSelectionScreen( sportDataList
                                  )));
                            }
                          } else {
                            ///first team flag
                            storage.write(
                                'userDefaultTeam',
                                state.responseModel.success!.sportInfo!.first
                                    .team!.first.strTeamLogo
                                    .toString());
                            storage.write(
                                'userDefaultTeamName',
                                state.responseModel.success!.sportInfo!.first
                                    .team!.first
                                    .toJson());

                            List<Map<String, dynamic>> data = [];
                            state.responseModel.success!.sportInfo
                                ?.forEach((element) {
                              data.add(element.toJson());
                            });

                            storage.write(sportInfo, data);

                            Get.snackbar("Octagon",
                                "You logged in as ${state.responseModel.success!.name}");

                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                builder: (context) => TabScreen()), (route) => false,);
                          //   Navigator.pushReplacement(context,
                          // MaterialPageRoute(builder: (context) => TabScreen()));
                          }
                        }
                      }
                      if (state is LoginErrorState) {

                        isLoading = false;
                        setState(() {

                        });
                        Get.snackbar("Login", "invalid email or password");
                        // showSnackBarWithTitleAndText("Alert",state.exception.toString());
                      }
                    },
                    builder: (context, _) {
                      return FilledButtonWidget(isLoading: isLoading,/*widget.model,*/ "Login", () {
                        /*Navigator.push(context,
                          MaterialPageRoute(builder: (context) => TabScreen()));*/
                        if (_emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          if (isValid()) {
                            loginBloc.add(LoginUserEvent(
                              email: _emailController.text,
                              password: _passwordController.text,
                              // loginType: "social",
                              fcmToken: storage.read("fcm_token"),
                            ));
                          }
                        } else {
                          Get.snackbar(
                              AppName, "Please enter Email and Password!");
                        }
                      }, 1);
                    }),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MobileNumberScreen()));
                      },
                      child: Text(
                        "Forget your password ?",
                        style: whiteColor14TextStyle,
                      )),
                ),

                const SizedBox(
                  height: 20,
                ),

                CommonLoginButton(
                  isLogin: true,
                  googlePress: (user) {
                    if (user!=null && user.user != null && user.user!.uid != null) {
                      ///api calling

                      isLoading = true;
                      setState(() {

                      });

                      loginBloc.add(SocialAuthEvent(
                        email: user.user?.email,
                        fcmToken: storage.read("fcm_token"),
                        socialId: user.user?.uid??""
                      ));


                      // loginBloc.add(LoginUserEvent(
                      //     emailOrPhone: user.user?.email??"",
                      //     password: "",
                      //     // loginType: "social",
                      //     fcmToken: getFCMToken(),
                      //     socialId: user.user!.uid.toString(),
                      //     socialType: "google"
                      // ));
                    }
                  },
                  // facebookPress: (user) {
                  //   if (user!=null && user.user != null && user.user!.uid != null) {
                  //
                  //
                  //     // getStorage.write(
                  //     //     "loginName", user.user.displayName ?? "");
                  //     // loginBloc.add(LoginUserEvent(
                  //     //     emailOrPhone: user.user?.email??"",
                  //     //     password: "",
                  //     //     // loginType: "social",
                  //     //     fcmToken: getFCMToken(),
                  //     //     socialId: user.user!.uid.toString(),
                  //     //     socialType: "facebook"
                  //     // ));
                  //     ///login api call
                  //   } else {
                  //     // showToast(user.message??"");
                  //   }
                  // },
                  applePress: (user) async {
                    ///api calling
                    if (user != null) {
                      isLoading = true;
                      setState(() {

                      });

                      appleLoginData = user;
                      loginBloc.add(SocialAuthEvent(
                          email: user.email,
                          fcmToken: storage.read("fcm_token"),
                          socialId: user.userIdentifier,
                      ));

                    } else {
                      // showSnackBarWithTitleAndText(
                      //     "Alert", "Something went wrong, Please try again later!");
                    }
                  },
                ),

                // Row(
                //   children: [
                //     InkWell(
                //       onTap: () async {
                //         Authentication.signOut(context: context).then((value) {
                //           print("go");
                //         });
                //       },
                //       child: Container(
                //         width:
                //         60,
                //         height:
                //         60,
                //         decoration: BoxDecoration(
                //           color: Colors.black,
                //           borderRadius: BorderRadius.circular(30),
                //         ),
                //         child: Center(
                //           child: Text("Logout G", style: TextStyle(color: Colors.white),),
                //         ),
                //       ),
                //     ),
                //     InkWell(
                //       onTap: () async {
                //         Authentication.signInWithGoogle(context: context).then((value) {
                //           print("go");
                //
                //           registerBloc.registerUser(RegisterRequestModel(
                //               name: value?.displayName??"",
                //               mobile: "",
                //               email: value!.email,
                //               cPassword: "88666688",
                //               password: "88666688",
                //               country: ""
                //           ));
                //         });
                //       },
                //       child: Container(
                //         width:
                //         60,
                //         height:
                //         60,
                //         decoration: BoxDecoration(
                //           color: Colors.black,
                //           borderRadius: BorderRadius.circular(30),
                //         ),
                //         child: Center(
                //           child: Text("Google", style: TextStyle(color: Colors.white),),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()));
                    },
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: RichText(
                        text: TextSpan(
                            text: "Don't have an Account?",
                            style: whiteColor14TextStyle,
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignupStepScreen()));
                                  },
                                text: " Sign Up",
                                style: whiteColor16TextStyle,
                              )
                            ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isValid() {
    bool isValid = true;

    if (!emailValidReg.hasMatch(_emailController.text.trim())) {
      Get.snackbar(AppName, "Please enter valid E-mail");
      isValid = false;
    } else

    // if(_mobileController.text.trim().length != 10){
    //   Get.snackbar(AppName, "Please enter valid mobile number");
    //   isValid = false;
    // }else

    ///pass
    if (_passwordController.text.trim().length < 6) {
      Get.snackbar(AppName, "Please enter at least 6 character for password");
      isValid = false;
    }

    return isValid;
  }

// Future<String> signInWithGoogle() async {
//   // Trigger the authentication flow
//   final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
//   print('googleUser ' + googleUser.toString());
//   final GoogleSignInAuthentication googleAuth =
//   await googleUser.authentication;
//
//   // Create a new credential
//   final GoogleAuthCredential credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth.accessToken,
//     idToken: googleAuth.idToken,
//   );
//
//   try {
//     // Once signed in, return the UserCredential
//     var userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//     await updateUserDataToBackend(userCredential);
//     return 'Success';
//   } catch (e) {
//     print(e.toString());
//     return e.toString();
//   }
// }

// Future<String> initiateFacebookLogin() async {
//   var facebookLogin = FacebookLogin();
//   var facebookLoginResult = await facebookLogin.logIn(['public_profile', 'email']);
//
//   switch (facebookLoginResult.status) {
//     case FacebookLoginStatus.error:
//       print('Something went wrong');
//       print(facebookLoginResult.errorMessage);
//       return 'Faild';
//       break;
//     case FacebookLoginStatus.cancelledByUser:
//       print('Something went wrong');
//       return 'Faild';
//       break;
//     case FacebookLoginStatus.loggedIn:
//
//       var graphResponse = await http.get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400)&access_token=${facebookLoginResult.accessToken.token}'));
//
//       var profile = json.decode(graphResponse.body);
//       print(profile.toString());
//       return 'Success';
//       // onLoginStatusChanged(true, profileData: profile);
//       break;
//   }
// }

// Future<void> loginWithApple(BuildContext context) async {
//   if (Platform.isAndroid) {
//     var redirectURL = '';
//     // var clientID = "com.appideas.chatcity";
//     var clientID = 'com.qookit.mobileapp';
//
//     final appleIdCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//         webAuthenticationOptions: WebAuthenticationOptions(
//             clientId: clientID, redirectUri: Uri.parse(redirectURL)));
//
//     final oAuthProvider = OAuthProvider('apple.com');
//     final credential = oAuthProvider.credential(
//       idToken: appleIdCredential.identityToken,
//       accessToken: appleIdCredential.authorizationCode,
//     );
//
//     print(credential);
//   } else {
//     final credential = await SignInWithApple.getAppleIDCredential(
//       scopes: [
//         AppleIDAuthorizationScopes.email,
//         AppleIDAuthorizationScopes.fullName
//       ],
//       webAuthenticationOptions: WebAuthenticationOptions(
//           clientId: 'com.aboutyou.dart_packages.sign_in_with_apple.example',
//           redirectUri: Uri.parse(
//               'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple')),
//       nonce: 'example-nonce',
//       state: 'example-state',
//     );
//
//     final signInWithAppleEndpoint = Uri(
//       scheme: 'https',
//       host: 'flutter-sign-in-with-apple-example.glitch.me',
//       path: '/sign_in_with_apple',
//       queryParameters: <String, String>{
//         'code': credential.authorizationCode,
//         if (credential.givenName != null) 'firstName': credential.givenName,
//         if (credential.familyName != null) 'lastName': credential. familyName,
//         'useBundleId': Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
//         if (credential.state != null) 'state': credential.state,
//       },
//     );
//     final session = await http.Client().post(signInWithAppleEndpoint).then((value) => AuthService().updateUserDataToBackend);
//     print(session);
//   }
// }
}
