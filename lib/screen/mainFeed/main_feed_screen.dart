import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/post_container_widget.dart';
import 'package:octagon/widgets/story_widget.dart';
import 'package:resize/resize.dart';
import 'package:share_plus/share_plus.dart';

import '../../main.dart';
import '../../model/post_response_model.dart';
import '../../model/team_list_response.dart';
import '../../networking/model/response_model/SportInfoModel.dart';
import '../../networking/response.dart';
import '../../utils/analiytics.dart';
import '../../utils/constants.dart';
import '../../utils/string.dart';
import '../chat_network/bloc/chat_bloc.dart';
import '../common/create_post_screen.dart';
import '../tabs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isMorePageAvailable = false;
  List<PostResponseModelData> postDataList = [];
  PostBloc postBloc = PostBloc();
  ChatBloc chatBloc = ChatBloc();
  var scrollController = ScrollController();
  var teamsScrollController = ScrollController();

  List<TeamData> sportsListing = [];
  List<TeamData> team = [];

  int currentPageNo = 1;

  bool visible = false;

  bool isRefreshHome = false;
  bool isStoryVisible = true;

  @override
  void initState() {
    super.initState();
    postBloc = PostBloc();
    scrollController.addListener(pagination);
    postBloc.add(GetUserTeamEvent());///local read
    getHomePageData();

    chatBloc.roomDataStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          if (event.data != null) {
            // team.add(event.data);
            for(TeamData data in event.data){
              if (!team.any((val) => val.id == data.id)) {
                team.add(data);
              }
            }
            setState(() {

            });
            print(team);
          }

          break;
        case Status.ERROR:
          print(Status.ERROR);
          break;
        case null:
        // TODO: Handle this case.
      }
    });

    currentPage.stream.listen((event) {
      if (event == 0) {

        bool tempMute = isMute;

        isMute = true;
        scrollController.jumpTo(0);
        teamsScrollController.jumpTo(0);
        isMute = tempMute;

        //     .then((value) {
        //   isMute = tempMute;
        // });
      }
    });
    publishAmplitudeEvent(eventType: 'Home $kScreenView');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     Navigator.push(context, MaterialPageRoute(builder: (context) =>
      //         GroupCreationScreen(update: (UserModel ) {  },)));
      //   },
      // ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.camera_alt,color: Colors.white,),
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreatePostScreen()))
                .then((value) {
              if (value != null) {
                isRefreshHome = true;
                postDataList.clear();
                getHomePageData();
              }
            });
          },
        ),
        backgroundColor: appBgColor,
        elevation: 0.0,
        title: Text(
          "Octagon",
          style: whiteColor20BoldTextStyle.copyWith(fontSize: 22,
          fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Share.share(
                  'My Favourite app for sports https://octagonapp.com/app-download');

              ///${Platform.isIOS ? "https://apps.apple.com/us/app/octagon-app/id1673110067":"https://play.google.com/store/apps/details?id=com.octagon.app"}
            },
            child: Container(
              color: Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
              child: const Icon(
                Icons.near_me_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          )
        ],
      ),
      body: BlocConsumer(
          bloc: postBloc,
          listener: (context, state) {
            if(state is PostLoadingBeginState){
              // onLoading(context);
            }
            if(state is PostLoadingEndState){
              // stopLoader(context);
            }

            if (state is GetPostState) {
              if (isRefreshHome) {
                postDataList.clear();
                // storiesDataList.clear();
              }

              if (state.postResponseModel.success != null) {
                for (var element in state.postResponseModel.success!) {
                  // if(element.type == "1"){
                  if (postDataList
                          .indexWhere((data) => data.post == element.post) ==
                      -1) {
                    postDataList.add(element);
                  } else {
                    print("${element.title} post drop from listing!");
                  }
                  // }else if(element.type == "2"){
                  // storiesDataList.add(element);
                  // }
                }
                isMorePageAvailable = state.postResponseModel.more ?? false;
              }

              isRefreshHome = false;
            }
            if(state is UserTeamState){

              sportsListing = state.data;

              var data = storage.read(sportInfo);
              int sportId = 0;
              if (data != null) {
                for (var element in (data as List)) {
                  SportInfo value = SportInfo.fromJson(element);
                  sportId = value.idSport ?? 0;
                }
              }

              setState(() {
                team = [];
                for (var element in sportsListing) {
                  element.sportId = sportId;
                  team.add(element);
                }

                print(team);
                ///get all teams which are related to Users selected sports.
                if(team.firstOrNull!=null){
                  chatBloc.getChatRooms(team[0]);
                }
              });
            }
          },
          builder: (context, _) {
            return RefreshIndicator(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 100.vw,
                    height: team.isNotEmpty && isStoryVisible ? 12.vh : 0,
                    margin: EdgeInsets.only(bottom: 2.vh),
                    child: ListView.builder(
                        addAutomaticKeepAlives: true,
                        scrollDirection: Axis.horizontal,
                        controller: teamsScrollController,
                        itemCount: team.length,
                        itemBuilder: (context, int index) {
                          return FacebookCardStory(
                              isUserSelected: index == 0,
                              roomId: "${team[index].id}" ?? "",
                              profile_image: team[index].strTeamLogo ?? "",
                              board_image: team[index].strTeamBadge ?? "",
                              isVisible:
                                  true /*index == 0 ? visible = true : false*/,
                              /*user_name: */ /*index == 0 ? "Add your story" : */ /*
                              team[index].strSport ?? "",*/
                              sportInfo: team[index]);
                        }),
                  ),
                  Expanded(
                    child: InViewNotifierList(
                      addAutomaticKeepAlives: true,
                      controller: scrollController,
                      itemCount: postDataList.length,
                      isInViewPortCondition: (double deltaTop,
                          double deltaBottom, double vpHeight) {
                        return deltaTop < (1 * vpHeight) &&
                            deltaBottom > (0.8 * vpHeight);
                      },
                      shrinkWrap: true,
                      builder: (BuildContext context, int index) {
                        return InViewNotifierWidget(
                            id: '$index',
                            builder: (BuildContext context, bool isInView, _) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) => setState(() {
                                        if (scrollController.position.pixels ==
                                            0) {
                                          isStoryVisible = true;
                                        } else {
                                          isStoryVisible = false;
                                        }
                                      }));

                              return PostWidgets(
                                name: postDataList[index].userName,
                                //dateTime: postData[index].timestamp!.toDate(),
                                post: postDataList[index].post,
                                postData: postDataList[index],
                                isInView: isInView,
                                // imgUrl: getThumbImage(homeDataList[index].images),
                                onLike: () {
                                  setState(() {
                                    if(postDataList[index].isLikedByMe){
                                      postDataList[index].likes = postDataList[index].likes - 1;
                                    }else{
                                      postDataList[index].likes = postDataList[index].likes + 1;
                                    }

                                    postDataList[index].isLikedByMe = !postDataList[index].isLikedByMe;
                                  });
                                  postBloc.add(LikePostEvent(
                                      contentId: postDataList[index].id.toString(),
                                      isLike:
                                      postDataList[index].isLikedByMe ? "1" :"0",
                                      type: postDataList[index].type.toString()));
                                },
                                onFollow: () {
                                  postBloc.add(FollowUserEvent(
                                    followId: postDataList[index].userId!.toString(),
                                    follow: !postDataList[index].isUserFollowedByMe ? "1":"0"
                                  ));
                                  setState(() {
                                    postDataList[index].isUserFollowedByMe =
                                        !postDataList[index].isUserFollowedByMe;
                                  });
                                },
                                onSavePost: () {
                                  postBloc.add(SavePostEvent(
                                    postId: postDataList[index].id!.toString(),
                                    save: !postDataList[index].isSaveByMe ? "1":"0"
                                  ));
                                  setState(() {
                                    postDataList[index].isSaveByMe =
                                        !postDataList[index].isSaveByMe;
                                  });
                                },
                                updateData: () {
                                  isRefreshHome = true;
                                  getHomePageData();
                                },
                              );
                            });
                      },
                    ),
                  ),
                ],
              ),
              onRefresh: () => _onRefreshHandler(context),
            );
          }),
    );
  }

  void pagination() {
    if ((scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) &&
        isMorePageAvailable) {
      isRefreshHome = false;
      currentPageNo = currentPageNo + 1;
      getHomePageData();
    }
  }

  Future<void> _onRefreshHandler(BuildContext context) async {
    isRefreshHome = true;
    postDataList.clear();
    ///clear all data and add data from first index.
    getHomePageData();
  }


  void getHomePageData() {
    postBloc.add(GetPostEvent(
      pageNo: currentPageNo,
    ));
  }
}
