import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/utils/colors.dart' as ColorR;
import 'package:octagon/utils/styles.dart' as StylesR;

import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../../networking/response.dart';
import '../../utils/analiytics.dart';
import '../../utils/constants.dart';
import '../../utils/image_picker.dart';
import '../../utils/string.dart';
import '../../widgets/filled_button_widget.dart';
import '../../widgets/video_editor_screen.dart';

class PostFile {
  String filePath = "";
  bool isVideo = false;

  PostFile({this.filePath = "", this.isVideo = false});
}

class CreatePostScreen extends StatefulWidget {
  bool isFromChat = false;

  CreatePostScreen({Key? key, this.isFromChat = false}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
   PostBloc postBloc  = PostBloc();

  AutovalidateMode isValidate = AutovalidateMode.disabled;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _postTitleController =
      TextEditingController(text: "Octagon");

  List<PostFile> files = [];

  final ImagePicker _picker = ImagePicker();
  bool isCommentEnable = false;
  bool isVideo = false;

  bool isLoading = false;

  List<String> imagePath = [];

  String dropdownValue = 'Post';
  var items = [
    'Post',
    'Story',
    'Reels',
  ];

  @override
  void initState() {
    super.initState();

    postBloc = PostBloc();

/*    postBloc.createPostDataStream.listen((event) {
      setState(() {
        switch (event.status) {
          case Status.LOADING:
            isLoading = true;
            break;
          case Status.COMPLETED:
            setState(() {
              event.data!;
            });
            showToast(message: "Post created successfully!");
            isLoading = false;
            Navigator.pop(context, true);
            print(event.data);
            break;
          case Status.ERROR:
            isLoading = false;
            print(Status.ERROR);
            break;
          case null:
            // TODO: Handle this case.
        }
      });
    });*/

    publishAmplitudeEvent(eventType: 'Create Post $kScreenView');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appBgColor,
      child: WillPopScope(
        onWillPop: () {
          if (isLoading) {
            showToast(message: "Posting is on going please wait..");
          }
          return Future(() => !isLoading);
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: appBgColor,
            appBar: AppBar(
              backgroundColor: appBgColor,
              elevation: 0.0,
              title: Text(
                "Create Post",
                style: whiteColor20BoldTextStyle,
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: BlocConsumer(
                bloc: postBloc,
                listener: (context,state){
                  if(state is PostLoadingBeginState){
                    // onLoading(context);
                    setState(() {
                      isLoading = true;
                    });
                  }
                  if(state is PostErrorState){
                    // stopLoader(context);
                    setState(() {
                      isLoading = false;
                    });
                  }
                  if(state is CreatePostState){
                    // stopLoader(context);
                    showToast(message: "Post created successfully!");

                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context, true);
                  }
                },
                builder: (context,_) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 36,
                          ),
                          // Text(
                          //   "Add your $dropdownValue!",
                          //   style: greyColor12TextStyle.copyWith(
                          //     color: Colors.white
                          //   ),
                          // ),
                          const SizedBox(
                            height: 36,
                          ),
                          Form(
                            autovalidateMode: isValidate,
                            child: Column(
                              children: [
                                // const SizedBox(
                                //   height: 20,
                                // ),
                                // TextFormBox(
                                //   textEditingController: _postTitleController,
                                //   hintText: "Post title",
                                //   suffixIcon: Icon(
                                //     Icons.title,
                                //     color: whiteColor,
                                //     size: 20,
                                //   ),
                                // ),
                                buildThumbnailView(),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormBox(
                                  textEditingController: _descriptionController,
                                  hintText: "Description",
                                  maxLines: 5,
                                  isMaxLengthEnable: true,
                                  isIconEnable: false,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),

                                // buildDropDownButton(),
                                if (!widget.isFromChat)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        "Comment ${!isCommentEnable ? 'Enabled' : 'Disabled'}",
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      commentSwitch(),
                                    ],
                                  ),
                                FilledButtonWidget(isLoading: isLoading,
                                    "Create $dropdownValue", () {
                                      if (!isLoading) {
                                        if (files
                                            .isNotEmpty /*_descriptionController.text.trim().isNotEmpty &&
                                _postTitleController.text.trim().isNotEmpty*/
                                        ) {
                                          if (widget.isFromChat) {
                                            Navigator.pop(context, [
                                              !isVideo,
                                              files,
                                              _descriptionController.text.trim()
                                            ]);
                                          } else {
                                            /* postBloc.createPost(
                                              postTitle:
                                                  _postTitleController.text.trim(),
                                              description: _descriptionController
                                                  .text
                                                  .trim(),
                                              isCommentEnable: isCommentEnable,
                                              postType:
                                                  items.indexOf(dropdownValue) + 1,
                                              photos: isVideo ? [] : files,
                                              videos: isVideo ? files : []);*/
                                            postBloc.add(CreatePostEvent(
                                                postTitle:
                                                _postTitleController.text.trim(),
                                                description: _descriptionController
                                                    .text
                                                    .trim(),
                                                isCommentEnable: isCommentEnable,
                                                postType:
                                                items.indexOf(dropdownValue) + 1,
                                                photos: isVideo ? [] : files,
                                                videos: isVideo ? files : []
                                            ));
                                          }
                                        } else {
                                          Get.snackbar(
                                              AppName, "Please enter valid data!");
                                        }
                                      } else {
                                        showToast(
                                            message:
                                            "Posting is on going please wait..");
                                      }
                                }, 1)
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildThumbnailView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTitles("Thumbnails"),
        Flexible(
            fit: FlexFit.loose,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildEmptyImageView(context,
                    onImagePicker: (List<String> imageItems, bool isVideo) {
                  setState(() {
                    for (var element in imageItems) {
                      files.add(PostFile(filePath: element, isVideo: isVideo));
                    }
                  });
                  // bloc.events.setImages(images);
                }),
                Expanded(
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    children: List.generate((files.length), (index) {
                      /*if (index == files.length) {
                        return buildEmptyImageView(context, onImagePicker:
                            (List<String> imageItems, bool isVideo) {
                          setState(() {
                            imageItems.forEach((element) {
                              files.add(PostFile(
                                  filePath: element, isVideo: isVideo));
                            });
                          });
                          // bloc.events.setImages(images);
                        });
                      } else*/ {
                        PostFile uploadModel = files[index];
                        return buildImageView(uploadModel, onDelete: () {
                          setState(() {
                            files.removeAt(index);
                            // bloc.events.setImages(images);
                          });
                        });
                      }
                    }),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  Widget buildTitles(String text) {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ));
  }

  Widget buildEmptyImageView(BuildContext context,
      {required Function(List<String> list, bool isVideo) onImagePicker}) {
    return Container(
      height: 95,
      width: 95,
      padding: EdgeInsets.all(12),
      child: DottedBorder(
          dashPattern: [4, 4],
          strokeWidth: 1,
          strokeCap: StrokeCap.round,
          borderType: BorderType.Rect,
          color: ColorR.kcLightGreyColor,
          child: Center(
            child: IconButton(
              color: ColorR.kcMediumGreyColor,
              icon: Icon(Icons.cloud_upload_outlined),
              onPressed: () async {
                showImagePicker(context,
                    onImageSelection: (ImageSource? imageSource) async {
                  try {
                    List<Uint8List> imageItems = [];

                    if (imageSource == null) {
                      isVideo = true;

                      final pickedFileList = await _picker.pickVideo(
                          source: ImageSource.gallery,
                          maxDuration: const Duration(seconds: 120));
                      if (pickedFileList?.path != null) {
                        imagePath.add(pickedFileList!.path);
                        await pickedFileList.readAsBytes().then((value) {
                          imageItems.add(value);
                        });
                      }
                    } else if (imageSource == ImageSource.camera) {
                      isVideo = false;

                      final pickedFileList = await _picker.pickImage(
                          source: imageSource, imageQuality: 50);
                      if (pickedFileList?.path != null) {
                        imagePath.add(pickedFileList!.path);
                        await pickedFileList.readAsBytes().then((value) {
                          imageItems.add(value);
                        });
                      }
                    } else {
                      isVideo = false;

                      final pickedFileList =
                          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                      if (pickedFileList != null) {
                        // pickedFileList.map((file) => file.readAsBytes()).toList();
                        // pickedFileList.map((file) => file.readAsBytes());
                        imagePath.add(pickedFileList.path);
                        // for (var element in pickedFileList) {
                        //   imagePath.add(element.path);
                        //   await   element.readAsBytes().then((value) {
                        //     imageItems.add(value);
                        //   });
                        // }

                        await pickedFileList.readAsBytes().then((value) {
                          imageItems.add(value);
                        });
                      }
                    }
                    if (mounted && imageItems[0] != null) {
                      if (isVideo) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                VideoEditor(file: File(imagePath[0])),
                          ),
                        ).then((value) {
                          if (value != null) {
                            onImagePicker([value], isVideo);
                          }
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageEditor(
                              image: imageItems[0],
                              // <-- Uint8List of image
                              // allowCamera: false,
                              // allowGallery: false,
                              savePath:
                                  Directory.fromUri(Uri.file(imagePath[0])).toString(),
                              // appBarColor: Colors.blue,
                              // bottomBarColor: Colors.blue,
                            ),
                          ),
                        ).then((value) {
                          if (value != null) {
                            saveImage(value).then((value) {
                              onImagePicker([value], isVideo);
                            });
                          }
                        });
                      }
                    }
                  } catch (e) {
                    print(e);
                  }
                });
              },
            ),
          )),
    );
  }

  Widget buildImageView(PostFile uploadModel, {required Function() onDelete}) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Stack(
        children: <Widget>[
          FutureBuilder(
              future: getImagePath(uploadModel.filePath ?? "",
                  isVideo: uploadModel.isVideo),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          width: 96,
                          height: 96,
                          child: Image.file(File("${snapshot.data!}"),
                              fit: BoxFit.fill)),
                    ),
                  );
                } else {
                  return Container(
                    width: 96,
                    height: 96,
                    color: Colors.transparent,
                    child: Image.file(File(uploadModel.filePath),
                        fit: BoxFit.fill),
                  );
                }
              }),
          Positioned(
            right: 2,
            top: 4,
            child: GestureDetector(
              onTap: () {
                onDelete();
              },
              child: CircleAvatar(
                  radius: 10.0,
                  backgroundColor: ColorR.kcLightGreyColor,
                  child:
                      Icon(Icons.close, color: ColorR.kcWhiteColor, size: 16)),
            ),
          ),
        ],
      ),
    );
  }

  buildDropDownButton() {
    return DropdownButton(
      value: dropdownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items, style: TextStyle(color: Colors.grey)),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
    );
  }

  commentSwitch() {
    return Switch(
      onChanged: (bool value) {
        setState(() {
          isCommentEnable = value;
        });
      },
      value: isCommentEnable,
    );
  }
}

Future<String> saveImage(Uint8List value) async {
  ///temp path of directory
  final Directory duplicateFilePath = await getTemporaryDirectory();

  ///saving image to temp path
  await XFile.fromData(value).saveTo(duplicateFilePath.path + "octagon.jpeg");
  return duplicateFilePath.path + "octagon.jpeg";
}
