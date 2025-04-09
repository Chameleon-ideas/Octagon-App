import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:jiffy/jiffy.dart';
import 'package:octagon/screen/common/full_screen_post.dart';
import 'package:octagon/screen/mainFeed/comment_screen.dart';
import 'package:octagon/screen/profile/other_user_profile.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/time_extenstionn.dart';
import 'package:octagon/widgets/follow_button_widget.dart';
import 'package:resize/resize.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import '../model/post_response_model.dart';
import '../utils/chat_room.dart';
import '../utils/polygon/polygon_border.dart';
import 'comment_widget.dart';
import 'default_user_image.dart';

class PostWidgets extends StatefulWidget {
  PostResponseModelData? postData;

  final String? name;
  final DateTime? dateTime;
  final String? post;
  int likes = 0;
  final String? imgUrl;

  bool isInView = false;

  Function onLike;
  Function onSavePost;
  Function onFollow;

  Function? updateData;

  PostWidgets(
      {this.name,
      this.dateTime,
      this.post,
      this.imgUrl,
        this.isInView = false,
      this.postData,
      this.updateData,
      required this.onLike,
      required this.onFollow,
      required this.onSavePost});

  @override
  _PostWidgetsState createState() => _PostWidgetsState();
}

class _PostWidgetsState extends State<PostWidgets> {
  String likedBy = "Liked by";

  ChewieController? _playerController;
  VideoPlayerController? _videoPlayerController;
  bool isCurrentPageOpen = true;

  @override
  void initState() {
    super.initState();

    if (widget.postData != null && widget.postData!.userLikes != null) {
      String temp = "";
      for (var element in widget.postData!.userLikes!) {
        temp = "$element ,";
      }
      if (widget.postData!.userLikes!.isEmpty) {
        likedBy = "";
      }
      likedBy = likedBy /* + temp*/;
    } else {
      likedBy = "";
    }

    if (widget.postData?.videos != null &&
        widget.postData!.videos!.isNotEmpty) {
      initializePlayer(widget.postData!.videos![0].filePath);
    }

    setState(() {});

    currentPage.stream.listen((event) {
      if (event != 0) {
        isCurrentPageOpen = false;
        if(_playerController!=null){
          _playerController!.pause();
          _videoPlayerController!.setVolume(0);
        }
      }else{
        isCurrentPageOpen = true;
      }
    });
  }

