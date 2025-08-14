import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/repositories/BreakingNews/breakNewsRepository.dart';
import 'package:news/utils/strings.dart';

abstract class BreakingNewsState {}

class BreakingNewsInitial extends BreakingNewsState {}

class BreakingNewsFetchInProgress extends BreakingNewsState {}

class BreakingNewsFetchSuccess extends BreakingNewsState {
  final List<BreakingNewsModel> breakingNews;

  BreakingNewsFetchSuccess({required this.breakingNews});
}

class BreakingNewsFetchFailure extends BreakingNewsState {
  final String errorMessage;

  BreakingNewsFetchFailure(this.errorMessage);
}

class BreakingNewsCubit extends Cubit<BreakingNewsState> {
  final BreakingNewsRepository _breakingNewsRepository;

  BreakingNewsCubit(this._breakingNewsRepository) : super(BreakingNewsInitial());

  Future<List<BreakingNewsModel>> getBreakingNews({required String langId}) async {
    emit(BreakingNewsFetchInProgress());
    try {
      final result = await _breakingNewsRepository.getBreakingNews(langId: langId);
      (!result[ERROR]) ? emit(BreakingNewsFetchSuccess(breakingNews: result['BreakingNews'])) : emit(BreakingNewsFetchFailure(result[MESSAGE]));
      return (!result[ERROR]) ? result['BreakingNews'] : [];
    } catch (e) {
      emit(BreakingNewsFetchFailure(e.toString()));
      return [];
    }
  }
}
