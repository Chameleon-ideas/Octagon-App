
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/networking/model/chat_message.dart';
import 'package:http/http.dart' as http;
import 'package:octagon/networking/model/chat_room.dart';
import 'package:octagon/networking/response.dart';
import 'package:octagon/screen/chat_network/bloc/chat_repo.dart';

class ChatBloc {
  ChatRepository? _chatRepository;

  late StreamController<Response<List<ChatMessageData>>> chatMessageController;

  late StreamController<Response> roomController;

  StreamSink<Response<List<ChatMessageData>>> get dataSink =>
      chatMessageController.sink;

  Stream<Response<List<ChatMessageData>>> get dataStream =>
      chatMessageController.stream;


  StreamSink<Response> get roomDataSink =>
      roomController.sink;

  Stream<Response> get roomDataStream =>
      roomController.stream;

  ChatBloc() {
    chatMessageController = StreamController<Response<List<ChatMessageData>>>();
    _chatRepository = ChatRepository(FirebaseFirestore.instance);
    roomController = StreamController<Response>();
  }

  List<ChatMessageData> fetchedMessageItem = List<ChatMessageData>.empty(growable: true);


  sendMessage(ChatMessageData message, TeamData sportInfo) async {
    dataSink.add(Response.loading('sending message to group..'));
    try {

      message.createdOn = DateTime.now();
      message.updatedAt = DateTime.now();

      DocumentReference responseData = await _chatRepository!
          .sendMessage(message: message, sportInfo: sportInfo);

      print(responseData);
      // dataSink.add(Response.completed(responseData));
    } catch (e) {
      dataSink.add(Response.error(e.toString()));
    }
  }


  sendReplayMessage(ChatMessageData message, String groupId) async {
    dataSink.add(Response.loading('sending replay message to group..'));
    try {

      message.createdOn = DateTime.now();
      message.updatedAt = DateTime.now();

      DocumentReference responseData = await _chatRepository!
          .sendReplayMessage(message: message, groupId: groupId);

      print(responseData);
      // dataSink.add(Response.completed(responseData));
    } catch (e) {
      dataSink.add(Response.error(e.toString()));
    }
  }



  getChatMessages(ChatRoom chatRoom, String? currentUser,{String? lastPage = ""}) {
    try{
      Query<Map<String, dynamic>> queryRef = FirebaseFirestore.instance
          .collection('chat_rooms/${chatRoom.id}/messages');

      // var value = await FirebaseFirestore.instance
      //     .collection(DB_REF_CHATS)
      //     .where('sportId', isEqualTo: sportInfo.sportId)
      //     .get();


      if(lastPage!=null && lastPage.isNotEmpty){
        queryRef = queryRef.orderBy("createdOn", descending: true)
            .limit(50)
            .startAfter([lastPage]);
      }else{
        queryRef = queryRef.orderBy("createdOn", descending: true)
            .limit(50);
      }

      queryRef.snapshots().listen((event) {
        List<ChatMessageData> chatMessages = [];
        for (var value in event.docs.toList()) {
          ChatMessageData data = ChatMessageData.fromJson(value.data());

          data.currentUserUid = currentUser;
          // data.timeAgo = timeago.format(data.updatedAt!);
          chatMessages.add(data);
        }
        dataSink.add(Response.completed(chatMessages));
      });
      // return _chatRepository!.getChatMessages(chatRoom, lastPage: lastPage).map((d) {
      //   print("hio");
      //   List<ChatMessage> data = [];
      //
      //   d.docs.toList().forEach((d) {
      //     ChatMessage element = ChatMessage.fromJson(d.data() as Map<String, dynamic>);
      //
      //     element.currentUserUid = currentUser;
      //     element.timeAgo = timeago.format(element.updatedAt!);
      //     data.add(element);
      //   });
      //
      //   return data;
      // }).map((event) {
      //   return event;
      // });
    }catch(e){
      print(e);
    }
  }


  getChatRooms(TeamData sportInfo){
    roomDataSink.add(Response.loading('getting chat rooms..'));
    try {

      // _chatRepository!.getPopularChatRooms(sportInfo);

      _chatRepository!.getPopularChatRooms(sportInfo).then((value) {
        print(value);
        roomDataSink.add(Response.completed(value));
      });

    } catch (e) {
      roomDataSink.add(Response.error(e.toString()));
    }
  }

  sendNotifications({required String subject, required String description, required String token}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=AAAAeyvqWOE:APA91bEikAqlSZ2TL-fMcsPEjoneQ0b6d3vAL309wk7PXtYl-xtm52z45ebaDXyMUvzh-JiTlOoK-a8gVcPyM8BllGj7dWL6F7GoUlhCQm_iyRq0TPrMZsPnqcqGuC6Ko7coZ4Q-tHWX'
    };
    var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "to": token,
      "notification": {
        "title": subject,
        "body": description,
        "subtitle": subject,
        "OrganizationId": "2",
        "content_available": true,
        "priority": "low",
      },
      "data": {
        "priority": "low",
        "content_available": true,
        "bodyText": description,
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // showMessage(msg: "Notifications has been sent to all users!");
      print(await response.stream.bytesToString());
    } else {
      // showMessage(msg: "Something went wrong! Please try again later!!");
      print(response.reasonPhrase);
    }
  }
}
