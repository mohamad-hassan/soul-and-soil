import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/repositories/FeatureSection/sectionRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class SectionRepository {
  static final SectionRepository _sectionRepository = SectionRepository._internal();

  late SectionRemoteDataSource _sectionRemoteDataSource;

  factory SectionRepository() {
    _sectionRepository._sectionRemoteDataSource = SectionRemoteDataSource();
    return _sectionRepository;
  }

  SectionRepository._internal();

  Future<Map<String, dynamic>> getSection({required String langId, String? latitude, String? longitude, String? limit, String? offset, String? sectionLimit, String? sectionOffset}) async {
    final result =
        await _sectionRemoteDataSource.getSections(langId: langId, latitude: latitude, longitude: longitude, limit: limit, offset: offset, sectionLimit: sectionLimit, sectionOffset: sectionOffset);

    return (result[ERROR]) ? {ERROR: result[ERROR], MESSAGE: result[MESSAGE]} : {ERROR: result[ERROR], "Section": (result[DATA] as List).map((e) => FeatureSectionModel.fromJson(e)).toList()};
  }
}
