import 'package:news/data/models/appLanguageModel.dart';
import 'package:news/data/repositories/language/languageRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class LanguageRepository {
  static final LanguageRepository _languageRepository = LanguageRepository._internal();

  late LanguageRemoteDataSource _languageRemoteDataSource;

  factory LanguageRepository() {
    _languageRepository._languageRemoteDataSource = LanguageRemoteDataSource();
    return _languageRepository;
  }

  LanguageRepository._internal();

  Future<Map<String, dynamic>> getLanguage() async {
    final result = await _languageRemoteDataSource.getLanguages();

    return {"Language": (result[DATA] as List).map((e) => LanguageModel.fromJson(e)).toList()};
  }
}
