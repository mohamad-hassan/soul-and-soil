import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/Bookmark/UpdateBookmarkCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/uiUtils.dart';

class NewsCard extends StatefulWidget {
  NewsModel newsDetail;
  bool showViews;
  bool showTags;
  Function()? onTap;
  NewsCard({super.key, required this.newsDetail, this.showViews = false, this.showTags = false, required this.onTap});

  @override
  State<NewsCard> createState() => NewsCardState();
}

class NewsCardState extends State<NewsCard> {
  List<String> tagList = [];
  List<String> tagId = [];
  late NewsModel newsData;

  @override
  void initState() {
    super.initState();

    newsData = widget.newsDetail;

    if (newsData.tagName! != "") {
      final tagName = newsData.tagName!;
      tagList = tagName.split(',');
    }

    if (newsData.tagId != null && newsData.tagId! != "") {
      tagId = newsData.tagId!.split(",");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: UiUtils.getColorScheme(context).surface, borderRadius: BorderRadius.circular(8)),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [setImage(), setContent()],
            ),
            (widget.showViews) ? setBookmarkIconButton() : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Widget setContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          //title
          CustomTextLabel(text: widget.newsDetail.title!, textStyle: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            spacing: 10,
            children: [(widget.newsDetail.date != null && widget.newsDetail.date!.isNotEmpty) ? setDate() : SizedBox.shrink(), (widget.showViews) ? setViews() : SizedBox.shrink()],
          ),
        ],
      ),
    );
  }

  Widget setBookmarkIconButton() {
    return BlocListener<UpdateBookmarkStatusCubit, UpdateBookmarkStatusState>(
      listener: (context, state) {
        if (state is UpdateBookmarkStatusSuccess) {
          context.read<BookmarkCubit>().getBookmark(langId: context.read<AppLocalizationCubit>().state.id);
        }
      },
      child: Positioned.directional(
          textDirection: Directionality.of(context),
          end: 10,
          top: 10,
          child: GestureDetector(
              onTap: () {
                context.read<UpdateBookmarkStatusCubit>().setBookmarkNews(news: widget.newsDetail, status: "0");
              },
              child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), color: UiUtils.getColorScheme(context).surface),
                  child: Icon(Icons.bookmark_outlined, color: UiUtils.getColorScheme(context).onPrimary, size: 20)))),
    );
  }

  Widget setViews() {
    return Row(spacing: 8, children: [
      Icon(Icons.remove_red_eye_rounded, size: 20),
      CustomTextLabel(text: "${widget.newsDetail.totalViews} ${UiUtils.getTranslatedLabel(context, 'viewsLbl')}", textStyle: TextStyle(fontSize: 12))
    ]);
  }

  Widget setDate() {
    return Row(
      spacing: 8,
      children: [Icon(Icons.calendar_month_rounded, size: 20), CustomTextLabel(text: UiUtils.formatDate(widget.newsDetail.date ?? ''), textStyle: TextStyle(fontSize: 12))],
    );
  }

  Widget setTags() {
    return Positioned.directional(
        textDirection: Directionality.of(context),
        bottom: 15.0,
        start: 7.0,
        child: widget.newsDetail.tagName! != ""
            ? SizedBox(
                height: 30.0,
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: tagList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 5.5),
                        child: InkWell(
                          child: Container(
                              height: 25.0,
                              width: 65,
                              alignment: Alignment.center,
                              padding: const EdgeInsetsDirectional.only(start: 3.0, end: 3.0, top: 1.0, bottom: 1.0),
                              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), color: UiUtils.getColorScheme(context).secondary.withOpacity(0.85)),
                              child: CustomTextLabel(
                                  text: tagList[index],
                                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true)),
                          onTap: () async {
                            Navigator.of(context).pushNamed(Routes.tagScreen, arguments: {"tagId": tagId[index], "tagName": tagList[index]});
                          },
                        ),
                      );
                    }))
            : const SizedBox.shrink());
  }

  Widget setImage() {
    return Stack(
      children: [
        Container(
            height: 192,
            color: borderColor,
            child: ShaderMask(
                shaderCallback: (rect) =>
                    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [darkSecondaryColor.withOpacity(0.6), darkSecondaryColor.withOpacity(0.6)]).createShader(rect),
                blendMode: BlendMode.darken,
                child: Container(
                  color: primaryColor.withAlpha(5),
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height / 3.3,
                  child: CustomNetworkImage(width: double.maxFinite, networkImageUrl: widget.newsDetail.image ?? ''),
                ))),
        //tags
        if (widget.showTags) setTags()
      ],
    );
  }
}
