import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class BreakingNewsRemoteDataSource {
  Future<dynamic> getBreakingNews({required String langId}) async {
    try {
      final body = {LANGUAGE_ID: langId};
      final result = await Api.sendApiRequest(body: body, url: Api.getBreakingNewsApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
