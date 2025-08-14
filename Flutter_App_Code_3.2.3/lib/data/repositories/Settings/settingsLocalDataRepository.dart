import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:news/utils/uiUtils.dart';

class SettingsLocalDataRepository {
  Future<void> setLanguagePreferences({required String code, required String id, required int rtl}) async {
    final box = Hive.box(settingsBoxKey);
    await Future.wait([box.put(currentLanguageCodeKey, code), box.put(currentLanguageIDKey, id), box.put(currentLanguageRTLKey, rtl)]);

    UiUtils.checkIfValidLocale(); // only if you want to validate locale after setting
  }

  String getCurrentLanguageCode() {
    return Hive.box(settingsBoxKey).get(currentLanguageCodeKey) ?? "";
  }

  String getCurrentLanguageId() {
    return Hive.box(settingsBoxKey).get(currentLanguageIDKey) ?? '';
  }

  int getCurrentLanguageRTL() {
    final value = Hive.box(settingsBoxKey).get(currentLanguageRTLKey);
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else {
      return 0;
    }
  }

  Future<void> setIntroSlider(bool value) async {
    Hive.box(settingsBoxKey).put(introSliderKey, value);
  }

  bool getIntroSlider() {
    return Hive.box(settingsBoxKey).get(introSliderKey) ?? true;
  }

  Future<void> setFcmToken(String value) async {
    Hive.box(settingsBoxKey).put(tokenKey, value);
  }

  String getFcmToken() {
    return Hive.box(settingsBoxKey).get(tokenKey) ?? "";
  }

  Future<void> setCurrentTheme(String value) async {
    Hive.box(settingsBoxKey).put(currentThemeKey, value);
  }

  String getCurrentTheme() {
    return Hive.box(settingsBoxKey).get(currentThemeKey) ?? "";
  }

  Future<void> setNotification(bool value) async {
    Hive.box(settingsBoxKey).put(notificationKey, value);
  }

  bool getNotification() {
    return Hive.box(settingsBoxKey).get(notificationKey) ?? true;
  }

  Future<void> setLocationCityKeys(double? latitude, double? longitude) async {
    Hive.box(locationCityBoxKey).put(latitudeKey, latitude);
    Hive.box(locationCityBoxKey).put(longitudeKey, longitude);
  }

  Set<String> getLocationCityValues() {
    Set<String> locationValues = {Hive.box(locationCityBoxKey).get(latitudeKey).toString(), Hive.box(locationCityBoxKey).get(longitudeKey).toString()};
    return locationValues;
  }

  ValueListenable<Box> getVideoScreenStyle() {
    return Hive.box(videoPreferenceKey).listenable();
  }
}
