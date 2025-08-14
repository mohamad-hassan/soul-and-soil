import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/cubits/categoryCubit.dart';
import 'package:news/cubits/tagCubit.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/models/CategoryModel.dart';
import 'package:news/data/models/TagModel.dart';
import 'package:news/ui/screens/auth/Widgets/svgPictureWidget.dart';
import 'package:news/ui/screens/filter/FilterBottomSheet.dart';
import 'package:news/ui/screens/filter/widgets/duration_filter_widget.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/customBackBtn.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'dart:async';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  SearchState createState() => SearchState();
}

bool buildResult = false; //used in 2 classes here _SearchState & _SuggestionList

class SearchState extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int pos = 0;
  List<NewsModel> searchList = [];
  final List<TextEditingController> _controllerList = [];
  bool isNetworkAvail = true;

  String query = "";
  int notificationoffset = 0;
  ScrollController? notificationcontroller;
  bool notificationisloadmore = true, notificationisgettingdata = false, notificationisnodata = false;

  // Filter related variables
  bool isFilterApplied = false;
  List<CategoryModel> filterSelectedCategories = [];
  List<TagModel> filterSelectedTags = [];
  DateTime? filterSelectedDate;
  DurationFilter? filterDurationFilter;

  Timer? _debounce;
  List<NewsModel> history = [];

  List<String> hisList = [];

  // Apply filters to search results
  void applyFilters() {
    notificationoffset = 0;

    getSearchNews(isFilter: true);
  }

  @override
  void initState() {
    super.initState();
    searchList.clear();

    // Load categories and tags if not already loaded
    context.read<CategoryCubit>().loadIfFailed(langId: context.read<AppLocalizationCubit>().state.id);
    context.read<TagCubit>().loadIfFailed(langId: context.read<AppLocalizationCubit>().state.id);

    notificationoffset = 0;

    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller!.addListener(_searchScrollListener);

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted) {
          setState(() {
            query = "";
          });
        }
      } else {
        query = _controller.text.trim();
        notificationoffset = 0;
        notificationisnodata = false;
        buildResult = false;
        if (query.isNotEmpty) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            notificationisloadmore = true;
            notificationoffset = 0;
            getSearchNews();
          });
        }
      }
    });
  }

  _searchScrollListener() {
    if (notificationcontroller!.offset >= notificationcontroller!.position.maxScrollExtent && !notificationcontroller!.position.outOfRange) {
      if (mounted) {
        setState(() {
          getSearchNews();
        });
      }
    }
  }

  Future<List<String>> getHistory() async {
    hisList = UiUtils.getDynamicListValue(historyListKey);
    return hisList;
  }

  @override
  void dispose() {
    notificationcontroller!.dispose();
    _controller.dispose();
    for (int i = 0; i < _controllerList.length; i++) {
      _controllerList[i].dispose();
    }

    super.dispose();
  }

  PreferredSizeWidget appbar() {
    return AppBar(
      leading: const CustomBackButton(horizontalPadding: 15),
      backgroundColor: Theme.of(context).canvasColor,
      title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
              hintText: UiUtils.getTranslatedLabel(context, 'search'),
              hintStyle: TextStyle(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer)),
              fillColor: secondaryColor)),
      titleSpacing: 0,
      actions: [
        IconButton(
            onPressed: () {
              _controller.text = '';
            },
            icon: Icon(Icons.close, color: UiUtils.getColorScheme(context).primaryContainer)),
        IconButton(
            padding: EdgeInsetsDirectional.only(end: 7),
            onPressed: () async {
              FocusManager.instance.rootScope.unfocus();
              final NewsFilterData? result = await showFilterBottomSheet(
                context: context,
                isCategoryModeON: (context.read<AppConfigurationCubit>().getCategoryMode() == "1"),
                initialFilters: NewsFilterData(
                  selectedCategories: filterSelectedCategories,
                  selectedTags: filterSelectedTags,
                  selectedDate: filterSelectedDate,
                  durationFilter: filterDurationFilter,
                ),
              );

              if (result != null) {
                setState(() {
                  buildResult = true;
                  isFilterApplied = true;
                  filterSelectedCategories = result.selectedCategories;
                  filterSelectedTags = result.selectedTags;
                  filterSelectedDate = result.selectedDate;
                  filterDurationFilter = result.durationFilter;
                  applyFilters();
                });
              } else if (result == null) {
                setState(() {
                  buildResult = false;
                  isFilterApplied = false;
                  filterSelectedCategories = [];
                  filterSelectedTags = [];
                  filterSelectedDate = null;
                  filterDurationFilter = null;
                });
              }
            },
            icon: Icon(
              Icons.filter_list,
              color: UiUtils.getColorScheme(context).primaryContainer,
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appbar(),
      body: _showContent(),
    );
  }

  Widget listItem(int index) {
    if (_controllerList.length < index + 1) {
      _controllerList.add(TextEditingController());
    }
    return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 7.0),
        child: ListTile(
            title: CustomTextLabel(
              text: searchList[index].title!,
              textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(7.0), child: CustomNetworkImage(networkImageUrl: searchList[index].image ?? "", height: 80, width: 80, fit: BoxFit.cover, isVideo: false)),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              List<NewsModel> addNewsList = [];
              addNewsList.addAll(searchList);
              addNewsList.removeAt(index);
              UiUtils.showInterstitialAds(context: context);
              Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": searchList[index], "newsList": addNewsList, "isFromBreak": false, "fromShowMore": false});
            }));
  }

  Future getSearchNews({bool? isFilter}) async {
    if (await InternetConnectivity.isNetworkAvailable()) {
      try {
        String latitude = SettingsLocalDataRepository().getLocationCityValues().first;
        String longitude = SettingsLocalDataRepository().getLocationCityValues().last;

        if (notificationisloadmore || (isFilter ?? false)) {
          if (mounted) {
            setState(() {
              notificationisloadmore = false;
              notificationisgettingdata = true;
              if (notificationoffset == 0) {
                searchList = [];
              }
            });
          }

          var parameter = {
            if (query.isNotEmpty) SEARCH: query.trim(),
            LIMIT: "20",
            OFFSET: notificationoffset.toString(),
            LANGUAGE_ID: context.read<AppLocalizationCubit>().state.id,
          };
          if (latitude != "null" && longitude != "null") {
            parameter[LATITUDE] = latitude;
            parameter[LONGITUDE] = longitude;
          }

          // Apply filters if present
          if (filterSelectedCategories.isNotEmpty) {
            parameter[CATEGORY_ID] = filterSelectedCategories.map((cat) => cat.id).join(',');
          }
          if (filterSelectedTags.isNotEmpty) {
            parameter[TAG_ID] = filterSelectedTags.map((tag) => tag.id).join(',');
          }
          if (filterSelectedDate != null) {
            parameter[DATE] = "${filterSelectedDate!.year}-${filterSelectedDate!.month.toString().padLeft(2, '0')}-${filterSelectedDate!.day.toString().padLeft(2, '0')}";
          }
          if (filterDurationFilter != null) {
            ///To map will be called so automatic it will add the parm of selected type
            parameter.addAll(filterDurationFilter!.toMap());
          }

          final result = await Api.sendApiRequest(body: parameter, url: Api.getNewsApi);

          print('>>>res are  $result');
          bool error = result["error"];
          int totalResult = result[TOTAL];
          notificationisgettingdata = false;
          if (notificationoffset == 0) {
            if (error == false && totalResult > 0) {
              notificationisnodata = false;
            } else {
              notificationisnodata = true;
            }
          }
          if (error == false && totalResult > 0) {
            if (mounted) {
              Future.delayed(
                  Duration.zero,
                  () => setState(() {
                        List mainlist = result[DATA];
                        if (mainlist.isNotEmpty) {
                          List<NewsModel> items = [];
                          List<NewsModel> allItems = [];
                          items.addAll(mainlist.map((data) => NewsModel.fromJson(data)).toList());
                          allItems.addAll(items);

                          if (notificationoffset == 0 && (isFilter ?? !buildResult)) {
                            NewsModel element = NewsModel(title: '${UiUtils.getTranslatedLabel(context, 'searchForLbl')} "$query"', image: "", history: false);
                            searchList.insert(0, element);
                            for (int i = 0; i < history.length; i++) {
                              if (history[i].title == query) {
                                searchList.insert(0, history[i]);
                              }
                            }
                          }

                          for (NewsModel item in items) {
                            searchList.where((i) => i.id == item.id).map((obj) {
                              allItems.remove(item);
                              return obj;
                            }).toList();
                          }
                          searchList.addAll(allItems);
                          notificationisloadmore = false;
                          notificationoffset = notificationoffset + limitOfAPIData;
                        } else {
                          notificationisloadmore = false;
                        }
                      }));
            }
          } else {
            notificationisloadmore = false;
            setState(() {});
          }
        }
      } on TimeoutException catch (_) {
        showSnackBar(UiUtils.getTranslatedLabel(context, 'somethingMSg'), context);
        setState(() {
          notificationisloadmore = false;
        });
      } catch (e) {
        setState(() {
          notificationisnodata = true;
          notificationisloadmore = false;
        });
      }
    } else {
      setState(() {
        isNetworkAvail = false;
      });
    }
  }

  clearAll() {
    setState(() {
      query = _controller.text;
      notificationoffset = 0;
      notificationisloadmore = true;
      searchList.clear();
    });
  }

  _showContent() {
    if (!isFilterApplied && _controller.text == "") {
      return FutureBuilder<List<String>>(
          future: getHistory(),
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              final List<String> entities = snapshot.data!;
              final List<NewsModel> itemList = [];
              for (int i = 0; i < entities.length; i++) {
                NewsModel item = NewsModel.history(entities[i]);
                itemList.add(item);
              }
              history.clear();
              history.addAll(itemList);

              return SingleChildScrollView(
                padding: const EdgeInsetsDirectional.only(top: 15.0),
                child: Column(
                  children: [
                    _SuggestionList(
                      textController: _controller,
                      suggestions: itemList,
                      notificationController: notificationcontroller,
                      getProduct: getSearchNews,
                      clearAll: clearAll,
                    ),
                  ],
                ),
              );
            } else {
              return const Column();
            }
          });
    } else if (buildResult) {
      return notificationisnodata
          ? const Center(child: CustomTextLabel(text: 'noNews'))
          : Padding(
              padding: const EdgeInsetsDirectional.only(top: 15.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsetsDirectional.only(bottom: 5, start: 10, end: 10, top: 12),
                        controller: notificationcontroller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: searchList.length,
                        itemBuilder: (context, index) {
                          NewsModel? item;
                          try {
                            item = searchList.isEmpty ? null : searchList[index];
                            if (notificationisloadmore && index == (searchList.length - 1) && notificationcontroller!.position.pixels <= 0) {
                              getSearchNews();
                            }
                          } on Exception catch (_) {}
                          return item == null ? const SizedBox.shrink() : listItem(index);
                        }),
                  ),
                  notificationisgettingdata ? const Padding(padding: EdgeInsetsDirectional.only(top: 5, bottom: 5), child: CircularProgressIndicator()) : const SizedBox.shrink()
                ],
              ));
    }
    return notificationisnodata
        ? const Center(child: CustomTextLabel(text: 'noNews'))
        : Padding(
            padding: const EdgeInsetsDirectional.only(top: 15.0),
            child: Column(
              children: <Widget>[
                Expanded(child: _SuggestionList(textController: _controller, suggestions: searchList, notificationController: notificationcontroller, getProduct: getSearchNews, clearAll: clearAll)),
                notificationisgettingdata ? const Padding(padding: EdgeInsetsDirectional.only(top: 5, bottom: 5), child: CircularProgressIndicator()) : const SizedBox.shrink()
              ],
            ));
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.textController, this.notificationController, this.getProduct, this.clearAll});

  final List<NewsModel>? suggestions;
  final TextEditingController? textController;

  final notificationController;
  final Function? getProduct, clearAll;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions!.length,
      shrinkWrap: true,
      controller: notificationController,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int i) {
        final NewsModel suggestion = suggestions![i];

        return ListTile(
            title: CustomTextLabel(
                text: suggestion.title!,
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            leading: textController!.text.toString().trim().isEmpty || suggestion.history!
                ? const Icon(Icons.history)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: suggestion.image == ''
                        ? Image.asset(UiUtils.getPlaceholderPngPath(), height: 80, width: 80)
                        : CustomNetworkImage(networkImageUrl: suggestion.image!, height: 80, width: 80, fit: BoxFit.cover, isVideo: false)),
            trailing: SvgPictureWidget(
                assetName: "searchbar_arrow",
                height: 11,
                width: 11,
                fit: BoxFit.contain,
                assetColor: ColorFilter.mode(UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), BlendMode.srcIn)),
            onTap: () async {
              if (suggestion.title!.startsWith('${UiUtils.getTranslatedLabel(context, 'searchForLbl')} ')) {
                UiUtils.setDynamicListValue(historyListKey, textController!.text.toString().trim());
                buildResult = true;
                clearAll!();
                getProduct!();
              } else if (suggestion.history!) {
                clearAll!();
                buildResult = true;
                textController!.text = suggestion.title!;
                textController!.selection = TextSelection.fromPosition(TextPosition(offset: textController!.text.length));
              } else {
                UiUtils.setDynamicListValue(historyListKey, textController!.text.trim());
                buildResult = false;
                UiUtils.showInterstitialAds(context: context);
                Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": suggestion, "isFromBreak": false, "fromShowMore": false});
              }
            });
      },
    );
  }
}
