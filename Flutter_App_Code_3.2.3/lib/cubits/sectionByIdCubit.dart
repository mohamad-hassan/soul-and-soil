import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/SectionById/sectionByIdRepository.dart';
import 'package:news/utils/strings.dart';

abstract class SectionByIdState {}

class SectionByIdInitial extends SectionByIdState {}

class SectionByIdFetchInProgress extends SectionByIdState {}

class SectionByIdFetchSuccess extends SectionByIdState {
  final List<NewsModel> newsModel;
  final List<BreakingNewsModel> breakNewsModel;
  final int totalCount;
  final String type;
  final bool hasMoreFetchError;
  final bool hasMore;

  SectionByIdFetchSuccess({required this.newsModel, required this.breakNewsModel, required this.totalCount, required this.type, required this.hasMore, required this.hasMoreFetchError});
}

class SectionByIdFetchFailure extends SectionByIdState {
  final String errorMessage;

  SectionByIdFetchFailure(this.errorMessage);
}

class SectionByIdCubit extends Cubit<SectionByIdState> {
  final SectionByIdRepository _sectionByIdRepository;
  final int limitOfFeaturedSectionData = 10;

  SectionByIdCubit(this._sectionByIdRepository) : super(SectionByIdInitial());

  void getSectionById({required String langId, required String sectionId, String? latitude, String? longitude, String? limit, String? offset}) async {
    try {
      emit(SectionByIdFetchInProgress());
      final result = await _sectionByIdRepository.getSectionById(
          offset: offset ?? "0", limit: limit ?? limitOfFeaturedSectionData.toString(), langId: langId, sectionId: sectionId, latitude: latitude, longitude: longitude);
      if (!result[ERROR]) {
        int totalSections = (result[DATA][0].newsType == "news" || result[DATA][0].newsType == "user_choice")
            ? result[DATA][0].newsTotal!
            : result[DATA][0].newsType == "breaking_news"
                ? result[DATA][0].breakNewsTotal!
                : result[DATA][0].videosTotal!;
        List<NewsModel> newsSection = (result[DATA][0].newsType == "news" || result[DATA][0].newsType == "user_choice")
            ? result[DATA][0].news!
            : result[DATA][0].videosType == "news"
                ? result[DATA][0].videos!
                : [];
        List<BreakingNewsModel> brNewsSection = result[DATA][0].newsType == "breaking_news"
            ? result[DATA][0].breakNews!
            : result[DATA][0].videosType == "breaking_news"
                ? result[DATA][0].breakVideos!
                : [];

        emit(SectionByIdFetchSuccess(
            newsModel: newsSection,
            breakNewsModel: brNewsSection,
            totalCount: totalSections,
            type: result[DATA][0].newsType!,
            hasMore: ((result[DATA][0].newsType! == NEWS) ? (newsSection.length < totalSections) : (brNewsSection.length < totalSections)),
            hasMoreFetchError: false));
      } else {
        emit(SectionByIdFetchFailure(result[MESSAGE]));
      }
    } catch (e) {
      if (!isClosed) emit(SectionByIdFetchFailure(e.toString())); //isClosed checked to resolve Bad state issue of Bloc
    }
  }

  bool hasMoreSections() {
    return (state is SectionByIdFetchSuccess) ? (state as SectionByIdFetchSuccess).hasMore : false;
  }

  void getMoreSectionById({required String langId, required String sectionId, String? latitude, String? longitude, String? limit, String? offset}) async {
    if (state is SectionByIdFetchSuccess) {
      try {
        final result = await _sectionByIdRepository.getSectionById(
            sectionId: sectionId,
            latitude: latitude,
            longitude: longitude,
            limit: limit ?? limitOfFeaturedSectionData.toString(),
            offset: (state as SectionByIdFetchSuccess).newsModel.length.toString(),
            langId: langId);
        List<NewsModel> updatedResults = [];
        List<BreakingNewsModel> updatedBrResults = [];

        if (result[DATA][0].newsType! == NEWS || result[DATA][0].videosType == NEWS) {
          updatedResults = (state as SectionByIdFetchSuccess).newsModel;
          List<NewsModel> newValues = (result[DATA][0].newsType == "news" || result[DATA][0].newsType == "user_choice")
              ? result[DATA][0].news ?? []
              : result[DATA][0].videosType == "news"
                  ? result[DATA][0].videos ?? []
                  : [];
          updatedResults.addAll(newValues);
        } else {
          updatedBrResults = (state as SectionByIdFetchSuccess).breakNewsModel;
          List<BreakingNewsModel> newValues = result[DATA][0].newsType == "breaking_news"
              ? result[DATA][0].breakNews!
              : result[DATA][0].videosType == "breaking_news"
                  ? result[DATA][0].breakVideos!
                  : [];
          updatedBrResults.addAll(newValues);
        }

        int totalCount = (result[DATA][0].newsType == "news" || result[DATA][0].newsType == "user_choice")
            ? result[DATA][0].newsTotal!
            : result[DATA][0].newsType == "breaking_news"
                ? result[DATA][0].breakNewsTotal!
                : result[DATA][0].videosTotal!;

        emit(SectionByIdFetchSuccess(
            newsModel: updatedResults,
            breakNewsModel: updatedBrResults,
            type: result[DATA][0].newsType!,
            totalCount: totalCount,
            hasMoreFetchError: false,
            hasMore: (result[DATA][0].newsType! == NEWS || result[DATA][0].videosType == NEWS) ? (updatedResults.length < totalCount) : (updatedBrResults.length < totalCount)));
      } catch (e) {
        print("error in loading more featured sections ${e.toString()}");
        emit(SectionByIdFetchSuccess(
            type: (state as SectionByIdFetchSuccess).type,
            breakNewsModel: (state as SectionByIdFetchSuccess).breakNewsModel,
            newsModel: (state as SectionByIdFetchSuccess).newsModel,
            hasMoreFetchError: (e.toString() == "No Data Found") ? false : true,
            totalCount: (state as SectionByIdFetchSuccess).totalCount,
            hasMore: (state as SectionByIdFetchSuccess).hasMore));
      }
    }
  }
}
