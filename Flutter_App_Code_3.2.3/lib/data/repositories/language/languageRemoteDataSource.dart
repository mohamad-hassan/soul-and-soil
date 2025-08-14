import 'package:news/utils/api.dart';

class LanguageRemoteDataSource {
  Future<dynamic> getLanguages() async {
    try {
      final result = await Api.sendApiRequest(url: Api.getLanguagesApi, body: {});
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
