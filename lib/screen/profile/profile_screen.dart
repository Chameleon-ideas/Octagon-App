import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/screen/profile/profile_posts.dart';
import 'package:octagon/utils/constants.dart';

import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/setting_screen.dart';
import 'package:shape_maker/shape_maker.dart';
import '../../main.dart';
import '../../model/post_response_model.dart';
import '../../model/team_list_response.dart';
import '../../model/user_profile_response.dart';

import '../../utils/chat_room.dart';
import '../../utils/octagon_common.dart';
import '../../widgets/default_user_image.dart';
import '../tabs_screen.dart';
import 'follow_following.dart';

class ProfileScreen extends StatefulWidget {
  int? userId;
  ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isMorePageAvailable = false;
  int currentPageNo = 1;

  UserProfileResponseModel? profileData;
  List<PostResponseModelData> postDataList = [];
  List<PostResponseModelData> favoritePostDataList = [];
  List<PostResponseModelData> storiesDataList = [];
  List<TeamData> sportsListing = [];

  int saveCount = 0, followers = 0, following = 0, postCount = 0;
  String userName = "", bio = "", profile = '';

  PostBloc postBloc = PostBloc();

  bool isLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    postBloc = PostBloc();

    widget.userId ??= storage.read("current_uid");

    setLocalData();
    refreshData();

