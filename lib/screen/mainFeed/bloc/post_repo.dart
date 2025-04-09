import 'package:octagon/model/comment_response_model.dart';
import 'package:octagon/model/favorite_model.dart';
import 'package:octagon/model/file_upload_response_model.dart';
import 'package:octagon/model/follow_model.dart';
import 'package:octagon/model/live_score_data.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/user_profile_response.dart';
import 'package:octagon/networking/model/request_model/create_post_request.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/utils/constants.dart';

import '../../../main.dart';
import '../../../model/block_user.dart';

abstract class IPostRepository {
  Future getPost(GetPostEvent event);
}
class PostRepository implements IPostRepository {
  static final PostRepository _postRepository = PostRepository._init();

  factory PostRepository() {
    return _postRepository;
  }

  PostRepository._init();

  Future getPost(GetPostEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["type"] = "1";
      body["page_no"] = "1";//emailOrPhone
      body["limit"] ="50";
      if(event.isProfile){
        body["flag"] = "0";
        body["user_id"] = event.userId.toString()/*storage.read("current_uid")*//*event.userId.toString()*/;
      }
      var result = await NetworkAPICall().multiPartPostRequest(getUserPostApiUrl, body, true,"POST");
      PostResponseModel responseModel = PostResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future likePost(LikePostEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["content_id"] = event.contentId;
      body["like"] = event.isLike;//emailOrPhone
      body["type"] =event.type;
      var result = await NetworkAPICall().multiPartPostRequest(likeUserPostApiUrl, body, true,"POST");
      FavoriteResponseModel responseModel = FavoriteResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future followUser(FollowUserEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["follow_id"] = event.followId;
      body["follow"] = event.follow;//emailOrPhone

      var result = await NetworkAPICall().multiPartPostRequest(followUserApiUrl, body, true,"POST");
      FollowResponseModel responseModel = FollowResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future removeFollowUser(RemoveFollowUserEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["following_id"] = event.followingId;

      var result = await NetworkAPICall().multiPartPostRequest(removeFollowerUrl, body, true,"POST");
      FollowResponseModel responseModel = FollowResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }


  Future savePost(SavePostEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["post_id"] = event.postId;
      body["save"] = event.save;//emailOrPhone

      var result = await NetworkAPICall().multiPartPostRequest(saveUserPostApiUrl, body, true,"POST");
      FavoriteResponseModel responseModel = FavoriteResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future getPostDetails(GetPostDetailsEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["post_id"] = event.postId;
      body["type"] = event.type;//emailOrPhone

      var result = await NetworkAPICall().multiPartPostRequest(getPostDetailsApiUrl, body, true,"POST");
      PostResponseModel responseModel = PostResponseModel.fromJsonForCreatePost(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future addComment(AddCommentEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["post_id"] = event.postId;
      body["comment"] = event.comment;
      body["parent_comment_id"] = "0";


      var result = await NetworkAPICall().multiPartPostRequest(addCommentApiUrl, body, true,"POST");
      CommentResponseModel responseModel = CommentResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future deleteComment(DeleteCommentEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["comment_id"] = event.commentId;


      var result = await NetworkAPICall().multiPartPostRequest(deleteCommentApiUrl, body, true,"POST");


      resource = Resource(
        error: null,
        data: result,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future deletePost(DeletePostEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["post_id"] = event.postId;
      var result = await NetworkAPICall().multiPartPostRequest(deletePostApiUrl, body, true,"POST");


      resource = Resource(
        error: null,
        data: result,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }


  Future createPost(CreatePostEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["title"] = event.postTitle;
      body["post"] = event.description;
      body["type"] = event.postType;
      body["location"] = event.postTitle;
      body["comment"] = event.isCommentEnable;
      body["photos"] = event.photos;
      body["video"] = event.videos;
      var result = await NetworkAPICall().createPostRequest(createPostApiUrl, body, true,"POST");
      CreatePostResponseModel responseModel = CreatePostResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future getOtherProfile(GetOtherProfileEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["user_id"] = event.userId; //emailOrPhone

      var result = await NetworkAPICall().multiPartPostRequest(getOtherUserDetailsUrl, body, true,"POST");
      UserProfileResponseModel responseModel = UserProfileResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future getSavePost(GetSavePostEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["page_no"] = event.pageNo; // emailOrPhone
      body["limit"] = "100";

      var result = await NetworkAPICall().multiPartPostRequest(getSavePostApiUrl, body, true,"POST");
      PostResponseModel responseModel = PostResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future getUserProfile(GetUserProfileEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};

      var result = await NetworkAPICall().postApiCall(getUserDetailsUrl, body, isToken: true);
      UserProfileResponseModel responseModel = UserProfileResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future getLiveScore(GetLiveScoreEvent event)  async {
    Resource? resource;
    try {
      var result = await NetworkAPICall().getLiveData(event.sportType ?? "soccer",);
      LiveScoreData responseModel = LiveScoreData.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future uploadFile(UploadFileEvent event)  async {
    Resource? resource;
    try {
      var result = await NetworkAPICall().uploadFile(postType: event.postType!,file: event.files!);
      FileUploadResponseModel responseModel = FileUploadResponseModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future blockUnBlockUser(BlockUnBlockEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["user_id"] = event.userId; //emailOrPhone

      var result = await NetworkAPICall().multiPartPostRequest(event.isBlock!?userBlockUrl:userUnBlockUrl, body, true,"POST");

      resource = Resource(
        error: null,
        data: true,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future getBlockUserList(GetBlockUserEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["page_no"] = event.pageNo; // emailOrPhone
      body["limit"] = "100";

      var result = await NetworkAPICall().multiPartPostRequest(blockUserListUrl, body, true,"POST");
      BlockUserModel responseModel = BlockUserModel.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

  Future reportPost(ReportPostEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["content_id"] = event.contentId;
      body["title"] = event.title;
      body["type"] = event.type;

      var result = await NetworkAPICall().multiPartPostRequest(reportUserPostApiUrl, body, true,"POST");

      resource = Resource(
        error: null,
        data: true,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }

}