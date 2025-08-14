import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/GetUserNews/getUserNewsRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class GetUserNewsRepository {
  static final GetUserNewsRepository _getUserNewsRepository = GetUserNewsRepository._internal();

  late GetUserNewsRemoteDataSource _getUserNewsRemoteDataSource;

  factory GetUserNewsRepository() {
    _getUserNewsRepository._getUserNewsRemoteDataSource = GetUserNewsRemoteDataSource();
    return _getUserNewsRepository;
  }

  GetUserNewsRepository._internal();

  Future<dynamic> getGetUserNews({required String offset, required String limit, String? latitude, String? longitude}) async {
    final result = await _getUserNewsRemoteDataSource.getGetUserNews(limit: limit, offset: offset, latitude: latitude, longitude: longitude);

    return (result[ERROR])
        ? {ERROR: result[ERROR], MESSAGE: result[MESSAGE]}
        : {ERROR: result[ERROR], "total": result[TOTAL], "GetUserNews": (result[DATA] as List).map((e) => NewsModel.fromJson(e)).toList()};
  }
}
