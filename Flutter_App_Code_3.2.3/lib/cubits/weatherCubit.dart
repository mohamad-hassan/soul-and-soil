import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/WeatherData.dart';
import 'package:news/utils/ErrorMessageKeys.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherFetchInProgress extends WeatherState {}

class WeatherFetchSuccess extends WeatherState {
  final WeatherDetails weatherData;

  WeatherFetchSuccess({required this.weatherData});
}

class WeatherFetchFailure extends WeatherState {
  final String errorMessage;

  WeatherFetchFailure(this.errorMessage);
}

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit() : super(WeatherInitial());

  void getWeatherDetails({required String langId, String? lat, String? lon}) async {
    try {
      emit(WeatherFetchInProgress());

      final weatherResponse = await Dio().get('https://api.weatherapi.com/v1/forecast.json?key=d0f2f4dbecc043e78d6123135212408&q=${lat.toString()},${lon.toString()}&days=1&alerts=no&lang=$langId');
      print("Weather APi called $weatherResponse");
      if (weatherResponse.statusCode == 200) {
        emit(WeatherFetchSuccess(weatherData: WeatherDetails.fromJson(Map.from(weatherResponse.data))));
      } else {
        emit(WeatherFetchFailure(weatherResponse.statusMessage ?? ErrorMessageKeys.defaultErrorMessage));
      }
    } catch (e) {
      emit(WeatherFetchFailure(e.toString()));
    }
  }
}
