import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/updateLikeAndDislikeCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsRepository.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/strings.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Bookmark/UpdateBookmarkCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Bookmark/bookmarkRepository.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:html/parser.dart';

class VideoItem extends StatefulWidget {
  final NewsModel model;

  VideoItem({super.key, required this.model});

  @override
  VideoItemState createState() => VideoItemState();
}

class VideoItemState extends State<VideoItem> {
  String formattedDescription = "";

  @override
  void initState() {
    super.initState();
  }

  void dispose() async {
    super.dispose();
  }

  void checkAndSetDescription({required String descr}) {
    formattedDescription = "";

    // Parse HTML and extract plain text
    formattedDescription = parse(descr).body?.text ?? '';
  }

  Widget videoData(NewsModel video) {
    checkAndSetDescription(descr: video.desc ?? '');
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          ClipRRect(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, darkSecondaryColor]).createShader(bounds);
                    },
                    blendMode: BlendMode.darken,
                    child: CustomNetworkImage(
                        networkImageUrl: (video.contentType == 'video_youtube' && video.contentValue!.isNotEmpty)
                            ? 'https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(video.contentValue!)!}/0.jpg'
                            : video.image!,
                        fit: BoxFit.cover,
                        width: double.maxFinite,
                        height: (Platform.isIOS) ? MediaQuery.of(context).size.height / 1.29 : MediaQuery.of(context).size.height / 1.25,
                        isVideo: true)),
                CircleAvatar(radius: 30, backgroundColor: Colors.black45, child: Icon(Icons.play_arrow, size: 40, color: Colors.white)),
                Positioned.directional(
                    textDirection: Directionality.of(context),
                    bottom: 25.0,
                    start: 0,
                    height: MediaQuery.of(context).size.height / 8.4,
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: CustomTextLabel(
                                  text: video.title!,
                                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: secondaryColor, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis)),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CustomTextLabel(
                                text: formattedDescription.trim(), textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: secondaryColor), maxLines: 3, overflow: TextOverflow.ellipsis),
                          )
                        ],
                      ),
                    )),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  bottom: 10.0,
                  end: 10.0,
                  height: MediaQuery.of(context).size.height / 6,
                  width: MediaQuery.of(context).size.width / 8,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Column(
                      children: [
                        if (video.sourceType == NEWS) //user can like or bookmark videos of source type news, and not Breaking News
                          Column(children: [
                            likeButton(),
                            const SizedBox(height: 15),
                            BlocProvider(
                              create: (context) => UpdateBookmarkStatusCubit(BookmarkRepository()),
                              child: BlocBuilder<BookmarkCubit, BookmarkState>(
                                  bloc: context.read<BookmarkCubit>(),
                                  builder: (context, bookmarkState) {
                                    bool isBookmark = context.read<BookmarkCubit>().isNewsBookmark(video.id!);
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
                                                  context.read<UpdateBookmarkStatusCubit>().setBookmarkNews(news: video, status: (isBookmark) ? "0" : "1");
                                                } else {
                                                  UiUtils.loginRequired(context);
                                                }
                                              },
                                              child: state is UpdateBookmarkStatusInProgress
                                                  ? SizedBox(height: 15, width: 15, child: UiUtils.showCircularProgress(true, Theme.of(context).primaryColor))
                                                  : Icon(isBookmark ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined, color: secondaryColor));
                                        });
                                  }),
                            ),
                            const SizedBox(height: 15),
                          ]),
                        InkWell(
                            onTap: () async {
                              (await InternetConnectivity.isNetworkAvailable())
                                  ? UiUtils.shareNews(context: context, slug: video.slug ?? "", title: video.title!, isVideo: true, videoId: video.id!, isBreakingNews: false, isNews: false)
                                  : showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
                            },
                            splashColor: Colors.transparent,
                            child: const Icon(Icons.share_rounded, color: secondaryColor))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.model.contentValue!.isNotEmpty) ? videoData(widget.model) : const SizedBox.shrink();
  }

  Widget likeButton() {
    bool isLike = context.read<LikeAndDisLikeCubit>().isNewsLikeAndDisLike(widget.model.newsId!);

    return BlocProvider(
        create: (context) => UpdateLikeAndDisLikeStatusCubit(LikeAndDisLikeRepository()),
        child: BlocConsumer<LikeAndDisLikeCubit, LikeAndDisLikeState>(
            bloc: context.read<LikeAndDisLikeCubit>(),
            listener: ((context, state) {
              if (state is LikeAndDisLikeFetchSuccess) {
                isLike = context.read<LikeAndDisLikeCubit>().isNewsLikeAndDisLike(widget.model.newsId!);
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
                            context.read<UpdateLikeAndDisLikeStatusCubit>().setLikeAndDisLikeNews(
                                  news: widget.model,
                                  status: (isLike) ? "0" : "1",
                                );
                          } else {
                            UiUtils.loginRequired(context);
                          }
                        },
                        child: Container(
                            child: (state is UpdateLikeAndDisLikeStatusInProgress)
                                ? SizedBox(height: 15, width: 15, child: UiUtils.showCircularProgress(true, Theme.of(context).primaryColor))
                                : ((isLike) ? const Icon(Icons.thumb_up_alt, size: 25, color: secondaryColor) : const Icon(Icons.thumb_up_off_alt, size: 25, color: secondaryColor))));
                  });
            }));
  }
}
