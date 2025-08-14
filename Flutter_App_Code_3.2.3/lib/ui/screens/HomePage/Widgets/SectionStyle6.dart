import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/sectionByIdCubit.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/widgets/customTextLabel.dart';

class Style6Section extends StatefulWidget {
  final FeatureSectionModel model;

  const Style6Section({super.key, required this.model});

  @override
  Style6SectionState createState() => Style6SectionState();
}

class Style6SectionState extends State<Style6Section> {
  int? style6Sel;
  bool isNews = true;
  late final ScrollController style6ScrollController = ScrollController()..addListener(hasMoreSectionScrollListener);
  late BreakingNewsModel breakingNewsData;
  late NewsModel newsData;

  @override
  void initState() {
    super.initState();
    getSectionDataById();
  }

  @override
  void dispose() {
    style6ScrollController.removeListener(() {});
    super.dispose();
  }

  void hasMoreSectionScrollListener() {
    if (style6ScrollController.position.maxScrollExtent == style6ScrollController.offset) {
      if (context.read<SectionByIdCubit>().hasMoreSections() && !(context.read<SectionByIdCubit>().state is SectionByIdFetchInProgress)) {
        print("style 6 : more section news to be fetched & state is ${context.read<SectionByIdCubit>().state}");
        context.read<SectionByIdCubit>().getMoreSectionById(langId: context.read<AppLocalizationCubit>().state.id, sectionId: widget.model.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return style6Data();
  }

  void getSectionDataById() {
    Future.delayed(Duration.zero, () {
      context.read<SectionByIdCubit>().getSectionById(
          langId: context.read<AppLocalizationCubit>().state.id,
          sectionId: widget.model.id!,
          latitude: SettingsLocalDataRepository().getLocationCityValues().first,
          longitude: SettingsLocalDataRepository().getLocationCityValues().last);
    });
  }

  Widget style6Data() {
    return BlocBuilder<SectionByIdCubit, SectionByIdState>(builder: (context, state) {
      print(" state $state");
      if (state is SectionByIdFetchSuccess) {
        isNews = (state.type == 'news' || state.type == 'user_choice' || state.type == 'videos') && state.newsModel.isNotEmpty
            ? true
            : (state.type == 'breaking_news' || state.type == 'videos') && state.breakNewsModel.isNotEmpty
                ? false
                : isNews;
        int totalCount = (isNews) ? state.newsModel.length : state.breakNewsModel.length;
        return (state.breakNewsModel.isNotEmpty || state.newsModel.isNotEmpty)
            ? Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: style6NewsDetails(newsData: state.newsModel, brNewsData: state.breakNewsModel, total: totalCount, type: state.type))
            : SizedBox.shrink();
      }
      return SizedBox.shrink();
    });
  }

  Widget style6NewsDetails({List<NewsModel>? newsData, List<BreakingNewsModel>? brNewsData, String? type, int total = 0}) {
    return SizedBox(
        height: MediaQuery.of(context).size.height / 2.8,
        child: SingleChildScrollView(
            controller: style6ScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
                children: List.generate(total, (index) {
              return SizedBox(
                  width: 180,
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: (isNews)
                          ? setImageCard(index: index, total: total, type: type!, newsModel: newsData![index], allNewsList: newsData)
                          : setImageCard(index: index, total: total, type: type!, breakingNewsModel: brNewsData![index], breakingNewsList: brNewsData)));
            }))));
  }

  Widget setImageCard(
      {required int index,
      required int total,
      required String type,
      NewsModel? newsModel,
      BreakingNewsModel? breakingNewsModel,
      List<NewsModel>? allNewsList,
      List<BreakingNewsModel>? breakingNewsList}) {
    return InkWell(
      child: Stack(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, darkSecondaryColor.withOpacity(0.9)]).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child: Container(
                color: primaryColor.withValues(alpha: 0.15),
                width: MediaQuery.of(context).size.width / 1.9,
                height: MediaQuery.of(context).size.height / 2.5,
                child: CustomNetworkImage(
                    networkImageUrl: (newsModel != null) ? newsModel.image! : breakingNewsModel!.image!,
                    height: MediaQuery.of(context).size.height / 2.5,
                    width: MediaQuery.of(context).size.width / 1.9,
                    fit: BoxFit.cover,
                    isVideo: type == "videos"),
              ),
            )),
        (newsModel != null && newsModel.categoryName != null)
            ? Align(
                alignment: Alignment.topLeft,
                child: Container(
                    margin: const EdgeInsetsDirectional.only(start: 7.0, top: 7.0),
                    height: 20.0,
                    padding: const EdgeInsetsDirectional.only(start: 6.0, end: 6.0, top: 2.5),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Theme.of(context).primaryColor),
                    child: CustomTextLabel(
                        text: newsModel.categoryName!,
                        textAlign: TextAlign.center,
                        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true)))
            : const SizedBox.shrink(),
        (type == "videos")
            ? Positioned.directional(
                textDirection: Directionality.of(context),
                top: MediaQuery.of(context).size.height * 0.13,
                start: MediaQuery.of(context).size.width / 6,
                end: MediaQuery.of(context).size.width / 6,
                child: UiUtils.setPlayButton(context: context))
            : const SizedBox.shrink(),
        Positioned.directional(
          textDirection: Directionality.of(context),
          bottom: 5,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            (newsModel != null)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextLabel(
                        text: UiUtils.convertToAgo(context, DateTime.parse(newsModel.publishDate ?? newsModel.date!), 3)!,
                        textStyle: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white)))
                : const SizedBox.shrink(),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                width: MediaQuery.of(context).size.width * 0.50,
                child: CustomTextLabel(
                    text: (newsModel != null) ? newsModel.title! : breakingNewsModel!.title!,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: secondaryColor),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis))
          ]),
        ),
      ]),
      onTap: () {
        if (type == "videos") {
          List<NewsModel> newsList = [];
          List<BreakingNewsModel> brNewsList = [];
          if (newsModel != null && allNewsList != null && allNewsList.isNotEmpty) {
            newsList = List.from(allNewsList);
            newsList.removeAt(index);
          } else if (breakingNewsModel != null && breakingNewsList != null && breakingNewsList.isNotEmpty) {
            brNewsList = List.from(breakingNewsList);
            brNewsList.removeAt(index);
          }
          // List<NewsModel> newsList = List.from(allNewsList ?? [])..removeAt(index);
          // List<BreakingNewsModel> breakNewsList = List.from(breakingNewsList ?? [])..removeAt(index);
          Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {
            "from": (newsModel != null) ? 1 : 3,
            if (newsModel != null) "model": newsModel,
            if (breakingNewsModel != null) "breakModel": breakingNewsModel,
            "otherBreakingVideos": brNewsList,
            "otherVideos": newsList,
          });
        } else if (type == 'news' || type == "user_choice") {
          //interstitial ads
          UiUtils.showInterstitialAds(context: context);
          if (allNewsList != null && allNewsList.isNotEmpty) {
            List<NewsModel> newsList = List.from(allNewsList);
            newsList.removeAt(index);
            Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": newsModel, "newsList": newsList, "isFromBreak": false, "fromShowMore": false});
          }
        } else {
          if (breakingNewsList != null && breakingNewsList.isNotEmpty) {
            //interstitial ads
            UiUtils.showInterstitialAds(context: context);
            List<BreakingNewsModel> breakList = List.from(breakingNewsList);
            breakList.removeAt(index);
            Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"breakModel": breakingNewsModel, "breakNewsList": breakList, "isFromBreak": true, "fromShowMore": false});
          }
        }
      },
    );
  }
}
