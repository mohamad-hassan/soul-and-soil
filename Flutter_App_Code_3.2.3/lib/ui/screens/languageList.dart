import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/Auth/registerTokenCubit.dart';
import 'package:news/cubits/generalNewsCubit.dart';
import 'package:news/cubits/rssFeedCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/cubits/breakingNewsCubit.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/screens/dashBoard/dashBoardScreen.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customAppBar.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/languageCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/categoryCubit.dart';
import 'package:news/cubits/featureSectionCubit.dart';
import 'package:news/cubits/languageJsonCubit.dart';
import 'package:news/cubits/liveStreamCubit.dart';
import 'package:news/cubits/otherPagesCubit.dart';
import 'package:news/cubits/videosCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/UserNotification/userNotificationCubit.dart';

class LanguageList extends StatefulWidget {
  final String? from;
  const LanguageList({super.key, this.from});

  @override
  LanguageListState createState() => LanguageListState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(builder: (_) => LanguageList(from: arguments['from']));
  }
}

class LanguageListState extends State<LanguageList> {
  String? selLanCode, selLanId;
  late String latitude, longitude;
  int? selLanRTL;
  bool isNetworkAvail = true;

  @override
  void initState() {
    isNetworkAvailable();
    getLanguageData();
    setLatitudeLongitude();
    super.initState();
  }

  Future getLanguageData() async {
    Future.delayed(Duration.zero, () {
      context.read<LanguageCubit>().getLanguage();
    });
  }

  void setLatitudeLongitude() {
    latitude = SettingsLocalDataRepository().getLocationCityValues().first;
    longitude = SettingsLocalDataRepository().getLocationCityValues().last;
  }

