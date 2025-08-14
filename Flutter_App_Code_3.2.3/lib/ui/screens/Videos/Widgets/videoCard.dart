import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Bookmark/UpdateBookmarkCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/updateLikeAndDislikeCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/LiveStreamingModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Bookmark/bookmarkRepository.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsRepository.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/videoPlayContainer.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/strings.dart';
import 'package:news/utils/uiUtils.dart';

class VideoCard extends StatefulWidget {
  final NewsModel? model;
  final BreakingNewsModel? brModel;
  final LiveStreamingModel? liveModel;
  VideoCard({super.key, this.model, this.liveModel, this.brModel});

  @override
  State<StatefulWidget> createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  late NewsModel? model;
  late BreakingNewsModel? brModel;
  late LiveStreamingModel? liveModel;
  bool isLiveVideo = false, isBreakingVideo = false;
  List<String>? tagList = [];
  List<String>? tagId = [];
  String formattedDate = "", contentType = "", contentValue = "", titleTxt = "";

  @override
  void initState() {
    super.initState();
    model = widget.model;
    brModel = widget.brModel;
    liveModel = widget.liveModel;
    isLiveVideo = (liveModel != null);
    isBreakingVideo = (brModel != null);
    setFormattedDate();
    setTitle();
    setContentValueAndContentType();
    setTags();
  }

  void setTitle() {
    titleTxt = (isLiveVideo)
        ? liveModel?.title ?? ""
        : (isBreakingVideo)
            ? brModel?.title ?? ""
            : model?.title ?? "";
  }

  void setTags() {
    if (model != null && model?.tagName != null && (model!.sourceType != null && model!.sourceType != BREAKING_NEWS)) {
      if (model!.tagName!.isNotEmpty) {
        final tagName = model?.tagName!;
        tagList = tagName?.split(',');
      }

      if (model?.tagId != null && model!.tagId!.isNotEmpty) {
        tagId = model?.tagId?.split(",");
      }
    }
  }

  void setFormattedDate() {
    String dateVal = (isLiveVideo) ? liveModel!.updatedDate ?? "" : (model?.publishDate ?? model?.date ?? "");
    if (dateVal.isNotEmpty) {
      DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(dateVal);
      formattedDate = DateFormat("MMM dd, yyyy").format(parsedDate);
    }
  }

