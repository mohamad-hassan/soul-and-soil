import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/repositories/SectionById/sectionByIdRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class SectionByIdRepository {
  static final SectionByIdRepository _sectionByIdRepository = SectionByIdRepository._internal();

  late SectionByIdRemoteDataSource _sectionByIdRemoteDataSource;

  factory SectionByIdRepository() {
    _sectionByIdRepository._sectionByIdRemoteDataSource = SectionByIdRemoteDataSource();
    return _sectionByIdRepository;
  }

  SectionByIdRepository._internal();
  Future<Map<String, dynamic>> getSectionById({required String langId, required String sectionId, required String limit, required String offset, String? latitude, String? longitude}) async {
    final result = await _sectionByIdRemoteDataSource.getSectionById(langId: langId, sectionId: sectionId, latitude: latitude, longitude: longitude, limit: limit, offset: offset);

    if ((result[ERROR])) {
      return {ERROR: result[ERROR], MESSAGE: result[MESSAGE]};
    } else {
      return {ERROR: result[ERROR], DATA: (result[DATA] as List).map((e) => FeatureSectionModel.fromJson(e)).toList()};
    }
  }
}
