import 'package:news/data/models/CommentModel.dart';
import 'package:news/data/repositories/NewsComment/LikeAndDislikeComment/likeAndDislikeCommDataSource.dart';
import 'package:news/utils/strings.dart';

class LikeAndDislikeCommRepository {
  static final LikeAndDislikeCommRepository _likeAndDislikeCommRepository = LikeAndDislikeCommRepository._internal();
  late LikeAndDislikeCommRemoteDataSource _likeAndDislikeCommRemoteDataSource;

  factory LikeAndDislikeCommRepository() {
    _likeAndDislikeCommRepository._likeAndDislikeCommRemoteDataSource = LikeAndDislikeCommRemoteDataSource();
    return _likeAndDislikeCommRepository;
  }

  LikeAndDislikeCommRepository._internal();

  Future<Map<String, dynamic>> setLikeAndDislikeComm({required String langId, required String commId, required String status}) async {
    final result = await _likeAndDislikeCommRemoteDataSource.likeAndDislikeComm(langId: langId, commId: commId, status: status);

    if (result[ERROR]) {
      return {ERROR: result[ERROR], MESSAGE: result[MESSAGE]};
    } else {
      final List<CommentModel> commentsList = (result[DATA] as List).map((e) => CommentModel.fromJson(e)).toList();
      CommentModel? updatedComment;

      commentsList.forEach((element) {
        if (element.id! == commId) {
          updatedComment = element;
        } else if (element.replyComList!.any((sublist) => sublist.id == commId) == true) {
          updatedComment = element;
        }
      });
      return {ERROR: result[ERROR], "total": result[TOTAL], "updatedComment": updatedComment ?? CommentModel.fromJson({})};
    }
  }
}
