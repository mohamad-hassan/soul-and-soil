import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class SectionByIdRemoteDataSource {
  Future<dynamic> getSectionById({required String langId, required String limit, required String offset, required String sectionId, String? latitude, String? longitude}) async {
    try {
      final body = {LANGUAGE_ID: langId, SECTION_ID: sectionId};
      if (latitude != null && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != null && longitude != "null") body[LONGITUDE] = longitude;

      if (sectionId.isNotEmpty) {
        body[SECTION_ID] = sectionId;
      }
      body[LIMIT] = limit;
      body[OFFSET] = offset;
      final result = await Api.sendApiRequest(body: body, url: Api.getFeatureSectionApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
