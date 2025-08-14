import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/GetSurveyAnswer/getSurveyAnsRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class GetSurveyAnsRepository {
  static final GetSurveyAnsRepository _getSurveyAnsRepository = GetSurveyAnsRepository._internal();

  late GetSurveyAnsRemoteDataSource _getSurveyAnsRemoteDataSource;

  factory GetSurveyAnsRepository() {
    _getSurveyAnsRepository._getSurveyAnsRemoteDataSource = GetSurveyAnsRemoteDataSource();
    return _getSurveyAnsRepository;
  }

  GetSurveyAnsRepository._internal();
  Future<Map<String, dynamic>> getSurveyAns({required String langId}) async {
    final result = await _getSurveyAnsRemoteDataSource.getSurveyAns(langId: langId);
    return {"GetSurveyAns": (result[DATA] as List).map((e) => NewsModel.fromSurvey(e)).toList()};
  }
}
