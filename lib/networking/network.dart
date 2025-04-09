import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:octagon/networking/exception/exception.dart';
import 'package:octagon/screen/common/create_post_screen.dart';
import 'package:octagon/utils/constants.dart';


//This Class is not complete, under modification

class NetworkAPICall {
  /// baseURL Containse Main URL of Api call.
  static final NetworkAPICall _networkAPICall = NetworkAPICall._internal();

  factory NetworkAPICall() {
    return _networkAPICall;
  }

  NetworkAPICall._internal();
  ///multipart api
  Future<dynamic> multiPartPostRequest(String url, dynamic body,bool isToken,String type) async {
    var client = http.Client();
    try {


      var header = isToken ? {
        // 'Content-Type': 'application/json',
        'Authorization': 'Bearer ${getUserToken()}'
      } : {
        'Content-Type': 'application/json',
      };

      var request = http.MultipartRequest(type, Uri.parse(baseUrl+url));

      request.headers.addAll(header);

      body.forEach((key,value){
        if(key.toString() != "photoKey" && key.toString().startsWith("photo")){
          if(value!=null){
            request.files.add(value);
          }
        }else{
          request.fields["$key"] = value.toString();
        }
      });
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));

      var response = await http.Response.fromStream(streamedResponse);

      /// if (response.statusCode == 200) {
      ///  print(response.body);
      return checkResponse(response);
      /// } else {
      ///   print(response.reasonPhrase);
      /// }
    } catch (exception) {
      client.close();
      rethrow;
    }
  }

  Future<dynamic> getLiveData(String sportsType) async {
    var responseJson;
    try {
      var response;

      response = await http.get(Uri.parse("https://livescore6.p.rapidapi.com/matches/v2/list-live?Category=$sportsType"), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "X-RapidAPI-Key":"3dbff851cemsh5e01b9da5e4ff25p1e63d4jsn06dc492f3ac1"
      });

      print(response.request);
      responseJson = response.body.toString();
    } on SocketException {
      throw AppException.exceptionHandler("No Internet connection");
    }
    return responseJson;
  }

  Future<dynamic> createPostRequest(String url, dynamic body,bool isToken,String type) async {
    var client = http.Client();
    try {


      var header = isToken ? {
        // 'Content-Type': 'application/json',
        'Authorization': 'Bearer ${getUserToken()}'
      } : {
        'Content-Type': 'application/json',
      };

      var request = http.MultipartRequest(type, Uri.parse(baseUrl+url));

      request.headers.addAll(header);

      if(body["title"].isNotEmpty){
        request.fields["title"] = body["title"].toString();
      }
      if(body["post"].isNotEmpty){
        request.fields["post"] = body["post"].toString();
      }
      if(body["type"].toString().isNotEmpty){
        request.fields["type"] = body["type"].toString();
      }
      if(body["location"].isNotEmpty){
        request.fields["location"] = body["location"].toString();
      }
      if(body["comment"].toString().isNotEmpty){
        request.fields["comment"] = body["comment"]?"1":"0";
      }
      // request.fields["tag_people"] = postTitle;

      try{
        if(body["photos"]!=null && body["photos"].isNotEmpty){
          List<http.MultipartFile> data = await convert(body["photos"].toList(), "photo");
          request.files.addAll(data);
        }

        if(body["video"]!=null && body["video"].isNotEmpty){
          List<http.MultipartFile> data = await convert(body["video"].toList(), "video");
          request.files.addAll(data);
        }

      }catch(e){
        print(e);
      }
      final streamedResponse = await request.send().timeout(const Duration(minutes: 2));

      var response = await http.Response.fromStream(streamedResponse);

      /// if (response.statusCode == 200) {
      ///  print(response.body);
      return checkResponse(response);
      /// } else {
      ///   print(response.reasonPhrase);
      /// }
    } catch (exception) {
      client.close();
      rethrow;
    }
  }

  Future<dynamic> editProfileApi(String url, dynamic body,bool isToken,String type) async {

    var client = http.Client();
    try {


      var header = isToken ? {
        // 'Content-Type': 'application/json',
        'Authorization': 'Bearer ${getUserToken()}'
      } : {
        'Content-Type': 'application/json',
      };



      var request = http.MultipartRequest(type, Uri.parse(baseUrl+url));
      request.headers.addAll(header);

    if(body["name"]!=null && body["name"].isNotEmpty){
      request.fields["name"] = body["name"].toString();
    }
    if(body["bio"]!=null && body["bio"].isNotEmpty){
      request.fields["bio"] = body["bio"];
    }
    if(body["dob"]!=null && body["dob"].isNotEmpty){
      request.fields["dob"] = body["dob"];
    }
    if(body["country"]!=null && body["country"].isNotEmpty){
      request.fields["country"] = body["country"];
    }
    if(body["bgPic"]!=null && body["bgPic"].isNotEmpty && !"${body["bgPic"]}".contains("http")){
      request.files.add(await http.MultipartFile.fromPath('background', body["bgPic"]));
    }
    if(body["profilePic"]!=null&&body["profilePic"].isNotEmpty && !"${body["profilePic"]}".contains("http")){
      request.files.add(await http.MultipartFile.fromPath('photo', body["profilePic"]));
    }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));;

      var response = await http.Response.fromStream(streamedResponse);
      /// if (response.statusCode == 200) {
      ///  print(response.body);
      return checkResponse(response);
      /// } else {
      ///   print(response.reasonPhrase);
      /// }
    } catch (exception) {
      client.close();
      rethrow;
    }
  }


  Future<List<http.MultipartFile>> convert(List<PostFile> files, String fileName) async {
    List<http.MultipartFile> multipartImageList = <http.MultipartFile>[];
    if (files.isNotEmpty) {
      var temp = 0;
      for (PostFile imagePath in files) {
        if(imagePath.filePath.isNotEmpty){
          http.MultipartFile data = await http.MultipartFile.fromPath("$fileName[$temp]", imagePath.filePath);
          multipartImageList.add(data);
          temp++;
        }
      }
    }
    return multipartImageList;
  }

  Future<dynamic> uploadFile({int postType = 0, List<PostFile>? file}) async {

    var client = http.Client();
    try {

    var request =
    http.MultipartRequest('POST', Uri.parse(baseUrl + uploadFileApiUrl));
    request.headers.addAll({
      'Accept' : 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      "Authorization": "Bearer ${getUserToken()}",
    });

    request.fields["type"] = "$postType";

    try{
      if(file!=null && file.isNotEmpty){
        List<http.MultipartFile> data = await convert(file.toList(), "files");
        request.files.addAll(data);
      }
    }catch(e){
      print(e);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return checkResponse(response);
    } catch (exception) {
      client.close();
      rethrow;
    }
  }

  ///get api
  Future<dynamic> getApiCall(String apiUrl, {bool isToken = true}) async {
    final client = http.Client();
    try {

      Map<String, String> header;
      header = isToken
          ? {
        // 'Content-Type': 'application/json',
        'Authorization': 'Bearer '/*${getFCMToken()}*/
      }
          : {
        'Content-Type': 'application/json'
      };

      var uri = Uri.parse(baseUrl+apiUrl);
      var response = await client
          .get(uri, headers: header)
          .timeout(const Duration(seconds: 30));


      return checkResponse(response);
    } catch (exception) {
      client.close();
      throw AppException.exceptionHandler(exception);
    }
  }

  ///post api
  Future<dynamic> postApiCall(
      String apiName,
      dynamic request, {
        bool isToken = true,
      }) async {
    var client = http.Client();
    try {
      Map<String, String> header;
      dynamic postBodyRequest;

      header = isToken
          ? {
        // 'Content-Type': 'application/json',
        'Authorization': 'Bearer ${getUserToken()}'
      }
          : {
        'Content-Type': 'application/json'
      };

      /// postBodyRequest -> Declared request Parameter to send in API calling.
      /// This is basically comes from repository file while call API
      postBodyRequest = json.encode(request);


      var response = await http.post(Uri.parse("$baseUrl$apiName"), body: postBodyRequest, headers: header).timeout(const Duration(seconds: 30));
      log(response.statusCode.toString(), name: 'Response statusCode');
      return checkResponse(response);
    } catch (exception) {
      client.close();
      throw AppException.exceptionHandler(exception);
    }
  }

  ///put api
  Future<dynamic> putApiCall(
      String apiName,
      dynamic request, {
        bool isToken = true,
      }) async {
    var client = http.Client();
    try {
      Map<String, String> header;
      dynamic postBodyRequest;

      header = isToken
          ? {
        // 'Content-Type': 'application/json',
        //'Authorization': 'Bearer ${getUserToken()}'


      }
          : {
        'Content-Type': 'application/json'
      };

      /// postBodyRequest -> Declared request Parameter to send in API calling.
      /// This is basically comes from repository file while call API
      /*isDecoded
          ?*/ postBodyRequest = json.encode(request);
      /*: postBodyRequest = request;*/

      var response = await http.put(Uri.parse(baseUrl+apiName), body: postBodyRequest).timeout(const Duration(seconds: 30));
      log(response.statusCode.toString(), name: 'Response statusCode');
      return checkResponse(response);
    } catch (exception) {
      client.close();
      throw AppException.exceptionHandler(exception);
    }
  }


  dynamic checkResponse(http.Response response) {
    print(response);
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          var json = jsonDecode(utf8.decode(response.body.toString().codeUnits));
          if (json is List<dynamic>) {
            return json;
          }
          if (json['status'] == 'error') {
            throw AppException(
                message: json['message'], errorCode: response.statusCode);
          }
          return json;
        } catch (e, stackTrace) {
          throw AppException.exceptionHandler(e, stackTrace);
        }
      case 400:
        var json = jsonDecode(response.body);
        throw AppException(
            message: json['message'], errorCode: json['statusCode']);
      case 404:
        var json = jsonDecode(response.body);



    // throw AppException(
    //     message: json['message'], errorCode: json['statusCode']);
      case 409:
        var json = jsonDecode(response.body);
        throw AppException(
            message: json['message'], errorCode: json['statusCode']);
      case 401:
        throw AppException(
          message: "unauthorized",
          errorCode: response.statusCode,
        );
      case 422:
        throw AppException(
            message: "Looks like our server is down for maintenance,"
            r'''\n\n'''
            "Please try again later.",
            errorCode: response.statusCode);
      case 500:
      case 502:
        var json = jsonDecode(response.body);
        throw AppException(
            message: "Looks like our server is down for maintenance,"
            r'''\n\n'''
            "Please try again later.",
            errorCode: response.statusCode);
      default:
        throw AppException(
            message: "Unable to communicate with the server at the moment."
            r'''\n\n'''
            "Please try again later",
            errorCode: response.statusCode);
    }
  }
}