   /* currentPage.stream.listen((event) {
      if(event == 3){
        refreshData();
      }
    });*/

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appBgColor,
        // floatingActionButton: FloatingActionButton(
        //   child: Text("Logout"),
        //   onPressed: (){
        //     storage.erase();
        //     Navigator.push(context, MaterialPageRoute(
        //         builder: (context) => const LoginScreen(null)));
        //   },
        // ),
        body: BlocConsumer(
          bloc: postBloc,
          listener: (context,state){
            if(state is PostLoadingBeginState){
              // onLoading(context);
              isLoading = true;
            }
            if(state is PostLoadingEndState){
              // stopLoader(context);
              isLoading = false;
            }

            if(state is SavePOstState){

            }
            if(state is DeletePostState){
              refreshData();
            }

            if(state is GetSavePostState){
              favoritePostDataList = [];
              storiesDataList = [];
              for (var element in state.postResponseModel.success!) {
                if(element.type == "1"){
                  favoritePostDataList.add(element);
                }else if(element.type == "2"){
                  storiesDataList.add(element);
                }
              }
              isMorePageAvailable = state.postResponseModel.more??false;
            }

            if(state is GetPostState){
              postDataList= [];
              storiesDataList = [];
              for (var element in state.postResponseModel.success!) {
                if(element.type == "1"){
                  postDataList.add(element);
                }else if(element.type == "2"){
                  storiesDataList.add(element);
                }
              }
              isMorePageAvailable = state.postResponseModel.more??false;
            }

            if(state is GetUserProfileState){
              profileData = state.userProfileResponseModel;

              setLocalData();
            }
            if(state is UserTeamState){
              sportsListing = state.data;
            }
          },
          builder: (context,_) {
            return RefreshIndicator(
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 250,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/splash/splash.png",
                                  height: 100,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),

                                ///Middle Profile info container
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      // color: whiteColor,
                                      borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(50),
                                      bottomLeft: Radius.circular(50))),
                                  margin: const EdgeInsets.only(top: 100),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Flexible(
                                        flex: 3,
                                        child: Container(
                                          height: 150,
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 10),
                                          // decoration: BoxDecoration(
                                          //     color: whiteColor.withOpacity(0.5),
                                          //     borderRadius: const BorderRadius.only(
                                          //         bottomLeft: Radius.circular(50))),
                                          child: buildProfileView(userPic: profile, teamLogo: "https://uifaces.co/our-content/donated/3799Ffxy.jpeg"),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 7,
                                          child: Container(
                                        height: 150,
                                          decoration: BoxDecoration(
                                            color: whiteColor,
                                              borderRadius: const BorderRadius.only(
                                                  bottomRight: Radius.circular(50),
                                                  bottomLeft: Radius.circular(50))),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),

                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  flex: 7,
                                                  child: Text(
                                                    userName.capitalize??"",
                                                    style:
                                                    blackColor20BoldTextStyle,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                  flex: 2,
                                                  child: IconButton(
                                                    icon: const Icon(Icons.settings, color: Colors.grey),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SettingScreen(profileData: profileData, ))).then((value) {
                                                        refreshData();
                                                      });

                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                            if(bio.isNotEmpty)
                                            Text(
                                              bio??"",
                                              maxLines: 4,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.clip,
                                              style:
                                              blackColor16BoldTextStyle,
                                            ),
                                          ],
                                        ),
                                      )
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///Post info
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            //height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ///post
                                buildPost(),

                                ///Followers
                                buildFollowers(),

                                ///Following
                                buildFollowing(),

                                ///Fav post
                                buildFavPost(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(25),
                            bottomLeft: Radius.circular(25)),
                      ),
                      child: TabBar(
                        unselectedLabelColor: greyColor,
                        labelColor: purpleColor,
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(
                            icon: Icon(
                              Icons.apps_rounded,
                            ),
                          ),
                          Tab(
                            icon: Icon(
                              Icons.person_pin_rounded,
                            ),
                          )
                        ],
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ProfilePosts(postDataList: postDataList, isLoading: isLoading, onButtonPress: (PostResponseModelData data){
                            postBloc.add(DeletePostEvent(postId: data.id.toString()));
                          }),
                          ProfilePosts(postDataList: favoritePostDataList,isSavedPost: true, onButtonPress: (PostResponseModelData data){

                            postBloc.add(SavePostEvent(
                                postId: data.id!.toString(), save: data.isSaveByMe ? "1":"0"
                            ));
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onRefresh: () => _onRefreshHandler(context),
            );
          }
        ),
      ),
    );
  }

  buildFollowers() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  FollowFollowing(initIndex: 0, followingUsers: profileData?.success?.followingUsers, followersUsers: profileData?.success?.followersUsers, refreshPage: (){
                    refreshData();
                  },))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
                right: BorderSide(color: greyColor))),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: "Followers\n",
              style: whiteColor16TextStyle,
              children: [
                TextSpan(
                    text: "${followers}",
                    style: whiteColor16BoldTextStyle)
              ]),
        ),
      ),
    );
  }

  buildFollowing() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  FollowFollowing(initIndex: 1,followersUsers: profileData?.success?.followersUsers, followingUsers: profileData?.success?.followingUsers, refreshPage: (){
                    refreshData();
                  },))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
                right: BorderSide(color: greyColor))),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: "Following\n",
              style: whiteColor16TextStyle,
              children: [
                TextSpan(
                    text: "$following",
                    style: whiteColor16BoldTextStyle)
              ]),
        ),
      ),
    );
  }

  buildFavPost() {
    return GestureDetector(
      onTap: (){
        _tabController.index = 1;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: RichText(
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          text: TextSpan(
              text: "Favourite\n",
              style: whiteColor16TextStyle,
              children: [
                TextSpan(
                    text: "$saveCount",
                    style: whiteColor16BoldTextStyle)
              ]),
        ),
      ),
    );
  }

  buildPost() {
   return GestureDetector(
     onTap: (){
       _tabController.index = 0 ;
     },
     child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            border: Border(
                right: BorderSide(color: greyColor))),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: "Post\n",
              style: whiteColor16TextStyle,
              children: [
                TextSpan(
                    text: "$postCount",
                    style: whiteColor16BoldTextStyle)
              ]),
        ),
      ),
   );
  }

  Future<void> _onRefreshHandler(BuildContext context) async {
   postBloc.add(GetUserProfileEvent());
  }

  buildProfileView({required String? userPic, required String teamLogo}) {
   return GestureDetector(
     onTap: () {

     },
     child: Stack(
       children: [
         Container(
           width: 90,
           height: 128,
           decoration: BoxDecoration(
               color: greyColor,
               borderRadius: const BorderRadius.all(Radius.circular(20)),
               image: DecorationImage(
                   image: NetworkImage(userPic??''), fit: BoxFit.cover)),
           child: !isProfilePicAvailable(userPic)?
           defaultThumb():null
         ),

         Positioned(
           top: 92,
           left: 12,
           child: Padding(
             padding: const EdgeInsets.all(8.0),
             child: ShapeMaker(
               height: 50,
               width: 50,
               bgColor: Colors.yellow,
               widget: Container(
                 margin: const EdgeInsets.all(6),
                 child: ShapeMaker(
                   bgColor: Colors.black,
                   widget: Container(
                     margin: const EdgeInsets.all(8),
                     child: ShapeMaker(
                         bgColor: (sportsListing.isNotEmpty &&
                             sportsListing.first.strTeam!.isNotEmpty ??false) ?
                         appBgColor:Colors.white,
                         widget: (sportsListing.isNotEmpty &&
                             sportsListing.first.strTeam!.isNotEmpty ??false)?
                         CachedNetworkImage(
                           imageUrl: sportsListing.first.strTeamLogo??"",
                           fit: BoxFit.cover,
                           alignment: Alignment.center,
                           width: 100,
                           height: 100,
                           placeholder: (context, url) => const SizedBox(height: 20),
                           errorWidget: (context, url, error) => const Icon(Icons.error),
                         ):null,
                     ),
                   ),
                 ),
               ),
             )
           ),
         ),
       ],
     ),
   );
  }

  void refreshData() {
    postBloc.add(GetUserTeamEvent());///local read
    if(widget.userId!=null){
      postBloc.add(GetPostEvent(pageNo: currentPageNo, isProfile: true, userId: widget.userId!));
    }

    postBloc.add(GetSavePostEvent());
    postBloc.add(GetUserProfileEvent());
    // postBloc.add(GetSavePostEvent(pageNo: "1"));
  }

  void setLocalData() {
    if(profileData!=null){
      followers = profileData?.success?.followers??0;
      following = profileData?.success?.following??0;
      saveCount = profileData?.success?.savePostCount??0;
      postCount = profileData?.success?.postCount??0;
      userName = profileData?.success?.user?.name??storage.read('user_name')??"";
      bio = profileData?.success?.user?.bio??storage.read('bio')??'';
      profile = profileData?.success?.user?.photo??storage.read('image_url')??"";
    }else{
      userName = storage.read('user_name')??"";
      bio = storage.read('bio')??"";
      profile = storage.read('image_url')??"";
    }
  }

}
