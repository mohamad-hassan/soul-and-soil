import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsRepository.dart';
import 'package:news/utils/strings.dart';

abstract class LikeAndDisLikeState {}

class LikeAndDisLikeInitial extends LikeAndDisLikeState {}

class LikeAndDisLikeFetchInProgress extends LikeAndDisLikeState {}

class LikeAndDisLikeFetchSuccess extends LikeAndDisLikeState {
  final List<NewsModel> likeAndDisLike;
  final int totalLikeAndDisLikeCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  LikeAndDisLikeFetchSuccess({required this.likeAndDisLike, required this.totalLikeAndDisLikeCount, required this.hasMoreFetchError, required this.hasMore});
}

class LikeAndDisLikeFetchFailure extends LikeAndDisLikeState {
  final String errorMessage;

  LikeAndDisLikeFetchFailure(this.errorMessage);
}

class LikeAndDisLikeCubit extends Cubit<LikeAndDisLikeState> {
  final LikeAndDisLikeRepository likeAndDisLikeRepository;
  int perPageLimit = 25;

  LikeAndDisLikeCubit(this.likeAndDisLikeRepository) : super(LikeAndDisLikeInitial());

  void getLike({required String langId}) async {
    try {
      emit(LikeAndDisLikeFetchInProgress());
      final result = await likeAndDisLikeRepository.getLike(limit: perPageLimit.toString(), offset: "0", langId: langId);
      emit(LikeAndDisLikeFetchSuccess(
          likeAndDisLike: result['LikeAndDisLike'], totalLikeAndDisLikeCount: result[TOTAL], hasMoreFetchError: false, hasMore: (result['LikeAndDisLike'] as List<NewsModel>).length < result[TOTAL]));
    } catch (e) {
      emit(LikeAndDisLikeFetchFailure(e.toString()));
    }
  }

  bool isNewsLikeAndDisLike(String newsId) {
    if (state is LikeAndDisLikeFetchSuccess) {
      final likeAndDisLike = (state as LikeAndDisLikeFetchSuccess).likeAndDisLike;
      return likeAndDisLike.indexWhere((element) => (element.id == newsId || element.newsId == newsId)) != -1;
    }
    return false;
  }

  void resetState() {
    emit(LikeAndDisLikeFetchInProgress());
  }
}
