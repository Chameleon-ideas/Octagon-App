import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:video_player/video_player.dart';

import '../../model/post_response_model.dart';
import '../../networking/response.dart';
import 'option_screen.dart';

class ContentScreen extends StatefulWidget {
  PostResponseModelData? postData;
  Function? updateData;
  Duration? videoDuration;
  var userId;

  bool isFromChat = false;
  VideoPlayerController? videoPlayerController;

  ContentScreen({Key? key, this.postData,this.videoDuration, this.updateData,
    this.isFromChat = false, required this.userId, this.videoPlayerController}) : super(key: key);

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  PostBloc postBloc = PostBloc();
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isVideo = false;
  bool isMute = false;

  @override
  void initState() {
    super.initState();
    postBloc = PostBloc();
/*
    postBloc.likePostDataStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          setState(() {
            event.data!.success.favorite;
          });

          widget.updateData!.call();

          // getHomePageData();
          print(event.data);
          break;
        case Status.ERROR:
          print(Status.ERROR);
          break;
        case null:
          // TODO: Handle this case.
      }
    });

    postBloc.followUserDataStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          setState(() {
          });
          // getHomePageData();
          widget.updateData!.call();

          print(event.data);
          break;
        case Status.ERROR:
          print(Status.ERROR);
          break;
        case null:
          // TODO: Handle this case.
      }
    });

    postBloc.reportUserDataStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          setState(() {
          });
          widget.updateData!.call();
          showToast(message: "You just report this post!, Thanks we will get back to you ASAP!");

          print(event.data);
          break;
        case Status.ERROR:
          print(Status.ERROR);
          break;
        case null:
          // TODO: Handle this case.
      }
    });

    postBloc.deleteUserPostDataStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          setState(() {
            event.data!;
          });

          widget.updateData!.call();

          print(event.data);
          break;
        case Status.ERROR:
          print(Status.ERROR);
          break;
        case null:
          // TODO: Handle this case.
      }
    });*/

    if(widget.postData?.videos!=null && widget.postData!.videos!.isNotEmpty){
      isVideo = true;
      initializePlayer(widget.postData?.videos?.first);
    }
  }

  Future initializePlayer(ImageData? data) async {
    if(widget.videoPlayerController != null){
      _videoPlayerController = widget.videoPlayerController!;
    }else{
      _videoPlayerController = VideoPlayerController.network(data!.filePath!);
      await Future.wait([_videoPlayerController.initialize()]);
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      showControls: false,
      allowMuting: false,
      looping: true,
      startAt: widget.videoDuration
    );
    setState(() {});
  }

  @override
  void dispose() {
    if(isVideo){
      if(widget.videoPlayerController == null){
        _videoPlayerController.dispose();
      }
      _chewieController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        (_chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized) || !isVideo
            ? GestureDetector(
          onDoubleTap: () {
            setState(() {
              ///double tap like button pressed
            });
          },
          child: isVideo ? Chewie(
            controller: _chewieController!,
          ) : isPostImageAvailable()?

          CachedNetworkImage(
            imageUrl: widget.postData?.images?.first.filePath ??
                "",
            alignment: Alignment.center,
            placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ):Container(
            color: purpleColor,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading...')
          ],
        ),
          // Center(
          //   child: GestureDetector(
          //     onDoubleTap: (){
          //       ///on like button pressed
          //       postBloc.likePost(postId: widget.postData!.id!, isFavorite: !widget.postData!.isLikedByMe);
          //       setState(() {
          //         widget.postData?.isLikedByMe = !widget.postData!.isLikedByMe;
          //       });
          //     },
          //       child: LikeIcon(widget.postData?.isLikedByMe??false)),
          // ),
        BlocConsumer(
          bloc: postBloc,
          listener: (context,state){
            if(state is PostLoadingBeginState){
              onLoading(context);
            }
            if(state is PostLoadingEndState){
              stopLoader(context);
            }
            if(state is DeletePostState){
              widget.updateData!.call();
            }
            if(state is FollowUserState){
              widget.updateData!.call();
            }
            if(state is LikePostState){
              widget.updateData!.call();
            }
            if(state is ReportPostState){
              widget.updateData!.call();
              showToast(message: "You just report this post!, Thanks we will get back to you ASAP!");
            }
          },
          builder: (context,_) {
            return OptionsScreen(postData: widget.postData,
              isMute: isMute,
              isVideo: isVideo,
              isFromChat: widget.isFromChat,
              isMyPost: widget.postData!.userId == widget.userId,
              onMute: (){
                isMute = !isMute;
                if(_videoPlayerController!=null){
                  _videoPlayerController.setVolume(isMute?0:1);
                }
              },
              onReport: (String value){
                //postBloc.reportUserPost(title: value, contentId: widget.postData!.id!);
                postBloc.add(ReportPostEvent(
                    title: value.toString(), contentId: widget.postData!.id!.toString(),type: "1"
                ));
              },
              onDeletePostPress: (){
                //postBloc.deleteUserPost(postId: widget.postData!.id!);
                postBloc.add(DeletePostEvent(
                  postId: widget.postData!.id!.toString()
                ));
              },
              onFollowPress: (){
              //postBloc.followUser(isFollowed: !widget.postData!.isUserFollowedByMe, userId: widget.postData!.userId!);
                postBloc.add(FollowUserEvent(
                  followId: !widget.postData!.isUserFollowedByMe ?"1":"0",
                  follow: widget.postData!.userId!.toString()
                ));
              setState(() {
                widget.postData!.isUserFollowedByMe = !widget.postData!.isUserFollowedByMe;
              });
            }, onLikePress: (){
              //postBloc.likePost(postId: widget.postData!.id!, isFavorite: !widget.postData!.isLikedByMe);
                postBloc.add(LikePostEvent(
                    contentId: widget.postData!.id.toString(),
                    isLike: widget.postData!.isLikedByMe ? "1" :"0",
                    type: widget.postData!.type.toString()));
              setState(() {
                widget.postData!.isLikedByMe = !widget.postData!.isLikedByMe;
              });
            },);
          }
        )
      ],
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
}


class LikeIcon extends StatelessWidget {
  bool isLikedByMe = false;
  LikeIcon(isLikedByMe);

  Future<int> tempFuture() async {
    return Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: tempFuture(),
        builder: (context, snapshot) =>
        snapshot.connectionState != ConnectionState.done
            ? Icon(Icons.favorite, size: 110, color: isLikedByMe?redColor:greyColor,)
            : SizedBox(),
      ),
    );
  }
}