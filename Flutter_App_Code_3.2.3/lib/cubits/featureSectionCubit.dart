import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/repositories/FeatureSection/sectionRepository.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class SectionState {}

class SectionInitial extends SectionState {}

class SectionFetchInProgress extends SectionState {}

class SectionFetchSuccess extends SectionState {
  final List<FeatureSectionModel> section;

  SectionFetchSuccess({required this.section});
}

class SectionFetchFailure extends SectionState {
  final String errorMessage;

  SectionFetchFailure(this.errorMessage);
}

class SectionCubit extends Cubit<SectionState> {
  final SectionRepository _sectionRepository;

  SectionCubit(this._sectionRepository) : super(SectionInitial());

  void getSection({required String langId, String? latitude, String? longitude}) async {
    try {
      emit(SectionFetchInProgress());
      final result = await _sectionRepository.getSection(langId: langId, latitude: latitude, longitude: longitude, limit: limitOfAPIData.toString(), offset: "0");
      (!result[ERROR]) ? emit(SectionFetchSuccess(section: result['Section'])) : emit(SectionFetchFailure(result[MESSAGE]));
    } catch (e) {
      emit(SectionFetchFailure(e.toString()));
    }
  }
}
