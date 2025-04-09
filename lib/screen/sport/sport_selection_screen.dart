import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:octagon/networking/model/response_model/sport_list_response_model.dart';
import 'package:octagon/networking/model/save_sports_request_model.dart';
import 'package:octagon/networking/response.dart';

import 'package:octagon/screen/login/login_screen.dart';
import 'package:octagon/screen/sport/bloc/sport_bloc.dart';
import 'package:octagon/screen/sport/bloc/sport_event.dart';
import 'package:octagon/screen/sport/bloc/sport_state.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/screen/term_selection/team_selection.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:resize/resize.dart';

import '../../utils/common_image_view.dart';
import '../../utils/svg_to_png.dart';


class SportSelection extends StatefulWidget {
  List<Sports>? sportDataList;
  bool isUpdate = false;

  SportSelection({Key? key, this.sportDataList, this.isUpdate = false}) : super(key: key);

  @override
  State<SportSelection> createState() => _SportSelectionState();
}



class _SportSelectionState extends State<SportSelection> {
  List<SaveSport> selectedSportsList = [];
  List<Sports> sportDataList = [];
 SportBloc sportBloc = SportBloc();
  List<SportListResponseModelData> sportListResponseModel = [];

  bool isLoading = false;

  // List<SaveSportListResponseModelData> saveSportListResponseModelData = [];

  @override
  void initState() {
    sportBloc = SportBloc();


    sportBloc.add(GetSportListEvent());

    publishAmplitudeEvent(eventType: 'Sports Selection $kScreenView');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
            backgroundColor: appBgColor,
            appBar: AppBar(
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Select your favorite sport",
                style: whiteColor20BoldTextStyle,
              ),
              actions: [
                if(!widget.isUpdate)
                  InkWell(
                    onTap: (){
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => TabScreen()));
                    },
                    child: Center(
                      child: Text(
                        "Skip  ",
                        style: whiteColor20BoldTextStyle,
                      ),
                    ),
                  )
              ],
            ),
            body: BlocConsumer(
              bloc: sportBloc,
              listener: (context,state){
                if(state is SportLoadingBeginState){
                  // onLoading(context);
                  isLoading = true;
                  setState(() {

                  });
                }
                if(state is GetSportListSate){
                  // stopLoader(context);
                  isLoading = false;

                  setState(() {
                    sportListResponseModel = state.sportListResponseModel.data??[];
                    for (var element in state.sportListResponseModel.data!) {
                      sportDataList.add(Sports(
                          "${element.strSport}",
                          element.id!.toInt(),
                          element.idSport!.toInt(),
                          element.strSportThumb.toString()));
                    }
                  });

                  if(widget.sportDataList!=null && widget.sportDataList!.isNotEmpty){
                    for (var data in widget.sportDataList!) {
                      int index =  sportDataList.indexWhere((element) => element.sportsId == data.sportsId);
                      widget.sportDataList![index] = data;
                    }
                  }
                }
                if(state is SaveSportState){
                  // stopLoader(context);
                  isLoading = false;
                  setState(() {


                  });
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TeamSelectionScreen(sportDataList, isUpdate: widget.isUpdate
                      )));
                }
              },
              builder: (context,_) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        child: Wrap(
                          spacing: 15,
                          children: getSportsSelection(),
                        ),
                      ),
                    ),
                    Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: FilledButtonWidget(isLoading: isLoading,/*widget.model,*/ "Next", () {
                          if(selectedSportsList.isNotEmpty) {
                            sportBloc.add(SaveSportListEvent(sports: selectedSportsList));
                          }else{
                            Get.snackbar("sport", "please selects sport");
                          }
                        }, 1)),
                  ],
                );
              }
            )),
      ),
    );
  }

  getSportsSelection() {
    List<Widget> list = [];
    for (int i = 0; i < sportDataList.length; i++) {
      list.add(getSports(i));
    }
    return list;
  }

  getSports(int index) {
    /*  for (var element in selectedLanguages) {
      if(element == language[index].language){
        language[index].isSelected = true;
      }
    }*/
    return GestureDetector(
      onTap: () {
        setState(() {
          sportDataList.forEach((element) {
            element.selected = false;
          });
          sportDataList[index].selected = !sportDataList[index].selected;

          selectedSportsList = [];
          selectedSportsList.add(SaveSport(
              sportId: sportDataList[index].sportsId,
              sportApiId: sportDataList[index].sportApiId));

          // sportDataList[index].selected
          //     ? selectedSportsList.add(SaveSport(
          //     sportId: sportDataList[index].sportsId,
          //     sportApiId: sportDataList[index].sportApiId))
          //     : selectedSportsList.remove(SaveSport(
          //     sportId: sportDataList[index].sportsId,
          //     sportApiId: sportDataList[index].sportApiId));

        });
      },
      child: Container(
        height: 130,
        width: 100,
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          children: <Widget>[
            buildSportSelectionWidget(isSelected: sportDataList[index].selected, image: sportDataList[index].sportsImage),
            SizedBox(
              height: 2.h,
            ),
            Expanded(
              child: Text(
                sportDataList[index].sportsName,
                textAlign: TextAlign.center,
                style: whiteColor14BoldTextStyle,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if(widget.isUpdate){
      return Future(() => true);
    }
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Octagon"),
        content: const Text("Are you sure you want to exit the app!"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: const Text("Yes"),
          ),
        ],
      ),
    )) ??
        false;
  }

}
