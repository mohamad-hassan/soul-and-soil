import 'package:news/data/models/LiveStreamingModel.dart';
import 'package:news/data/repositories/LiveStream/liveRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class LiveStreamRepository {
  static final LiveStreamRepository _liveStreamRepository = LiveStreamRepository._internal();

  late LiveStreamRemoteDataSource _liveStreamRemoteDataSource;

  factory LiveStreamRepository() {
    _liveStreamRepository._liveStreamRemoteDataSource = LiveStreamRemoteDataSource();
    return _liveStreamRepository;
  }

  LiveStreamRepository._internal();

  Future<dynamic> getLiveStream({required String langId}) async {
    final result = await _liveStreamRemoteDataSource.getLiveStreams(langId: langId);

    return (result[ERROR]) ? {ERROR: result[ERROR], MESSAGE: result[MESSAGE]} : {ERROR: result[ERROR], "LiveStream": (result[DATA] as List).map((e) => LiveStreamingModel.fromJson(e)).toList()};
  }
}
