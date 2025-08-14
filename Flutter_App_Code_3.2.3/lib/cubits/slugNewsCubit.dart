import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

abstract class SlugNewsState {}

class SlugNewsInitial extends SlugNewsState {}

class SlugNewsFetchInProgress extends SlugNewsState {}

class SlugNewsFetchSuccess extends SlugNewsState {
  final List<NewsModel> generalNews;
  final int totalCount;

  SlugNewsFetchSuccess({required this.totalCount, required this.generalNews});
}

class SlugNewsFetchFailure extends SlugNewsState {
  final String errorMessage;

  SlugNewsFetchFailure(this.errorMessage);
}

class SlugNewsCubit extends Cubit<SlugNewsState> {
  SlugNewsCubit() : super(SlugNewsInitial());

  Future<dynamic> getSlugNews({required String langId, String? latitude, String? longitude, int? offset, String? newsSlug}) async {
    emit(SlugNewsInitial());
    try {
      final body = {LANGUAGE_ID: langId, LIMIT: 20};

      if (latitude != null && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != null && longitude != "null") body[LONGITUDE] = longitude;
      if (offset != null) body[OFFSET] = offset;
      if (newsSlug != null && newsSlug != "null" && newsSlug.trim().isNotEmpty) body[SLUG] = newsSlug; // used in case of native link , details screen redirection

      final result = await Api.sendApiRequest(body: body, url: Api.getNewsApi);
      if (!result[ERROR]) {
        emit(SlugNewsFetchSuccess(generalNews: (result[DATA] as List).map((e) => NewsModel.fromJson(e)).toList(), totalCount: result[TOTAL]));
      } else {
        emit(SlugNewsFetchFailure(result[MESSAGE]));
      }
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
