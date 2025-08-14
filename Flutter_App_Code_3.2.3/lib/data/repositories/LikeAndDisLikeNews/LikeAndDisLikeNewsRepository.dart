import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsDataSource.dart';
import 'package:news/utils/strings.dart';

class LikeAndDisLikeRepository {
  static final LikeAndDisLikeRepository _LikeAndDisLikeRepository = LikeAndDisLikeRepository._internal();
  late LikeAndDisLikeRemoteDataSource _LikeAndDisLikeRemoteDataSource;

  factory LikeAndDisLikeRepository() {
    _LikeAndDisLikeRepository._LikeAndDisLikeRemoteDataSource = LikeAndDisLikeRemoteDataSource();
    return _LikeAndDisLikeRepository;
  }

  LikeAndDisLikeRepository._internal();

  Future<Map<String, dynamic>> getLike({required String offset, required String limit, required String langId}) async {
    final result = await _LikeAndDisLikeRemoteDataSource.getLike(perPage: limit, offset: offset, langId: langId);

    return {"total": result[TOTAL], "LikeAndDisLike": (result[DATA] as List).map((e) => NewsModel.fromJson(e)).toList()};
  }

  Future setLike({required String newsId, required String status}) async {
    final result = await _LikeAndDisLikeRemoteDataSource.addAndRemoveLike(status: status, newsId: newsId);
    return result;
  }
}
