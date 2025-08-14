import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart' as loc;
import 'package:marqueer/marqueer.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Auth/registerTokenCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/cubits/breakingNewsCubit.dart';
import 'package:news/cubits/featureSectionCubit.dart';
import 'package:news/cubits/generalNewsCubit.dart';
import 'package:news/cubits/getUserDataByIdCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/languageJsonCubit.dart';
import 'package:news/cubits/liveStreamCubit.dart';
import 'package:news/cubits/otherPagesCubit.dart';
import 'package:news/cubits/sectionByIdCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:news/cubits/weatherCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/SectionById/sectionByIdRepository.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/screens/HomePage/Widgets/GeneralNewsRandomStyle.dart';
import 'package:news/ui/screens/HomePage/Widgets/LiveWithSearchView.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionShimmer.dart';
import 'package:news/ui/screens/HomePage/Widgets/WeatherData.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle1.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle2.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle3.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle4.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle5.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionStyle6.dart';
import 'package:news/ui/screens/Profile/Widgets/customAlertDialog.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/adSpaces.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:news/utils/strings.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/data/models/AuthModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // WeatherDetails? weatherData;
  // bool weatherLoad = true;
  final loc.Location _location = loc.Location();
  bool? _serviceEnabled;
  loc.PermissionStatus? _permissionGranted;
  double? lat;
  double? lon;
  bool updateList = false;
  Set<String> get locationValue => SettingsLocalDataRepository().getLocationCityValues();
  late final appConfig, authConfig;
  String languageId = "14"; //set it as default language code

  void getSections() {
    Future.delayed(Duration.zero, () {
      context.read<SectionCubit>().getSection(langId: languageId, latitude: locationValue.first, longitude: locationValue.last);
    }).whenComplete(() => getGeneralNews());
  }

  void getLiveStreamData() {
    Future.delayed(Duration.zero, () {
      context.read<LiveStreamCubit>().getLiveStream(langId: languageId);
    });
  }

  void getBookmark() {
    Future.delayed(Duration.zero, () {
      context.read<BookmarkCubit>().getBookmark(langId: languageId);
    });
  }

  void getLikeNews() {
    Future.delayed(Duration.zero, () {
      context.read<LikeAndDisLikeCubit>().getLike(langId: languageId);
    });
  }

  void getUserData() {
    Future.delayed(Duration.zero, () {
      context.read<GetUserByIdCubit>().getUserById();
    });
  }

  checkForAppUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.read<AppConfigurationCubit>().state is AppConfigurationFetchSuccess) {
        if (context.read<AppConfigurationCubit>().isUpdateRequired()) {
          openUpdateDialog();
        }
      }
    });
  }

  openUpdateDialog() {
    bool isForceUpdate = (context.read<AppConfigurationCubit>().getForceUpdateMode() != "" && context.read<AppConfigurationCubit>().getForceUpdateMode() == "1") ? true : false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return CustomAlertDialog(
              isForceAppUpdate: (isForceUpdate) ? true : false,
              context: context,
              yesButtonText: 'yesLbl',
              yesButtonTextPostfix: '',
              noButtonText: (isForceUpdate) ? 'exitLbl' : 'noLbl',
              imageName: '',
              titleWidget: CustomTextLabel(
                text: (isForceUpdate) ? 'forceUpdateTitleLbl' : 'newVersionAvailableTitleLbl',
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: UiUtils.getColorScheme(context).primaryContainer),
              ),
              messageText: context.read<LanguageJsonCubit>().getTranslatedLabels((isForceUpdate) ? 'forceUpdateDescLbl' : 'newVersionAvailableDescLbl'),
              onYESButtonPressed: () => UiUtils.gotoStores(context),
            );
          },
        );
      },
    );
  }

  showPermissionPopup() async {
    loc.LocationData locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      SettingsLocalDataRepository().setLocationCityKeys(null, null);
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await _location.getLocation();

    setState(() {
      lat = locationData.latitude;
      lon = locationData.longitude;
    });
    getLocationPermission();

    return (locationData);
  }

  getLocationPermission() async {
    if (appConfig.getLocationWiseNewsMode() == "1") {
      SettingsLocalDataRepository().setLocationCityKeys(lat, lon);
      //update latitude,longitude - along with token
      if (context.read<SettingsCubit>().getSettings().token != '') {
        context.read<RegisterTokenCubit>().registerToken(fcmId: context.read<SettingsCubit>().getSettings().token, context: context);
        context.read<SettingsCubit>().changeFcmToken(context.read<SettingsCubit>().getSettings().token);
      }
    } else {
      SettingsLocalDataRepository().setLocationCityKeys(null, null);
    }

    if (appConfig.getWeatherMode() == "1") {
      getWeatherData();
    }
  }

  Future<void> getWeatherData() async {
    if (lat != null && lon != null) {
      context.read<WeatherCubit>().getWeatherDetails(langId: (Hive.box(settingsBoxKey).get(currentLanguageCodeKey)), lat: lat.toString(), lon: lon.toString());
    }
  }

  void getBreakingNews() {
    Future.delayed(Duration.zero, () {
      context.read<BreakingNewsCubit>().getBreakingNews(langId: languageId);
    });
  }

  void getGeneralNews() {
    context.read<GeneralNewsCubit>().getGeneralNews(langId: languageId, latitude: locationValue.first, longitude: locationValue.last);
  }

  @override
  void initState() {
    super.initState();
    appConfig = context.read<AppConfigurationCubit>();
    authConfig = context.read<AuthCubit>();
    languageId = context.read<AppLocalizationCubit>().state.id;
    checkForAppUpdate();
    getSections();
    if (appConfig.getWeatherMode() == "1" || appConfig.getLocationWiseNewsMode() == "1") showPermissionPopup();
    if (authConfig.getUserId() != "0") {
      getUserData();
    }
    getLiveStreamData();
    if (appConfig.getBreakingNewsMode() == "1") getBreakingNews();
    if (appConfig.getMaintenanceMode() == "1") Navigator.of(context).pushReplacementNamed(Routes.maintenance);
  }

  Widget breakingNewsMarquee() {
    return BlocBuilder<BreakingNewsCubit, BreakingNewsState>(
      builder: ((context, state) {
        return (state is BreakingNewsFetchSuccess && state.breakingNews.isNotEmpty)
            ? Container(
                margin: const EdgeInsets.only(top: 10),
                color: UiUtils.getColorScheme(context).primaryContainer,
                height: 32,
                child: Marqueer.builder(
                  pps: 25.0,
                  restartAfterInteractionDuration: const Duration(seconds: 1),
                  separatorBuilder: (_, index) => Center(
                    child: Text(
                      ' ● ',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).secondary, fontWeight: FontWeight.normal),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    var multiplier = index ~/ state.breakingNews.length;
                    var i = index;
                    if (multiplier > 0) {
                      i = index - (multiplier * state.breakingNews.length);
                    }
                    final item = state.breakingNews[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: CustomTextLabel(
                        text: item.title!,
                        textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).secondary, fontWeight: FontWeight.normal),
                      ),
                    );
                  },
                ),
              )
            : const SizedBox.shrink();
      }),
    );
  }

  Widget getSectionList() {
    return BlocBuilder<GeneralNewsCubit, GeneralNewsState>(
      builder: (context, newsState) {
        return BlocBuilder<SectionCubit, SectionState>(
          builder: (context, sectionState) {
            if (sectionState is SectionFetchSuccess) {
              //if it has only one section and it doesn't have news in it  then show No data found message
              if (sectionState.section.length == 1) {
                if (sectionState.section.first.newsType == "breaking_news") {
                  if (sectionState.section.first.breakNewsTotal == 0) {
                    return ErrorContainerWidget(errorMsg: ErrorMessageKeys.noDataMessage, onRetry: _refresh);
                  }
                } else if (sectionState.section.first.newsTotal != null && sectionState.section.first.newsTotal! == 0) {
                  return ErrorContainerWidget(errorMsg: ErrorMessageKeys.noDataMessage, onRetry: _refresh);
                }
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) {
                  FeatureSectionModel model = sectionState.section[index];
                  return sectionData(model: model);
                }),
                itemCount: sectionState.section.length,
              );
            }
            if (sectionState is SectionFetchFailure) {
              if (context.read<GeneralNewsCubit>().state is GeneralNewsFetchSuccess) {
                return sectionData(newsModelList: (context.read<GeneralNewsCubit>().state as GeneralNewsFetchSuccess).generalNews);
              } else {
                return ErrorContainerWidget(
                  errorMsg: (sectionState.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : sectionState.errorMessage,
                  onRetry: _refresh,
                );
              }
            }
            return sectionShimmer(context); //state is SectionFetchInProgress || state is SectionInitial
          },
        );
      },
    );
  }

  Widget sectionData({FeatureSectionModel? model, List<NewsModel>? newsModelList}) {
    return (model != null)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (model.adSpaceDetails != null) AdSpaces(adsModel: model.adSpaceDetails!), //sponsored ads
              if (model.styleApp == 'style_1') Style1Section(model: model),
              if (model.styleApp == 'style_2') Style2Section(model: model),
              if (model.styleApp == 'style_3') Style3Section(model: model),
              if (model.styleApp == 'style_4') Style4Section(model: model),
              if (model.styleApp == 'style_5') Style5Section(model: model),
              if (model.styleApp == 'style_6')
                BlocProvider(
                  create: (context) => SectionByIdCubit(SectionByIdRepository()),
                  child: Style6Section(model: model),
                ),
            ],
          )
        : GeneralNewsRandomStyle(modelList: newsModelList!);
  }

  //refresh function to refresh page
  Future<void> _refresh() async {
    getSections();
    getLocationPermission();
    if (authConfig.getUserId() != "0") {
      getUserData();
      getBookmark();
      getLikeNews();
    }
    getLiveStreamData();
    getPages();

    if (appConfig.getBreakingNewsMode() == "1") getBreakingNews();
    if (appConfig.getMaintenanceMode() == "1") Navigator.of(context).pushReplacementNamed(Routes.maintenance);
    if (appConfig.getWeatherMode() == "1") getWeatherData();
  }

  getPages() {
    Future.delayed(Duration.zero, () {
      context.read<OtherPageCubit>().getOtherPage(langId: languageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () => _refresh(),
          child: BlocListener<GetUserByIdCubit, GetUserByIdState>(
            bloc: context.read<GetUserByIdCubit>(),
            listener: (context, state) {
              if (state is GetUserByIdFetchSuccess) {
                var data = state.result;
                if (data[STATUS] == 0) {
                  showSnackBar(UiUtils.getTranslatedLabel(context, 'deactiveMsg'), context);
                  Future.delayed(const Duration(seconds: 2), () {
                    UiUtils.userLogOut(contxt: context);
                  });
                } else {
                  authConfig.updateDetails(
                    authModel: AuthModel(
                      id: data[ID].toString(),
                      name: data[NAME],
                      status: data[STATUS].toString(),
                      mobile: data[MOBILE],
                      email: data[EMAIL],
                      type: data[TYPE],
                      profile: data[PROFILE],
                      role: data[ROLE].toString(),
                      jwtToken: data[TOKEN],
                    ),
                  );
                }
              }
            },
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(), //To restrict scrolling on Refresh
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, bottom: 10.0),
                child: Column(
                  children: [
                    const LiveWithSearchView(),
                    BlocBuilder<WeatherCubit, WeatherState>(
                      builder: (context, state) {
                        if (state is WeatherFetchSuccess) {
                          return WeatherDataView(weatherData: state.weatherData);
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    breakingNewsMarquee(),
                    getSectionList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