  Future initializePlayer(String? data) async {
    _videoPlayerController = VideoPlayerController.network(data!);
    await Future.wait([_videoPlayerController!.initialize()]);

    _playerController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        showControls: false,
        allowMuting: false,
        looping: false);
  }

  @override
  Widget build(BuildContext context) {
    if(_videoPlayerController!=null){
      if(!isMute){
        if(widget.isInView && isCurrentPageOpen){
          _videoPlayerController!.setVolume(1.0);
        }else{
          _videoPlayerController!.setVolume(0);
        }
      }else{
        _videoPlayerController!.setVolume(0);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[

        ///title, description, follow button
        ///image
        if (widget.postData?.images != null && widget.postData!.images!.isNotEmpty)
          AnimatedContainer(
            margin: const EdgeInsets.only(top: 10),
            duration: const Duration(seconds: 2),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///user thumb
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtherUserProfileScreen(
                                      userId: widget.postData?.userId)));
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 80,
                            ),
                            Container(
                              width: 50,
                              height: 65,
                              decoration: BoxDecoration(
                                  color: greyColor,
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(20)),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          widget.postData?.photo ?? ""),
                                      fit: BoxFit.cover)),
                              child: !isProfilePicAvailable(widget.postData?.photo)?
                                      defaultThumb():null
                            ),
                            Positioned(
                              top: 45,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: ShapeDecoration(
                                  color: appBgColor,
                                  shape: PolygonBorder(
                                    sides: 8,
                                    rotate: 68,
                                    side: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                                clipBehavior: Clip.antiAlias,
                                child: OctagonShape(
                                  // bgColor: Colors.black,
                                  child: isTeamLogo()?
                                   CachedNetworkImage(
                                    imageUrl: /*isTeamLogo() ?*/
                                    widget.postData?.sportInfo?.first.team
                                        ?.first.strTeamLogo
                                       /* :
                                    ""*/,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    width: 30,
                                    height: 30,
                                    placeholder: (context, url) => const SizedBox(height: 20),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ):null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.name!.capitalize!,
                                      style: whiteColor16BoldTextStyle),
                                  if (widget.postData?.userId != storage.read("current_uid"))
                                    FollowButton(
                                      text: widget.postData!.isUserFollowedByMe
                                          ? "Following"
                                          : "Follow",
                                      onClick: () {
                                        widget.onFollow();
                                        print("follow");
                                      },
                                    ),
                                ],
                              ),
                              RichText(
                                maxLines: 3,
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                    text: "${(widget.postData?.post ?? "").length > 120?
                                    (widget.postData?.post ?? "").substring(0, 120): (widget.postData?.post ?? "")}",
                                    style: greyColor14TextStyle.copyWith(
                                      color: Colors.white,
                                      // fontSize: 13,
                                    ),
                                    children: [
                                      if((widget.postData?.post ?? "").length > 100)
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                           /* Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => FullScreenPost(
                                                      postData: widget.postData,
                                                      updateData: () {
                                                        widget.updateData!.call();
                                                      },
                                                    )));*/
                                          },
                                        text: " Show More",
                                        style: blueColor12TextStyle,
                                      ),
                                    ]),
                              ),
                              // Text(
                              //   '${(widget.postData?.post ?? "").length > 60?
                              //   (widget.postData?.post ?? "").substring(0, 60): (widget.postData?.post ?? "")} ${(widget.postData?.post ?? "").length > 50? "Show More":""}',
                              //   style: greyColor14TextStyle.copyWith(
                              //     color: Colors.white,
                              //     fontSize: 13,
                              //   ),
                              //   overflow: TextOverflow.clip,
                              //   maxLines: 3,
                              //   textAlign: TextAlign.start,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
          ),

        ///image
        (widget.postData?.images != null && widget.postData!.images!.isNotEmpty)
            ? buildImageView()
            : buildVideoView(),

        Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 4),
          child: Text(
            getDateTime(widget.postData?.createdAt),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ///like comment share and save buttons
        Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap:(){
                                  widget.onLike();
                                },
                                child: Icon(
                                  widget.postData!.isLikedByMe
                                      ? Icons.favorite
                                      : Icons.favorite_outline_outlined,
                                  color: widget.postData!.isLikedByMe
                                      ? Colors.red
                                      : greyColor,
                                  size: 25,
                                ),
                              ),
                              /*AnimatedIconButton(
                                onPressed: () {
                                  print('all icons pressed');
                                },
                                splashRadius: 1,
                                padding: EdgeInsets.zero,
                                size: 20,
                                animationDirection: AnimationDirection.forward(),
                                icons: [
                                  AnimatedIconItem(
                                    icon: Icon(
                                      widget.postData!.isLikedByMe
                                          ? Icons.favorite
                                          : Icons.favorite_outline_outlined,
                                      color: widget.postData!.isLikedByMe
                                          ? Colors.red
                                          : greyColor,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      widget.onLike();
                                    },
                                  ),
                                  const AnimatedIconItem(
                                    icon: Icon(Icons.favorite_rounded,
                                        color: Colors.red, size: 25),
                                  ),
                                ],
                              ),*/
                               Padding(
                                 padding: const EdgeInsets.all(2.0),
                                 child: Text(
                                  "${widget.postData?.likes ?? 0} likes",
                                  style: whiteColor12TextStyle,
                                                               ),
                               )
                            ],
                          ),
                        ),
                        // if ("${widget.postData?.comment}" == "0")
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                GestureDetector(
                                  child: Icon(
                                    Icons.mode_comment_outlined,
                                    color: greyColor,
                                    size: 25,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CommentScreen(
                                                captionTxt:
                                                    widget.postData?.title ?? "",
                                                name: widget.name!,
                                                profilePic: widget.imgUrl ?? "",
                                                postData: widget.postData))).then((_){
                                                  if(widget.updateData!=null){
                                                    print("fas");
                                                    widget.updateData!.call();
                                                  }
                                    });
                                  },
                                ),
                                Text(
                                  "${widget.postData?.comments?.length}",
                                  style: whiteColor12TextStyle,
                                )
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                child: Transform.rotate(
                                  angle: 330 * 3.14 / 185,
                                  child: Icon(
                                    Icons.send_outlined,
                                    color: greyColor,
                                    size: 23,
                                  ),
                                ),
                                onTap: () {
                                  Share.share(
                                      'check out this post:- https://octagonapp.com/post/${widget.postData!.id}',
                                      subject: 'Octagon');
                                },
                              ),
                              Text(
                                " ",
                                style: whiteColor12TextStyle,
                              )
                            ],
                          ),
                        ),
                      ]),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    widget.postData!.isSaveByMe
                        ? Icons.bookmark
                        : Icons.bookmark_border_outlined,
                    color: greyColor,
                    size: 30,
                  ),
                  onPressed: () {
                    widget.onSavePost();
                    print('on save post to favorite');
                  },
                ),
              ],
            )),

        ///first few comments
        if (widget.postData?.comments != null &&
            widget.postData!.comments!.isNotEmpty)
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 10, bottom: 25),
            child: Row(
              children: [
                Container(
                  height: 35,
                  width: 35,
                  decoration: ShapeDecoration(
                    // color: appBgColor,
                    shape: PolygonBorder(
                      sides: 8,
                      rotate: 68,
                      side: BorderSide(
                        color: amberColor,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: widget.postData?.comments?.first.users != null
                      ?
                  CachedNetworkImage(
                    imageUrl: widget.postData?.comments?.first.users?.photo ??
                        "",
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: 26,
                    height: 26,
                    placeholder: (context, url) => const SizedBox(height: 20),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ):null,
                ),
                /*OctagonShape(
                  child: widget.postData?.comments?.first.users == null
                      ? null
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: 100,
                          height: 100,
                          imageUrl:  widget.postData?.comments?.first.users?.photo ??
                          "",
                          placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                  height: 35,
                  width: 30,
                ),*/
                Expanded(
                  child: RichText(
                    text: TextSpan(
                        text:
                            " ${widget.postData?.comments?.first.users?.name}".capitalize!,
                        style: whiteColor16BoldTextStyle,
                        children: [
                          TextSpan(
                            text:
                                " ${widget.postData?.comments?.first.comment}",
                            style: whiteColor12TextStyle,
                          )
                        ]),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(left: 10),
                //   child: Text("${widget.postData?.comments?.first.users?.name}: ${widget.postData?.comments?.first.comment}",style: TextStyle(
                //     color: Colors.white
                //   ),overflow: TextOverflow.clip,),
                // ),
              ],
            ),
          )
      ],
    );
  }

  Widget buildLikedUserProfile({String imgUrl = "", double leftSide = 0.0}) {
    return Positioned(
      left: leftSide,
      child: CircleAvatar(
        backgroundColor: appBgColor,
        radius: 15,
        child: CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(imgUrl),
        ),
      ),
    );
  }

  Widget buildLikedBy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Stack(
              //alignment:new Alignment(x, y)
              children: widget.postData!.userLikes!
                  .map((e) => buildLikedUserProfile(imgUrl: ""))
                  .toList(),
            ),
          ),
          Expanded(
              child: Text(
            likedBy,
            style: whiteColor12TextStyle,
          ))
        ],
      ),
    );
  }

  bool isPostImageAvailable() {
    bool isAvailable = false;
    if (widget.postData?.images != null) {
      if (widget.postData?.images?.isNotEmpty ?? false) {
        isAvailable = true;
      }
    }
    return isAvailable;
  }

  String getDateTime(DateTime? createdAt) {
    return timeAgo(Jiffy.parse((createdAt ?? DateTime.now()).toString()).dateTime);
  }

  String timeAgo(DateTime dateTime) {
    // Convert the UTC time to local time
    DateTime localDateTime = dateTime.toLocal();

    Duration diff = DateTime.now().difference(localDateTime);

    if (diff.inSeconds < 60) {
      return "just now";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    } else if (diff.inDays < 30) {
      int weeks = (diff.inDays / 7).floor();
      return "$weeks week${weeks == 1 ? '' : 's'} ago";
    } else if (diff.inDays < 365) {
      int months = (diff.inDays / 30).floor();
      return "$months month${months == 1 ? '' : 's'} ago";
    } else {
      int years = (diff.inDays / 365).floor();
      return "$years year${years == 1 ? '' : 's'} ago";
    }
  }


  buildImageView() {
    return Container(
      color: Colors.transparent/*Colors.grey[50]*/,
      // width: double.infinity,
      // height: 400,
      child: GestureDetector(
        onDoubleTap: () {
          setState(() {
            // widget.postData!.likes++;
            widget.onLike();
            // widget.likes++;
          });
        },
        onTap: () {
          goToFullScreenPost();
        },
        child: isPostImageAvailable()
            ? CachedNetworkImage(
              imageUrl: widget.postData?.images?.first.filePath ?? "",
              fit: BoxFit.contain,
              placeholder: (context, url) =>  SizedBox(height:30.vh,
                  width: 100.vw, child: const Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ): AnimatedContainer(duration: const Duration(seconds: 2),
          color: appBgColor,
          height:55.vh,
          width: 100.vw,
        ),
      ),
    );
  }

  buildVideoView() {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          // widget.postData!.likes++;
          widget.onLike();
          // widget.likes++;
        });
      },
      onTap: () {
        goToFullScreenPost();
      },
      child: SizedBox(
        height: (_playerController != null &&
            _playerController!.videoPlayerController.value.isInitialized)?_playerController!
            .videoPlayerController.value.size.height:620,
        width: 100.vw,
        child: Stack(
              children: [
                (_playerController != null &&
                    _playerController!.videoPlayerController.value.isInitialized) ?
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  bottom: 0,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100.vw,
                      height: _playerController!
                          .videoPlayerController.value.size.height,
                      child: Chewie(
                        controller: _playerController!,
                      ),
                    ),
                  )
                ): AnimatedContainer(duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.only(top: 80),
                  color: Colors.transparent,
                  height:30.vh,
                  width: 100.vw,
                  child: const Center(child: CircularProgressIndicator()),
                  // height: 10,
                ),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ///100 height taken
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///user thumb
                            GestureDetector(
                              onTap: () {
                                /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OtherUserProfileScreen(
                                            userId: widget.postData?.userId)));*/
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 80,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 65,
                                    decoration: BoxDecoration(
                                        color: greyColor,
                                        borderRadius:
                                        const BorderRadius.all(Radius.circular(20)),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                widget.postData?.photo ?? ""),
                                            fit: BoxFit.cover)),
                                  ),
                                  Positioned(
                                    top: 45,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: const ShapeDecoration(
                                        color: Colors.black,
                                        shape: PolygonBorder(
                                          sides: 8,
                                          rotate: 68,
                                          side: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        imageUrl: isTeamLogo() ?
                                        widget.postData?.sportInfo?.first.team
                                            ?.first.strTeamLogo
                                            :
                                        "",
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                        width: 30,
                                        height: 30,
                                        placeholder: (context, url) => const SizedBox(height: 20),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(widget.name!,
                                        style: whiteColor16BoldTextStyle),
                                    Text(
                                      widget.postData?.post ?? "",
                                      style: greyColor14TextStyle.copyWith(
                                          color: Colors.white
                                      ),
                                      overflow: TextOverflow.clip,
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (widget.postData?.userId != storage.read("current_uid"))
                            SizedBox(
                              width: 100,
                              child: FollowButton(
                                text: widget.postData!.isUserFollowedByMe
                                    ? "Following"
                                    : "Follow",
                                onClick: () {
                                  widget.onFollow();
                                  print("follow");
                                },
                              ),
                            ),
                          Text(
                            getDateTime(widget.postData?.createdAt),
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ]),

                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Icon(
                        isMute
                            ? Icons.volume_off
                            : Icons.volume_up,
                        color: greyColor,
                        size: 25,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if(isMute){
                          isMute = false;
                        }else {
                          isMute = true;
                        }
                      });
                      if(_playerController!=null){
                        _playerController!.setVolume(isMute? 1 : 0);
                      }
                    },
                  ),
                ),
              ],
            )
      ),
    );
  }

  isTeamLogo() {
    if(widget.postData!=null &&widget.postData?.sportInfo!=null
    &&widget.postData!.sportInfo!.isNotEmpty &&
        widget.postData?.sportInfo?.first.team
            !=null && widget.postData!.sportInfo!.first.team!.isNotEmpty &&
    widget.postData?.sportInfo?.first.team
        ?.first.strTeamLogo!=null){
      return true;
    }else{
      return false;
    }

  }

  void goToFullScreenPost() {
    if(_videoPlayerController!=null){
      _videoPlayerController!.position.then((value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FullScreenPost(
                  postData: widget.postData,
                  videoDuration: value,
                  videoPlayerController: _videoPlayerController,
                  updateData: () {
                    widget.updateData!.call();
                  },
                )));
      });
    }else{
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullScreenPost(
                postData: widget.postData,
                videoPlayerController: _videoPlayerController,
                updateData: () {
                  widget.updateData!.call();
                },
              )));
    }
  }
}
