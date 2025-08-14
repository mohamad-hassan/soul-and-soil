import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/CommentModel.dart';
import 'package:news/data/repositories/NewsComment/LikeAndDislikeComment/likeAndDislikeCommRepository.dart';
import 'package:news/utils/strings.dart';

abstract class LikeAndDislikeCommState {}

class LikeAndDislikeCommInitial extends LikeAndDislikeCommState {}

class LikeAndDislikeCommInProgress extends LikeAndDislikeCommState {}

class LikeAndDislikeCommSuccess extends LikeAndDislikeCommState {
  final CommentModel comment;
  final bool wasLikeAndDislikeCommNewsProcess;
  final bool fromLike;

  LikeAndDislikeCommSuccess(this.comment, this.wasLikeAndDislikeCommNewsProcess, this.fromLike);
}

class LikeAndDislikeCommFailure extends LikeAndDislikeCommState {
  final String errorMessage;

  LikeAndDislikeCommFailure(this.errorMessage);
}

class LikeAndDislikeCommCubit extends Cubit<LikeAndDislikeCommState> {
  final LikeAndDislikeCommRepository _likeAndDislikeCommRepository;

  LikeAndDislikeCommCubit(this._likeAndDislikeCommRepository) : super(LikeAndDislikeCommInitial());

  void setLikeAndDislikeComm({required String langId, required String commId, required String status, required bool fromLike}) async {
    try {
      emit(LikeAndDislikeCommInProgress());
      final result = await _likeAndDislikeCommRepository.setLikeAndDislikeComm(langId: langId, commId: commId, status: status);

      (!result[ERROR]) ? emit(LikeAndDislikeCommSuccess(result['updatedComment'], true, fromLike)) : emit(LikeAndDislikeCommFailure(result[MESSAGE]));
    } catch (e) {
      emit(LikeAndDislikeCommFailure(e.toString()));
    }
  }
}
