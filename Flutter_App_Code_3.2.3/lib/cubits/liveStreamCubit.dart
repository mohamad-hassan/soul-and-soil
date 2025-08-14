import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/LiveStreamingModel.dart';
import 'package:news/data/repositories/LiveStream/liveStreamRepository.dart';
import 'package:news/utils/strings.dart';

abstract class LiveStreamState {}

class LiveStreamInitial extends LiveStreamState {}

class LiveStreamFetchInProgress extends LiveStreamState {}

class LiveStreamFetchSuccess extends LiveStreamState {
  final List<LiveStreamingModel> liveStream;

  LiveStreamFetchSuccess({required this.liveStream});
}

class LiveStreamFetchFailure extends LiveStreamState {
  final String errorMessage;

  LiveStreamFetchFailure(this.errorMessage);
}

class LiveStreamCubit extends Cubit<LiveStreamState> {
  final LiveStreamRepository _liveStreamRepository;

  LiveStreamCubit(this._liveStreamRepository) : super(LiveStreamInitial());

  void getLiveStream({required String langId}) async {
    try {
      emit(LiveStreamFetchInProgress());
      final result = await _liveStreamRepository.getLiveStream(langId: langId);

      (!result[ERROR]) ? emit(LiveStreamFetchSuccess(liveStream: result['LiveStream'])) : emit(LiveStreamFetchFailure(result[MESSAGE]));
    } catch (e) {
      emit(LiveStreamFetchFailure(e.toString()));
    }
  }
}
