import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octagon/main.dart';
import 'package:octagon/screen/login/bloc/login_bloc.dart';
import 'package:octagon/screen/login/bloc/login_event.dart';
import 'package:octagon/screen/login/bloc/login_state.dart';
import 'package:octagon/screen/sport/sport_selection_screen.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/polygon/polygon_border.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import 'package:octagon/utils/colors.dart' as ColorR;
import 'package:octagon/utils/styles.dart' as StylesR;

import '../../networking/model/user_response_model.dart';
import '../../utils/common_image_view.dart';
import '../../utils/constants.dart';


class EditProfileScreen extends StatefulWidget {
  UserModel? profileData;
  Function(UserModel) update;

  bool isUpdate = true;

  EditProfileScreen({Key? key, required this.update, this.profileData, this.isUpdate = true}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  AutovalidateMode isValidate = AutovalidateMode.disabled;

  final ImagePicker _picker = ImagePicker();
  String profilePhoto = "";
  bool isLocalImage = false;
  String bgPhoto = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _countryController = TextEditingController();

  Country? selectedCountry;

LoginBloc loginBloc = LoginBloc();

  @override
  void initState() {
      loginBloc = LoginBloc();


    if (widget.profileData != null) {
      if (widget.profileData?.name != null) {
        _nameController.text = widget.profileData!.name!;
      }
      if (widget.profileData?.email != null) {
        _emailController.text = widget.profileData!.email!;
      }
      if (widget.profileData?.bio != null) {
        _bioController.text = widget.profileData!.bio!;
      }
      if (widget.profileData?.dob != null && !widget.profileData!.dob!.contains("null")) {
        _dobController.text = widget.profileData!.dob!;
      }
      if (widget.profileData?.country != null) {
        _countryController.text = widget.profileData!.country!;
      }
      if(widget.profileData!.photo!=null){
        profilePhoto = widget.profileData!.photo!;
      }
      if (widget.profileData?.background != null) {
        bgPhoto = widget.profileData!.background!;
      }
    }
    super.initState();

    publishAmplitudeEvent(eventType: 'Edit Profile $kScreenView');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appBgColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: appBgColor,
          appBar: AppBar(
            leading: widget.isUpdate ? InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ): null,
            elevation: 0,
            centerTitle: true,
            backgroundColor: appBgColor,
            title: Text(widget.isUpdate?"Edit Profile":"Profile Details", style: whiteColor20BoldTextStyle,),
          ),
          body: BlocConsumer(
            bloc: loginBloc,
            listener: (context,state){
              if(state is LoginLoadingBeginState){
                onLoading(context);
              }
              if(state is LoginLoadingEndState){
                // if(widget.isUpdate){
                //   stopLoader(context);
                // }
              }
              if(state is EditProfileState){


                if(state.updateProfileResponseModel.success?.country!=null){
                  storage.write('country', state.updateProfileResponseModel.success!.country.toString());
                }
                if(state.updateProfileResponseModel.success?.name!=null){
                  storage.write('user_name', state.updateProfileResponseModel.success!.name.toString());
                }
                if(state.updateProfileResponseModel.success?.bio!=null){
                  storage.write('bio', state.updateProfileResponseModel.success!.bio.toString());
                }

                storage.write('image_url', state.updateProfileResponseModel.success!.photo.toString());

                if(state.updateProfileResponseModel.success?.email!=null){
                  storage.write('email', state.updateProfileResponseModel.success!.email.toString());
                }

                setAmplitudeUserProperties();

                if(widget.profileData!=null){
                  widget.profileData!.name = state.updateProfileResponseModel.success!.name.toString();
                  widget.profileData!.photo = state.updateProfileResponseModel.success!.photo.toString();
                  widget.profileData!.bio = state.updateProfileResponseModel.success!.bio.toString();
                  widget.profileData!.dob = state.updateProfileResponseModel.success!.dob.toString();
                  widget.profileData!.country = state.updateProfileResponseModel.success!.country.toString();
                  widget.update.call(widget.profileData!);
                }

                if(widget.isUpdate){
                  showToast(message: "Your profile has been updated successfully!");
                  stopLoader(context);
                  Navigator.pop(context);
                }else{
                  showToast(message: "Your profile has been saved successfully!");
                  stopLoader(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection()));
                }
              }
            },
            builder: (context,_) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Text(
                          "",
                          style: whiteColor24BoldTextStyle,
                        ),
                        Text(
                          "Select your profile photo.",
                          style: greyColor12TextStyle,
                        ),
                        Container(
                            height: 150,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: GestureDetector(
                              onTap: () {
                                showImagePicker(context, onImageSelection:
                                    (ImageSource imageSource) async {
                                  try {
                                    profilePhoto = "";
                                    final pickedFileList = await _picker.pickImage(
                                        source: imageSource, imageQuality: 50);
                                    if (pickedFileList?.path != null) {
                                      setState(() {
                                        profilePhoto = pickedFileList!.path;
                                        isLocalImage = true;
                                      });
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                });
                              },
                              child: buildProfileWidget(),
                            )),
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
                                isMaxLengthEnable: true,
                                maxCharcter: 40,
                                isEnable: !widget.isUpdate,
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
                                textEditingController: _nameController,
                                hintText: "Name",
                                isMaxLengthEnable: true,
                                maxCharcter: 40,
                                suffixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormBox(
                                textEditingController: _bioController,
                                hintText: "Bio",
                                maxCharcter: 150,
                                isMaxLengthEnable: true,
                                suffixIcon: Icon(
                                  Icons.description,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormBox(
                                textEditingController: _dobController,
                                hintText: "DOB",
                                isEnable: false,
                                onClick: () {
                                 showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now().subtract(const Duration(days: 2555)),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now().subtract(const Duration(days: 2555))).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        _dobController.text =
                                        "${value.month}/${value.day}/${value.year}"; // 08/14/2019
                                      });
                                    }
                                  });

                                },
                                suffixIcon: Icon(
                                  Icons.calendar_month_outlined,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormBox(
                                textEditingController: _countryController,
                                hintText: "Country",
                                isEnable: false,
                                onClick: () {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode: true,
                                    // optional. Shows phone code before the country name.
                                    onSelect: (Country country) {
                                      _countryController.text = country.name;
                                      selectedCountry = country;
                                      print('Select country: ${country.displayName}');
                                    },
                                  );
                                },
                                suffixIcon: Icon(
                                  Icons.place_outlined,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        FilledButtonWidget(/*null,*/ widget.isUpdate?"Update Profile":"Save Profile", () {

                          loginBloc.add(EditProfileEvent(
                            name: _nameController.text.trim(),
                            bio: _bioController.text.trim(),
                            country: _countryController.text.trim(),
                            dob: _dobController.text.trim(),
                            profilePic: profilePhoto,
                          ));
                          /*if(_nameController.text.trim().isNotEmpty &&
                              _dobController.text.trim().isNotEmpty &&
                              _bioController.text.trim().isNotEmpty &&
                              profilePhoto.isNotEmpty
                          ){

                          }else{
                            Get.snackbar(AppName, "Please enter valid data!");
                          }*/
                        }, 1),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  void showImagePicker(context,
      {Function(ImageSource imageSource)? onImageSelection}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ColorR.kcBackground,
              border: Border.all(
                color: ColorR.kcLightGreyColor,
                width: 1.0,
              ),
            ),
            child:  Wrap(
              children: <Widget>[
                Column(),
                ListTile(
                    leading:
                        Icon(Icons.photo_library, color: ColorR.kcTealColor),
                    title: Text(
                      "Picker Gallery",
                      style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          color: ColorR.kcIvoryBlackColor),
                    ),
                    onTap: () {
                      onImageSelection?.call(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading:
                      new Icon(Icons.photo_camera, color: ColorR.kcTealColor),
                  title: Text("Picker Camera",
                      style: StylesR.kTextStyleRestaurantInfoTitle),
                  onTap: () {
                    onImageSelection?.call(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                StylesR.verticalSpaceMedium,
                ListTile(
                  title: Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        color: ColorR.kcIvoryBlackColor),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  buildProfileWidget() {
    // CircleAvatar(
    //   backgroundColor: greyColor,
    //   radius: 50,
    //   child: profilePhoto.isEmpty
    //       ? Image.network(widget
    //       .profileData?.success?.user?.photo ??
    //       "https://uifaces.co/our-content/donated/3799Ffxy.jpeg",
    //     fit: BoxFit.cover,
    //     alignment: Alignment.center,
    //     width: 100,
    //     height: 100,)
    //       : Image.file(File(profilePhoto),
    //     fit: BoxFit.cover,
    //     alignment: Alignment.center,
    //     width: 100,
    //     height: 100,
    //     // profileData?.success?.user?.photo??),
    //   ),
    // );

    return Container(
      height: 150,
      width: 150,
      decoration:  const ShapeDecoration(
        shape: PolygonBorder(
          sides: 8,
          rotate: 68,
          side: BorderSide(
            color: Colors.blue,
          ),
        ),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: !isLocalImage
          ? ImageViewWidget(image: widget.profileData?.photo ??
          "https://uifaces.co/our-content/donated/3799Ffxy.jpeg",
        /*fit: BoxFit.cover,
        alignment: Alignment.center,
        width: 150,
        height: 150,*/)
          : Image.file(File(profilePhoto),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        width: 150,
        height: 150,
        // profileData?.success?.user?.photo??),
      )
    );
  }

  bool checkIsEmpty() {
    if(widget.profileData!=null && widget.profileData?.photo!=null
    && widget.profileData!.photo!.isNotEmpty) {
      return true;
    }
    return false;
  }
}
