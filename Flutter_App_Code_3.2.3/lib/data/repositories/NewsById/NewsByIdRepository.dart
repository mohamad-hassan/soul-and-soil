import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/NewsById/NewsByIdRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class NewsByIdRepository {
  static final NewsByIdRepository _newsByIdRepository = NewsByIdRepository._internal();

  late NewsByIdRemoteDataSource _newsByIdRemoteDataSource;

  factory NewsByIdRepository() {
    _newsByIdRepository._newsByIdRemoteDataSource = NewsByIdRemoteDataSource();
    return _newsByIdRepository;
  }

  NewsByIdRepository._internal();

  Future<Map<String, dynamic>> getNewsById({required String newsId, required String langId}) async {
    final result = await _newsByIdRemoteDataSource.getNewsById(newsId: newsId, langId: langId);

    return {"NewsById": (result[DATA] as List).map((e) => NewsModel.fromJson(e)).toList()};
  }
}
