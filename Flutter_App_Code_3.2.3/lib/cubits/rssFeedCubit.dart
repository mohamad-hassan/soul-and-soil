import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/RSSFeedModel.dart';
import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

abstract class RSSFeedState {}

class RSSFeedInitial extends RSSFeedState {}

class RSSFeedFetchInProgress extends RSSFeedState {}

class RSSFeedFetchSuccess extends RSSFeedState {
  final List<RSSFeedModel> RSSFeed;
  final int totalRSSFeedCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  RSSFeedFetchSuccess({required this.RSSFeed, required this.totalRSSFeedCount, required this.hasMoreFetchError, required this.hasMore});
}

class RSSFeedFetchFailure extends RSSFeedState {
  final String errorMessage;

  RSSFeedFetchFailure(this.errorMessage);
}

class RSSFeedCubit extends Cubit<RSSFeedState> {
  RSSFeedCubit() : super(RSSFeedInitial());
  int limit = 10;

  void getRSSFeed({required String langId, String? categoryId, String? subCategoryId}) async {
    try {
      emit(RSSFeedFetchInProgress());

      final result = await Api.sendApiRequest(
          body: {LANGUAGE_ID: langId, if (categoryId != null) CATEGORY_ID: categoryId, if (subCategoryId != null) SUBCAT_ID: subCategoryId, LIMIT: limit, OFFSET: 0}, url: Api.rssFeedApi);

      (!result[ERROR])
          ? emit(RSSFeedFetchSuccess(
              RSSFeed: (result[DATA] as List).map((e) => RSSFeedModel.fromJson(e)).toList(), totalRSSFeedCount: result[TOTAL], hasMoreFetchError: false, hasMore: result.length < result[TOTAL]))
          : emit(RSSFeedFetchFailure(result[MESSAGE]));
    } catch (e) {
      emit(RSSFeedFetchFailure(e.toString()));
    }
  }

  bool hasMoreRSSFeed() {
    return (state is RSSFeedFetchSuccess) ? (state as RSSFeedFetchSuccess).hasMore : false;
  }

  void getMoreRSSFeed({required String langId}) async {
    if (state is RSSFeedFetchSuccess) {
      try {
        final result = await Api.sendApiRequest(body: {LANGUAGE_ID: langId, LIMIT: limit, OFFSET: (state as RSSFeedFetchSuccess).RSSFeed.length}, url: Api.rssFeedApi);
        if (!result[ERROR]) {
          List<RSSFeedModel> updatedResults = (state as RSSFeedFetchSuccess).RSSFeed;
          updatedResults.addAll((result[DATA] as List).map((e) => RSSFeedModel.fromJson(e)).toList());
          emit(RSSFeedFetchSuccess(RSSFeed: updatedResults, totalRSSFeedCount: result[TOTAL], hasMoreFetchError: false, hasMore: updatedResults.length < result[TOTAL]));
        } else {
          emit(RSSFeedFetchFailure(result[MESSAGE]));
        }
      } catch (e) {
        emit(RSSFeedFetchSuccess(
            RSSFeed: (state as RSSFeedFetchSuccess).RSSFeed,
            hasMoreFetchError: true,
            totalRSSFeedCount: (state as RSSFeedFetchSuccess).totalRSSFeedCount,
            hasMore: (state as RSSFeedFetchSuccess).hasMore));
      }
    }
  }
}