  void setContentValueAndContentType() {
    contentType = (isLiveVideo) ? liveModel?.type ?? "" : ((model != null) ? model?.contentType ?? "" : brModel!.contentType ?? "");
    contentValue = (isLiveVideo)
        ? liveModel?.url ?? ""
        : (model != null)
            ? model?.contentValue ?? ""
            : brModel!.contentValue ?? "";
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  Widget likeButton() {
    bool isLike = context.read<LikeAndDisLikeCubit>().isNewsLikeAndDisLike(widget.model?.newsId ?? "0");

    return BlocProvider(
        create: (context) => UpdateLikeAndDisLikeStatusCubit(LikeAndDisLikeRepository()),
        child: BlocConsumer<LikeAndDisLikeCubit, LikeAndDisLikeState>(
            bloc: context.read<LikeAndDisLikeCubit>(),
            listener: ((context, state) {
              if (state is LikeAndDisLikeFetchSuccess) {
                isLike = context.read<LikeAndDisLikeCubit>().isNewsLikeAndDisLike(model?.newsId ?? "0");
              } else {
                isLike = false; //in case of failue - no other likes found
              }
            }),
            builder: (context, likeAndDislikeState) {
              return BlocConsumer<UpdateLikeAndDisLikeStatusCubit, UpdateLikeAndDisLikeStatusState>(
                  bloc: context.read<UpdateLikeAndDisLikeStatusCubit>(),
                  listener: ((context, state) {
                    if (state is UpdateLikeAndDisLikeStatusSuccess) {
                      context.read<LikeAndDisLikeCubit>().getLike(langId: context.read<AppLocalizationCubit>().state.id);
                    }
                  }),
                  builder: (context, state) {
                    return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (context.read<AuthCubit>().getUserId() != "0") {
                            if (state is UpdateLikeAndDisLikeStatusInProgress) {
                              return;
                            }
                            context.read<UpdateLikeAndDisLikeStatusCubit>().setLikeAndDisLikeNews(news: model ?? NewsModel(), status: (isLike) ? "0" : "1");
                          } else {
                            UiUtils.loginRequired(context);
                          }
                        },
                        child: designButtons(
                            childWidget: (state is UpdateLikeAndDisLikeStatusInProgress)
                                ? SizedBox(height: 15, width: 15, child: UiUtils.showCircularProgress(true, Theme.of(context).primaryColor))
                                : ((isLike)
                                    ? Icon(Icons.thumb_up_alt, size: 25, color: UiUtils.getColorScheme(context).onPrimary)
                                    : Icon(Icons.thumb_up_off_alt, size: 25, color: UiUtils.getColorScheme(context).onPrimary))));
                  });
            }));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Container(
      decoration: BoxDecoration(color: UiUtils.getColorScheme(context).surface, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(aspectRatio: 16 / 9, child: VideoPlayContainer(contentType: contentType, contentValue: contentValue)),
          ),
          const SizedBox(height: 10),
          (model != null && model!.sourceType != BREAKING_NEWS)
              ? Wrap(
                  spacing: 8,
                  children: tagList!
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .map(
                        (tag) => InkWell(
                          onTap: () async {
                            Navigator.of(context).pushNamed(Routes.tagScreen, arguments: {"tagId": tagId, "tagName": tagList});
                          },
                          child: Container(
                              height: 25.0,
                              width: 65,
                              alignment: Alignment.center,
                              padding: const EdgeInsetsDirectional.only(start: 3.0, end: 3.0, top: 1.0, bottom: 1.0),
                              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), color: UiUtils.getColorScheme(context).secondary.withOpacity(0.85)),
                              child: CustomTextLabel(
                                  text: tag,
                                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true)),
                        ),
                      )
                      .toList(),
                )
              : SizedBox.shrink(),
          const SizedBox(height: 10),
          CustomTextLabel(text: titleTxt, textStyle: TextStyle(color: UiUtils.getColorScheme(context).onPrimary)),
          const SizedBox(height: 10),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (formattedDate.isNotEmpty)
                  ? Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 20),
                        SizedBox(width: 4),
                        CustomTextLabel(text: formattedDate, textStyle: TextStyle(fontSize: 12, color: UiUtils.getColorScheme(context).onPrimary)),
                      ],
                    )
                  : SizedBox.shrink(),
              Row(
                children: [
                  if ((model?.sourceType != null && model?.newsId != null || model?.id != null) || (model?.sourceType == NEWS || model?.sourceType == VIDEOS))
                    Row(children: [
                      likeButton(),
                      const SizedBox(height: 15),
                      BlocProvider(
                        create: (context) => UpdateBookmarkStatusCubit(BookmarkRepository()),
                        child: BlocBuilder<BookmarkCubit, BookmarkState>(
                            bloc: context.read<BookmarkCubit>(),
                            builder: (context, bookmarkState) {
                              bool isBookmark = context.read<BookmarkCubit>().isNewsBookmark(model?.id ?? "0");
                              return BlocConsumer<UpdateBookmarkStatusCubit, UpdateBookmarkStatusState>(
                                  bloc: context.read<UpdateBookmarkStatusCubit>(),
                                  listener: ((context, state) {
                                    if (state is UpdateBookmarkStatusSuccess) {
                                      (state.wasBookmarkNewsProcess) ? context.read<BookmarkCubit>().addBookmarkNews(state.news) : context.read<BookmarkCubit>().removeBookmarkNews(state.news);
                                      setState(() {});
                                    }
                                  }),
                                  builder: (context, state) {
                                    return InkWell(
                                        onTap: () {
                                          if (context.read<AuthCubit>().getUserId() != "0") {
                                            if (state is UpdateBookmarkStatusInProgress) return;
                                            context.read<UpdateBookmarkStatusCubit>().setBookmarkNews(news: model!, status: (isBookmark) ? "0" : "1");
                                          } else {
                                            UiUtils.loginRequired(context);
                                          }
                                        },
                                        child: state is UpdateBookmarkStatusInProgress
                                            ? SizedBox(height: 15, width: 15, child: UiUtils.showCircularProgress(true, Theme.of(context).primaryColor))
                                            : designButtons(
                                                childWidget: Icon(isBookmark ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined, color: UiUtils.getColorScheme(context).onPrimary)));
                                  });
                            }),
                      ),
                      const SizedBox(height: 15)
                    ]),
                  InkWell(
                      onTap: () async {
                        (await InternetConnectivity.isNetworkAvailable())
                            ? UiUtils.shareNews(context: context, slug: model?.slug ?? "", title: model?.title ?? "", isVideo: true, videoId: model?.id ?? "0", isBreakingNews: false, isNews: false)
                            : showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
                      },
                      splashColor: Colors.transparent,
                      child: designButtons(childWidget: Icon(Icons.share_rounded, color: UiUtils.getColorScheme(context).onPrimary)))
                ],
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget designButtons({required Widget childWidget}) {
    return Container(
        height: 30,
        width: 30,
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(7), color: borderColor.withOpacity(0.2)),
        child: childWidget);
  }
}
