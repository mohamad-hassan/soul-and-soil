import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:news/cubits/themeCubit.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/screens/auth/Widgets/svgPictureWidget.dart';
import 'package:news/ui/styles/appTheme.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextBtn.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/deleteUserNewsCubit.dart';
import 'package:news/cubits/getUserNewsCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/app/routes.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';

class ManageUserNews extends StatefulWidget {
  const ManageUserNews({super.key});

  @override
  ManageUserNewsState createState() => ManageUserNewsState();
}

class ManageUserNewsState extends State<ManageUserNews> {
  final bool _isButtonExtended = true;
  late final ScrollController controller = ScrollController()..addListener(hasMoreNewsScrollListener);
  Set<String> get locationValue => SettingsLocalDataRepository().getLocationCityValues();

  final labelKeys = {"standard_post": 'stdPostLbl', "video_youtube": 'videoYoutubeLbl', "video_other": 'videoOtherUrlLbl', "video_upload": 'videoUploadLbl'};

  @override
  void initState() {
    getNews();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getNews() {
    context.read<GetUserNewsCubit>().getGetUserNews(latitude: locationValue.first, longitude: locationValue.last);
  }

  void getMoreNews() {
    context.read<GetUserNewsCubit>().getMoreGetUserNews(latitude: locationValue.first, longitude: locationValue.last);
  }

  void hasMoreNewsScrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<GetUserNewsCubit>().hasMoreGetUserNews()) {
        getMoreNews();
      } else {
        debugPrint("No more News for this user");
      }
    }
  }

  getAppBar() {
    return PreferredSize(
        preferredSize: const Size(double.infinity, 45),
        child: UiUtils.applyBoxShadow(
          context: context,
          child: AppBar(
              centerTitle: false,
              backgroundColor: Colors.transparent,
              title: Transform(
                  transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
                  child: CustomTextLabel(
                      text: 'manageNewsLbl',
                      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Icon(Icons.arrow_back, color: UiUtils.getColorScheme(context).primaryContainer)),
              )),
        ));
  }

  newsAddBtn() {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      FloatingActionButton(
          isExtended: _isButtonExtended,
          backgroundColor: UiUtils.getColorScheme(context).surface,
          child: Icon(Icons.add, size: 32, color: UiUtils.getColorScheme(context).primaryContainer),
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.addNews, arguments: {"isEdit": false, "from": "myNews"});
          }),
      const SizedBox(height: 10)
    ]);
  }

  _buildNewsContainer({required NewsModel model, required int index, required int totalCurrentNews, required bool hasMoreNewsFetchError, required bool hasMore}) {
    if (index == totalCurrentNews - 1 && index != 0) {
      if (hasMore) {
        if (hasMoreNewsFetchError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: IconButton(onPressed: () => getMoreNews(), icon: Icon(Icons.error, color: Theme.of(context).primaryColor)),
          ));
        } else {
          return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0), child: UiUtils.showCircularProgress(true, Theme.of(context).primaryColor)));
        }
      }
    }

    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": model, "isFromBreak": false, "fromShowMore": false});
        },
        child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: UiUtils.getColorScheme(context).surface),
            padding: const EdgeInsetsDirectional.all(15),
            margin: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.24,
              height: MediaQuery.of(context).size.height * 0.26,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    newsImage(imageURL: model.image!),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [categoryName(categoryName: (model.categoryName != null && model.categoryName!.trim().isNotEmpty) ? model.categoryName! : ""), setDate(dateValue: model.date!)]),
                    ),
                    Spacer(),
                    deleteAndEditButton(isEdit: true, onTap: () => Navigator.of(context).pushNamed(Routes.addNews, arguments: {"model": model, "isEdit": true, "from": "myNews"})),
                    deleteAndEditButton(isEdit: false, onTap: () => deleteNewsDialogue(model.id!, index))
                  ],
                ),
                Divider(thickness: 2),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextLabel(
                      text: model.title!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w700)),
                  contentTypeView(model: model),
                ])),
                Divider(thickness: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (model.isExpired == 1)
                        ? Container(
                            child: Row(
                            children: [
                              SvgPictureWidget(
                                  assetName: 'expiredNews',
                                  assetColor:
                                      (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark ? ColorFilter.mode(darkIconColor, BlendMode.srcIn) : ColorFilter.mode(iconColor, BlendMode.srcIn))),
                              SizedBox(width: 2.5),
                              Text(
                                UiUtils.getTranslatedLabel(context, 'expiredKey'),
                                style: TextStyle(color: (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark ? darkIconColor : iconColor), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ))
                        : SizedBox.shrink(),
                    (model.status == "0")
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                            child: Row(
                              children: [
                                SvgPictureWidget(
                                    assetName: 'deactivatedNews',
                                    assetColor:
                                        (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark ? ColorFilter.mode(darkIconColor, BlendMode.srcIn) : ColorFilter.mode(iconColor, BlendMode.srcIn))),
                                SizedBox(width: 2.5),
                                Text(
                                  UiUtils.getTranslatedLabel(context, 'deactivatedKey'),
                                  style: TextStyle(color: (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark ? darkIconColor : iconColor), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ))
                        : SizedBox.shrink(),
                  ],
                ),
              ]),
            )));
  }

  Widget newsImage({required String imageURL}) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(45),
        child: CustomNetworkImage(networkImageUrl: imageURL, fit: BoxFit.cover, height: MediaQuery.of(context).size.width * 0.18, isVideo: false, width: MediaQuery.of(context).size.width * 0.18));
  }

  Widget categoryName({required String categoryName}) {
    return (categoryName.trim().isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CustomTextLabel(
                text: categoryName,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w600)),
          )
        : const SizedBox.shrink();
  }

  Widget contentTypeView({required NewsModel model}) {
    String contType = "";

    final key = labelKeys[model.contentType];
    if (key != null) {
      contType = UiUtils.getTranslatedLabel(context, key);
    }
    return (model.contentType != "")
        ? Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextLabel(
                  text: 'contentTypeLbl',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withAlpha((0.3 * 255).round()))),
              CustomTextLabel(text: " : ", textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withAlpha((0.3 * 255).round()))),
              CustomTextLabel(
                  text: contType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withAlpha((0.3 * 255).round())))
            ]),
          )
        : SizedBox.shrink();
  }

  Widget deleteAndEditButton({required bool isEdit, required void Function()? onTap}) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.only(top: 3, bottom: 3, start: 5),
          alignment: Alignment.center,
          child: SvgPictureWidget(
              assetName: (isEdit) ? 'editMyNews' : 'deleteMyNews',
              height: 30,
              width: 30,
              fit: BoxFit.contain,
              assetColor: (isEdit) ? ColorFilter.mode(UiUtils.getColorScheme(context).onPrimary, BlendMode.srcIn) : null),
        ));
  }

  Widget setDate({required String dateValue}) {
    DateTime time = DateTime.parse(dateValue);
    var newFormat = DateFormat("dd-MMM-yyyy", Hive.box(settingsBoxKey).get(currentLanguageCodeKey));
    final newNewsDate = newFormat.format(time);

    return CustomTextLabel(
        text: newNewsDate,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8)));
  }

  deleteNewsDialogue(String id, int index) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              backgroundColor: UiUtils.getColorScheme(context).surface,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: CustomTextLabel(text: 'doYouReallyNewsLbl', textStyle: Theme.of(this.context).textTheme.titleMedium),
              title: const CustomTextLabel(text: 'delNewsLbl'),
              titleTextStyle: Theme.of(this.context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              actions: <Widget>[
                CustomTextButton(
                    textWidget: CustomTextLabel(
                        text: 'noLbl', textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.of(context).pop(false);
                    }),
                BlocConsumer<DeleteUserNewsCubit, DeleteUserNewsState>(
                    bloc: context.read<DeleteUserNewsCubit>(),
                    listener: (context, state) {
                      if (state is DeleteUserNewsSuccess) {
                        context.read<GetUserNewsCubit>().deleteNews(index);
                        showSnackBar(state.message, context);
                        Navigator.pop(context);
                      }
                    },
                    builder: (context, state) {
                      return CustomTextButton(
                          textWidget: CustomTextLabel(
                              text: 'yesLbl', textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold)),
                          onTap: () async {
                            context.read<DeleteUserNewsCubit>().setDeleteUserNews(newsId: id);
                          });
                    })
              ],
            );
          });
        });
  }

  contentShimmer(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.grey,
        child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
            itemBuilder: (_, i) =>
                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey.withOpacity(0.6)), margin: const EdgeInsets.only(top: 20), height: 190.0),
            itemCount: 6));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(),
        floatingActionButton: newsAddBtn(),
        body: BlocBuilder<GetUserNewsCubit, GetUserNewsState>(
          builder: (context, state) {
            if (state is GetUserNewsFetchSuccess) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 10, end: 10, bottom: 10),
                child: RefreshIndicator(
                  onRefresh: () async {
                    getNews();
                  },
                  child: ListView.builder(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.getUserNews.length,
                      itemBuilder: (context, index) {
                        return _buildNewsContainer(
                            model: state.getUserNews[index], hasMore: state.hasMore, hasMoreNewsFetchError: state.hasMoreFetchError, index: index, totalCurrentNews: state.getUserNews.length);
                      }),
                ),
              );
            }
            if (state is GetUserNewsFetchFailure) {
              return ErrorContainerWidget(
                  errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : state.errorMessage, onRetry: getNews);
            }
            return contentShimmer(context);
          },
        ));
  }
}
