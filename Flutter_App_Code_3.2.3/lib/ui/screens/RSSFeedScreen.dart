import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/categoryCubit.dart';
import 'package:news/cubits/rssFeedCubit.dart';
import 'package:news/data/models/CategoryModel.dart';
import 'package:news/data/models/RSSFeedModel.dart';
import 'package:news/ui/screens/AddEditNews/Widgets/customBottomsheet.dart';
import 'package:news/ui/screens/auth/Widgets/svgPictureWidget.dart';
import 'package:news/ui/styles/colors.dart';

import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/uiUtils.dart';

class RSSFeedScreen extends StatefulWidget {
  @override
  RSSFeedScreenState createState() => RSSFeedScreenState();
}

class RSSFeedScreenState extends State<RSSFeedScreen> {
  final Set<String> selectedTopics = {};
  final Random random = Random();
  late final ScrollController _controller = ScrollController()..addListener(hasMoreRssFeedScrollListener);
  String? catSel = "", subCatSel = "", subCatSelId, catSelId;
  int? catIndex, subCatIndex;
  bool isFilter = true, showSubcat = false;

  @override
  void initState() {
    super.initState();
    getRSSFeed();
  }

  setAppBar() {
    return PreferredSize(
        preferredSize: const Size(double.infinity, 52),
        child: UiUtils.applyBoxShadow(
            context: context,
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: MediaQuery.of(context).padding.top + 10.0, start: 25, end: 25, bottom: 15),
              child: Row(children: [
                CustomTextLabel(
                  text: 'rssFeed',
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                Spacer(),
                GestureDetector(child: Icon(Icons.filter_list_rounded), onTap: () => setCategorySubcategoryFilter(context))
              ]),
            )));
  }

  setCategorySubcategoryFilter(BuildContext context) {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 5.0,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.35,
                padding: const EdgeInsets.only(top: 10.0, bottom: 5, left: 10, right: 10),
                child: Column(children: [
                  titleWithDropdownButton(),
                  const SizedBox(height: 5),
                  (isFilter) ? setCategoryFilter(setBottomSheetState) : SizedBox.shrink(),
                  (isFilter) ? setSubCategoryFilter(setBottomSheetState) : SizedBox.shrink(),
                ]));
          });
        });
  }

  void getRSSFeed() async {
    if (await InternetConnectivity.isNetworkAvailable()) {
      Future.delayed(Duration.zero, () {
        context.read<RSSFeedCubit>().getRSSFeed(langId: context.read<AppLocalizationCubit>().state.id, categoryId: catSelId, subCategoryId: subCatSelId);
      });
    }
  }

  void hasMoreRssFeedScrollListener() {
    if (_controller.position.maxScrollExtent == _controller.offset) {
      if (context.read<RSSFeedCubit>().hasMoreRSSFeed()) {
        context.read<RSSFeedCubit>().getMoreRSSFeed(langId: context.read<AppLocalizationCubit>().state.id);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget titleWithDropdownButton() {
    return InkWell(
        onTap: () {
          isFilter = !isFilter;
          setState(() {});
        },
        child: Container(
          width: double.maxFinite,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Row(
            children: [
              CustomTextLabel(text: 'FilterBy', textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: UiUtils.getColorScheme(context).primaryContainer)),
              Spacer(),
              if (catSelId != null || subCatSelId != null) (isFilter) ? clearFilterButton() : SizedBox.shrink(),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocBuilder<RSSFeedCubit, RSSFeedState>(
          builder: (context, state) {
            if (state is RSSFeedFetchSuccess) {
              return RefreshIndicator(
                onRefresh: () async {
                  getRSSFeed();
                },
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 15),
                    itemCount: state.RSSFeed.length,
                    controller: _controller,
                    itemBuilder: (context, index) {
                      return Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: buildRSSFeedItem(state.RSSFeed[index], index, state.RSSFeed.length, state.hasMoreFetchError, state.hasMore));
                    }),
              );
            }
            if (state is RSSFeedFetchFailure) {
              return ErrorContainerWidget(
                  errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : state.errorMessage,
                  onRetry: getRSSFeed); //Add category & subcategory id if selected
            }
            if (state is RSSFeedFetchInProgress || state is RSSFeedInitial) {
              return Center(child: UiUtils.showCircularProgress(true, Theme.of(context).primaryColor));
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget buildRSSFeedItem(RSSFeedModel feed, int index, int totalCurrentFeeds, bool hasMoreFeedsFetchError, bool hasMore) {
    if (index == totalCurrentFeeds - 1 && index != 0) {
      if (hasMore) {
        if (hasMoreFeedsFetchError) {
          return const SizedBox.shrink();
        } else {
          return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0), child: UiUtils.showCircularProgress(true, Theme.of(context).primaryColor)));
        }
      }
    }
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pushNamed(Routes.rssFeedDetails, arguments: {"feedUrl": feed.feedUrl});
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), border: Border.all(color: borderColor.withAlpha((0.3 * 255).round()))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: SvgPictureWidget(assetName: 'rss_feed', height: 20, width: 10, fit: BoxFit.fill)),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(feed.feedName!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.start),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget setCategoryFilter(void Function(void Function()) setStater) {
    return BlocConsumer<CategoryCubit, CategoryState>(listener: (context, state) {
      if (catSel != "") catIndex = context.read<CategoryCubit>().getCategoryIndex(categoryName: catSel!);
    }, builder: (context, state) {
      if (state is CategoryFetchSuccess) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return CustomBottomsheet(
                      context: context,
                      titleTxt: 'selCatLbl',
                      language_id: context.read<AppLocalizationCubit>().state.id,
                      listLength: context.read<CategoryCubit>().getCatList().length,
                      listViewChild: (context, index) {
                        return catListItem(index, context.read<CategoryCubit>().getCatList(), setStater);
                      });
                }),
            child: UiUtils.setRowWithContainer(
                context: context,
                firstChild: CustomTextLabel(
                    text: (catSel == "" || catSel == null) ? 'catLbl' : catSel!,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: catSel == "" ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer)),
                isContentTypeUpload: false),
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  Widget catListItem(int index, List<CategoryModel> catList, void Function(void Function()) setStater) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            subCatSel = "";
            subCatSelId = null;
            catSel = catList[index].categoryName!;
            catIndex = index;
            catSelId = catList[index].id!;
            showSubcat = true;
          });
          setStater(() {});
          getRSSFeed();
          Navigator.pop(context);
        },
        child: UiUtils.setBottomsheetContainer(entryId: catSelId ?? "0", listItem: catList[index].categoryName!, compareTo: catList[index].id!, context: context),
      ),
    );
  }

  Widget subCatListItem(int index, List<CategoryModel> catList, void Function(void Function()) setStater) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: InkWell(
          onTap: () {
            setState(() {
              subCatSel = catList[catIndex!].subData![index].subCatName!;
              subCatSelId = catList[catIndex!].subData![index].id!;
            });
            setStater(() {});
            getRSSFeed();
            Navigator.pop(context);
          },
          child: UiUtils.setBottomsheetContainer(
              entryId: subCatSelId ?? "0", listItem: catList[catIndex!].subData![index].subCatName!, compareTo: catList[catIndex!].subData![index].id!, context: context)),
    );
  }

  Widget setSubCategoryFilter(void Function(void Function()) setStater) {
    if ((catSel != "" && catSel != null) &&
        (catIndex != null) &&
        (!catIndex!.isNegative && context.read<CategoryCubit>().getCatList().isNotEmpty) &&
        (context.read<CategoryCubit>().getCatList()[catIndex!].subData!.isNotEmpty)) {
      return BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: InkWell(
              onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return CustomBottomsheet(
                        context: context,
                        titleTxt: 'selSubCatLbl',
                        language_id: context.read<AppLocalizationCubit>().state.id,
                        listLength: context.read<CategoryCubit>().getCatList()[catIndex!].subData!.length,
                        listViewChild: (context, index) => subCatListItem(index, context.read<CategoryCubit>().getCatList(), setStater));
                  }),
              child: UiUtils.setRowWithContainer(
                  context: context,
                  firstChild: CustomTextLabel(
                      text: (subCatSel == "" || subCatSel == null) ? 'subcatLbl' : subCatSel!,
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: subCatSel == "" ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer)),
                  isContentTypeUpload: false),
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget clearFilterButton() {
    return Center(
        child: TextButton(
            onPressed: () {
              setState(() {
                catSelId = null;
                catSel = null;
                subCatSelId = null;
                subCatSel = null;
                showSubcat = false;
              });
              getRSSFeed(); //call API without Ids
              Navigator.of(context).pop();
            },
            child: CustomTextLabel(
              text: 'clearFilter',
              textStyle: TextStyle(decoration: TextDecoration.underline, decorationThickness: 2),
            )));
  }
}
