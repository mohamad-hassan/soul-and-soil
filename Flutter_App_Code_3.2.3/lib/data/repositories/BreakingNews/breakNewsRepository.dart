import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/repositories/BreakingNews/breakNewsRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class BreakingNewsRepository {
  static final BreakingNewsRepository _breakingNewsRepository = BreakingNewsRepository._internal();

  late BreakingNewsRemoteDataSource _breakingNewsRemoteDataSource;

  factory BreakingNewsRepository() {
    _breakingNewsRepository._breakingNewsRemoteDataSource = BreakingNewsRemoteDataSource();
    return _breakingNewsRepository;
  }

  BreakingNewsRepository._internal();

  Future<dynamic> getBreakingNews({required String langId}) async {
    final result = await _breakingNewsRemoteDataSource.getBreakingNews(langId: langId);

    return (result[ERROR]) ? {ERROR: result[ERROR], MESSAGE: result[MESSAGE]} : {ERROR: result[ERROR], "BreakingNews": (result[DATA] as List).map((e) => BreakingNewsModel.fromJson(e)).toList()};
  }
}