  Widget getLangList() {
    return BlocBuilder<AppLocalizationCubit, AppLocalizationState>(builder: (context, stateLocale) {
      return BlocBuilder<LanguageCubit, LanguageState>(builder: (context, state) {
        if (state is LanguageFetchSuccess) {
          return ListView.separated(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                return Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: (selLanCode ?? stateLocale.languageCode) == state.language[index].code! ? UiUtils.getColorScheme(context).primaryContainer : null),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            Intl.defaultLocale = state.language[index].code;
                            selLanCode = state.language[index].code!;
                            selLanId = state.language[index].id!;
                            selLanRTL = state.language[index].isRTL!;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomNetworkImage(networkImageUrl: state.language[index].image!, isVideo: false, height: 40, fit: BoxFit.fill, width: 40),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                              CustomTextLabel(
                                  text: state.language[index].languageDisplayName ?? state.language[index].language!,
                                  textStyle: Theme.of(this.context).textTheme.titleLarge?.copyWith(
                                      color: ((selLanCode ?? (stateLocale).languageCode) == state.language[index].code!)
                                          ? UiUtils.getColorScheme(context).secondary
                                          : UiUtils.getColorScheme(context).primaryContainer)),
                            ],
                          ),
                        ),
                      ),
                    ));
              }),
              separatorBuilder: (context, index) {
                return const SizedBox(height: 1.0);
              },
              itemCount: state.language.length);
        }
        if (state is LanguageFetchFailure) {
          return Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: ErrorContainerWidget(
                errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : state.errorMessage, onRetry: getLanguageData),
          );
        }
        return const Padding(padding: EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0), child: SizedBox.shrink());
      });
    });
  }

  saveBtn() {
    return BlocConsumer<LanguageJsonCubit, LanguageJsonState>(
        bloc: context.read<LanguageJsonCubit>(),
        listener: (context, state) {
          if (state is LanguageJsonFetchSuccess) {
            final langId = selLanId ?? context.read<AppLocalizationCubit>().state.id;

            UiUtils.setDynamicStringValue(
              context.read<AppLocalizationCubit>().state.languageCode,
              jsonEncode(state.languageJson),
            ).then((_) {
              // Update languageId
              homeScreenKey?.currentState?.languageId = langId;

              // Fetch general data
              context.read<OtherPageCubit>().getOtherPage(langId: langId);
              context.read<SectionCubit>().getSection(langId: langId, latitude: latitude, longitude: longitude);
              context.read<LiveStreamCubit>().getLiveStream(langId: langId);
              context.read<GeneralNewsCubit>().getGeneralNews(langId: langId, latitude: latitude, longitude: longitude);
              context.read<VideoCubit>().getVideo(langId: langId, latitude: latitude, longitude: longitude);
              context.read<CategoryCubit>().getCategory(langId: langId);

              // Conditional based on config
              final config = context.read<AppConfigurationCubit>();
              if (config.getWeatherMode() == "1") {
                homeScreenKey?.currentState?.getWeatherData();
              }
              if (config.getRSSFeedMode() == "1") {
                context.read<RSSFeedCubit>().getRSSFeed(langId: langId);
              }
              if (config.getBreakingNewsMode() == "1") {
                context.read<BreakingNewsCubit>().getBreakingNews(langId: langId);
              }

              // If user is logged in
              final auth = context.read<AuthCubit>();
              if (auth.getUserId() != "0") {
                context.read<LikeAndDisLikeCubit>().getLike(langId: langId);
                context.read<BookmarkCubit>().getBookmark(langId: langId);
                context.read<UserNotificationCubit>().getUserNotification();
                updateUserLanguageWithFCMid();
              }
            });

            if (widget.from != null && widget.from == "firstLogin" && context.read<CategoryCubit>().getCatList().isNotEmpty) {
              //check if it is firstLogin - then goto Home or else pop
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.managePref, (route) => false, arguments: {"from": 2});
            } else if (widget.from == "firstLogin") {
              Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
            } else {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          if (state is LanguageJsonFetchSuccess) {
            return InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                    height: 45.0,
                    margin: const EdgeInsetsDirectional.all(20),
                    width: MediaQuery.of(context).size.width * 0.9,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(15.0)),
                    child: CustomTextLabel(text: 'saveLbl', textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: backgroundColor, fontWeight: FontWeight.bold))),
                onTap: () {
                  setState(() {
                    if (selLanCode != null && context.read<AppLocalizationCubit>().state.languageCode != selLanCode) {
                      context.read<AppLocalizationCubit>().changeLanguage(selLanCode!, selLanId!, selLanRTL!);
                      context.read<LanguageJsonCubit>().getLanguageJson(lanCode: selLanCode!);
                    } else {
                      if (widget.from != null && widget.from == "firstLogin" && context.read<CategoryCubit>().getCatList().isNotEmpty) {
                        Navigator.of(context).pushNamedAndRemoveUntil(Routes.managePref, (route) => false, arguments: {"from": 2});
                      } else if (widget.from == "firstLogin") {
                        Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
                      } else {
                        Navigator.pop(context);
                      }
                    }
                  });
                });
          }
          return const SizedBox.shrink();
        });
  }

  void updateUserLanguageWithFCMid() async {
    String currentFCMId = context.read<SettingsCubit>().getSettings().token.trim();

    if (currentFCMId.isEmpty) {
      final newToken = await FirebaseMessaging.instance.getToken();
      if (newToken != null) {
        currentFCMId = newToken;
        context.read<RegisterTokenCubit>().registerToken(fcmId: currentFCMId, context: context);
      }
    } else {
      context.read<RegisterTokenCubit>().registerToken(fcmId: currentFCMId, context: context);
    }

    context.read<SettingsCubit>().changeFcmToken(currentFCMId);
  }

  isNetworkAvailable() async {
    if (await InternetConnectivity.isNetworkAvailable()) {
      setState(() {
        isNetworkAvail = true;
      });
    } else {
      setState(() {
        isNetworkAvail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(height: 45, isBackBtn: true, label: 'chooseLanLbl', horizontalPad: 15, isConvertText: true),
        bottomNavigationBar: (isNetworkAvail) ? saveBtn() : const SizedBox.shrink(),
        body: getLangList());
  }
}
