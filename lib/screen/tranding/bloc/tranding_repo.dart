import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/networking/model/notification_response.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/tranding/bloc/tranding_event.dart';
import 'package:octagon/utils/constants.dart';

abstract class ITrendingRepository {
  Future getTrending(GetTrendingEvent event);
}
class TrendingRepository implements ITrendingRepository {
  static final TrendingRepository _postRepository = TrendingRepository._init();

  factory TrendingRepository() {
    return _postRepository;
  }

  TrendingRepository._init();

  @override
  Future getTrending(GetTrendingEvent event) async{
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["type"] = event.type;
      var result = await NetworkAPICall().multiPartPostRequest(getTrendingListApiUrl, body, true,"POST");
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

  @override
  Future getNotification(GetNotificationEvent event) async{
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      var result = await NetworkAPICall().postApiCall(notificationUrl, body, isToken: true);
      NotificationResponse responseModel = NotificationResponse.fromJson(result);

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

}
