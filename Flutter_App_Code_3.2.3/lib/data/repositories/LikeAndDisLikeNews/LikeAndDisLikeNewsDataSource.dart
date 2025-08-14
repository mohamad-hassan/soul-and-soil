import 'package:news/utils/strings.dart';
import 'package:news/utils/api.dart';

class LikeAndDisLikeRemoteDataSource {
  Future<dynamic> getLike({required String langId, required String offset, required String perPage}) async {
    try {
      final body = {LANGUAGE_ID: langId, OFFSET: offset, LIMIT: perPage};

      final result = await Api.sendApiRequest(body: body, url: Api.getLikeNewsApi);

      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future addAndRemoveLike({required String newsId, required String status}) async {
    try {
      final body = {NEWS_ID: newsId, STATUS: status};
      final result = await Api.sendApiRequest(body: body, url: Api.setLikesDislikesApi);
      return result[DATA];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
