import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/screens/HomePage/Widgets/CommonSectionTitle.dart';

class Style3Section extends StatelessWidget {
  final FeatureSectionModel model;

  const Style3Section({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return style3Data(model, context);
  }

  Widget style3Data(FeatureSectionModel model, BuildContext context) {
    int limit = limitOfAllOtherStyle;
    int newsLength = (model.newsType == 'news' || model.newsType == "user_choice") ? model.news!.length : model.videos!.length;
    int brNewsLength = model.newsType == 'breaking_news' ? model.breakNews!.length : model.breakVideos!.length;

    if (model.breakVideos!.isNotEmpty || model.breakNews!.isNotEmpty || model.videos!.isNotEmpty || model.news!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonSectionTitle(model, context),
          if ((model.newsType == 'breaking_news' || model.videosType == "breaking_news") && (model.newsType == 'breaking_news' ? model.breakNews!.isNotEmpty : model.breakVideos!.isNotEmpty))
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.34,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: min(brNewsLength, limit),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      BreakingNewsModel data = model.newsType == 'breaking_news' ? model.breakNews![index] : model.breakVideos![index];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((index != 0 && index % nativeAdsIndex == 0) &&
                              context.read<AppConfigurationCubit>().getInAppAdsMode() == "1" &&
                              (context.read<AppConfigurationCubit>().getAdsType() != "unity" || context.read<AppConfigurationCubit>().getIOSAdsType() != "unity"))
                            SizedBox(width: MediaQuery.of(context).size.width * 0.87, child: nativeAdsShow(context: context, index: index)),
                          InkWell(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.87,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.directional(
                                      textDirection: Directionality.of(context),
                                      start: 0,
                                      end: 0,
                                      top: MediaQuery.of(context).size.height / 15,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: MediaQuery.of(context).size.height / 4,
                                        margin: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 10, end: 10, top: 10, bottom: 10),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: UiUtils.getColorScheme(context).surface),
                                        padding: const EdgeInsets.all(14),
                                        child: Padding(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 9),
                                            child: CustomTextLabel(
                                                text: data.title!,
                                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.normal),
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis)),
                                      )),
                                  Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    start: 30,
                                    end: 30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CustomNetworkImage(
                                          networkImageUrl: data.image!,
                                          height: MediaQuery.of(context).size.height / 4.7,
                                          width: double.maxFinite,
                                          fit: BoxFit.cover,
                                          isVideo: model.newsType == 'videos' ? true : false),
                                    ),
                                  ),
                                  if (model.newsType == 'videos')
                                    Positioned.directional(
                                      textDirection: Directionality.of(context),
                                      top: MediaQuery.of(context).size.height * 0.085,
                                      start: MediaQuery.of(context).size.width / 3,
                                      end: MediaQuery.of(context).size.width / 3,
                                      child: InkWell(
                                          onTap: () {
                                            List<BreakingNewsModel> brNewsList = List.from(model.breakVideos ?? [])..removeAt(index);
                                            Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"from": 3, "breakModel": data, "otherBreakingVideos": brNewsList});
                                          },
                                          child: UiUtils.setPlayButton(context: context)),
                                    ),
                                ],
                              ),
                            ),
                            onTap: () {
                              if (model.newsType == 'breaking_news') {
                                //interstitial ads
                                UiUtils.showInterstitialAds(context: context);
                                List<BreakingNewsModel> breakList = [];
                                breakList.addAll(model.breakNews!);
                                breakList.removeAt(index);
                                Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"breakModel": data, "breakNewsList": breakList, "isFromBreak": true, "fromShowMore": false});
                              }
                            },
                          ),
                        ],
                      );
                    })),
          if ((model.newsType == 'news' || model.videosType == "news" || model.newsType == "user_choice") &&
              ((model.newsType == 'news' || model.newsType == "user_choice") ? model.news!.isNotEmpty : model.videos!.isNotEmpty))
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.34,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: min(newsLength, limit),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      NewsModel data = (model.newsType == 'news' || model.newsType == "user_choice") ? model.news![index] : model.videos![index];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((index != 0 && index % nativeAdsIndex == 0) &&
                              context.read<AppConfigurationCubit>().getInAppAdsMode() == "1" &&
                              (context.read<AppConfigurationCubit>().getAdsType() != "unity" || context.read<AppConfigurationCubit>().getIOSAdsType() != "unity"))
                            SizedBox(width: MediaQuery.of(context).size.width * 0.87, child: nativeAdsShow(context: context, index: index)),
                          InkWell(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.87,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.directional(
                                      textDirection: Directionality.of(context),
                                      start: 0,
                                      end: 0,
                                      top: MediaQuery.of(context).size.height / 15,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: MediaQuery.of(context).size.height / 3.8,
                                        margin: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 10, end: 10, top: 10, bottom: 10),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: UiUtils.getColorScheme(context).surface),
                                        padding: const EdgeInsets.all(14),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (data.categoryName != null)
                                                Container(
                                                    height: 20.0,
                                                    padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0, top: 2.5),
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Theme.of(context).primaryColor),
                                                    child: CustomTextLabel(
                                                        text: data.categoryName!,
                                                        textAlign: TextAlign.center,
                                                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryColor),
                                                        overflow: TextOverflow.ellipsis,
                                                        softWrap: true)),
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 10.0),
                                                  child: CustomTextLabel(
                                                      text: data.title!,
                                                      textStyle:
                                                          Theme.of(context).textTheme.titleMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.normal),
                                                      softWrap: true,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                        ),
                                      )),
                                  Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    start: 30,
                                    end: 30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CustomNetworkImage(
                                          networkImageUrl: data.image!,
                                          height: MediaQuery.of(context).size.height / 4.7,
                                          width: MediaQuery.of(context).size.width,
                                          fit: BoxFit.cover,
                                          isVideo: model.newsType == 'videos' ? true : false),
                                    ),
                                  ),
                                  if (model.newsType == 'videos')
                                    Positioned.directional(
                                      textDirection: Directionality.of(context),
                                      top: MediaQuery.of(context).size.height * 0.085,
                                      start: MediaQuery.of(context).size.width / 3,
                                      end: MediaQuery.of(context).size.width / 3,
                                      child: InkWell(
                                          onTap: () {
                                            List<NewsModel> allNewsList = List.from(model.videos ?? [])..removeAt(index);
                                            Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"from": 1, "model": data, "otherVideos": allNewsList});
                                          },
                                          child: UiUtils.setPlayButton(context: context)),
                                    ),
                                ],
                              ),
                            ),
                            onTap: () {
                              if (model.newsType == 'news' || model.newsType == "user_choice") {
                                //interstitial ads
                                UiUtils.showInterstitialAds(context: context);
                                List<NewsModel> newsList = [];
                                newsList.addAll(model.news!);
                                newsList.removeAt(index);
                                Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": data, "newsList": newsList, "isFromBreak": false, "fromShowMore": false});
                              }
                            },
                          ),
                        ],
                      );
                    })),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
