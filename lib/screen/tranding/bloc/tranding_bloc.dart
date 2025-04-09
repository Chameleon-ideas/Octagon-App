

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octagon/networking/exception/exception.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/screen/tranding/bloc/tranding_event.dart';
import 'package:octagon/screen/tranding/bloc/tranding_repo.dart';
import 'package:octagon/screen/tranding/bloc/tranding_state.dart';

class TrendingBloc extends Bloc<TrendingScreenEvent, TrendingScreenState> {
  TrendingBloc() : super(TrendingInitialState());

  final TrendingRepository _trendingRepository = TrendingRepository();

  Stream<TrendingScreenState> mapEventToState(TrendingScreenEvent event) async* {

    if (event is GetTrendingEvent) {
      yield TrendingLoadingBeginState();
      Resource resource = await _trendingRepository.getTrending(event);
      if (resource.data != null) {
        yield GetTrendingState(resource.data);
      } else {
        yield TrendingErrorState(
            AppException.decodeExceptionData(jsonString: resource.error ?? ''));
      }
      yield TrendingLoadingEndState();
    }
    if (event is GetNotificationEvent) {
      yield TrendingLoadingBeginState();
      Resource resource = await _trendingRepository.getNotification(event);
      if (resource.data != null) {
        yield GetNotificationState(resource.data);
      } else {
        yield TrendingErrorState(
            AppException.decodeExceptionData(jsonString: resource.error ?? ''));
      }
      yield TrendingLoadingEndState();
    }
  }
  }