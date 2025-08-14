import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class LiveStreamRemoteDataSource {
  Future<dynamic> getLiveStreams({required String langId}) async {
    try {
      final body = {LANGUAGE_ID: langId};
      final result = await Api.sendApiRequest(body: body, url: Api.getLiveStreamingApi);

      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
