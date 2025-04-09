import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:resize/resize.dart';
import '../model/team_list_response.dart';
import '../networking/model/chat_room.dart';
import '../utils/chat_room.dart';
import '../utils/polygon/polygon_border.dart';
import '../utils/team_icon_bg.dart';

class FacebookCardStory extends StatelessWidget {
  final String? profile_image;
  final String? board_image;
  final bool? isVisible;
  // final String? user_name;
  final String? roomId;
  final TeamData? sportInfo;
  bool isUserSelected = false;

  FacebookCardStory(
      {this.profile_image,
      this.board_image,
      this.isVisible,
      this.isUserSelected = false,
      // this.user_name,
      required this.roomId, this.sportInfo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // currentPage.add(10);///chat page number
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatRoomScreen(sportInfo: sportInfo,chatRoom: ChatRoom(id: roomId))));
      },
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Container(
              height: 10.vh,
              width: 85,
              // decoration: const ShapeDecoration(
              //   color: Colors.yellow,
              //   shape: PolygonBorder(
              //     sides: 8,
              //     rotate: 68,
              //   ),
              // ),
              alignment: Alignment.center,
              // clipBehavior: Clip.antiAlias,
              child: Container(
                height: 85,
                width: 85,
                decoration: const ShapeDecoration(
                  color: Colors.black,
                  shape: PolygonBorder(
                    sides: 8,
                    rotate: 68,
                  ),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: TeamOctagonShape(
                  width: 75,
                  height: 75,
                  isHighlighted: isUserSelected,
                  child: CachedNetworkImage(
                    imageUrl: profile_image!,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: 65,
                    height: 65,
                    placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   height: 2.vh,
            //   child: Center(
            //     child: Text(sportInfo?.strTeam??"",
            //       style: whiteColor14BoldTextStyle,
            //       textAlign: TextAlign.center,
            //       maxLines: 2,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
    /*return Padding(
      padding: const EdgeInsets.only(top: 17, bottom: 5, left: 4, right: 4),
      child: GestureDetector(
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(
          //     builder: (context) => StoryPage()));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(ChatRoom(id: roomId))));
        },
        child: Stack(
          children: [
            Container(
              width: 90,
              height: 130,
              decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  image: DecorationImage(
                      image: NetworkImage(board_image!), fit: BoxFit.cover)),
            ),
            //Expanded(child: Container()),

            Positioned(
              top: 90,
              left: 12,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: appBgColor, width: 2),
                      image: DecorationImage(
                          image: NetworkImage(profile_image!),
                          fit: BoxFit.cover)),
                ),
              ),
            ),
            *//* Visibility(
              visible: isVisible!,
              child: Padding(
                padding: const EdgeInsets.all(3.5),
                child: Facebook_Fav(),
              ),
            )*//*
          ],
        ),
      ),
    );*/
  }
}

class Facebook_Fav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {},
      shape: CircleBorder(),
      fillColor: Colors.white,
      constraints: BoxConstraints.tightFor(width: 42.0, height: 42.0),
      child: Icon(
        Icons.add,
        color: whiteColor,
        size: 30,
      ),
    );
  }
}
