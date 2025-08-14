import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/breakingNewsCubit.dart';
import 'package:news/cubits/languageCubit.dart';
import 'package:news/cubits/slugNewsCubit.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/utils/strings.dart';
import 'package:news/utils/uiUtils.dart';

//TODO: if change in API calls or variables, change the same in Dashboard screen > initDynamicLinks()
class LoadingScreen extends StatefulWidget {
  String routeSettingsName;
  String newsSlug;

  LoadingScreen({required this.routeSettingsName, required this.newsSlug, Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    fetchData();
    isLoading.addListener(() {
      if (!isLoading.value) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API delay
    if (widget.routeSettingsName.contains('/news/')) {
      String langCodeShared = widget.routeSettingsName.split("/")[1];
      String? langIdPass = UiUtils.rootNavigatorKey.currentContext!.read<AppLocalizationCubit>().state.id;
      if (context.read<LanguageCubit>().langList().isNotEmpty) langIdPass = context.read<LanguageCubit>().langList().firstWhere((e) => e.code == langCodeShared).id;
      UiUtils.rootNavigatorKey.currentContext?.read<SlugNewsCubit>().getSlugNews(langId: langIdPass ?? "0", newsSlug: widget.newsSlug).then((value) {
        if (value[DATA] != null) {
          NewsModel? model = (value[DATA] as List).map((e) => NewsModel.fromJson(e)).toList().first;
          Navigator.popAndPushNamed(context, Routes.newsDetails,
              arguments: {"model": model, "slug": widget.newsSlug, "isFromBreak": widget.routeSettingsName.contains('/breaking-news/') ? true : false, "fromShowMore": false});
        } else {
          setState(() {
            isLoading.value = false;
          });
        }
      });
    } else if (widget.routeSettingsName.contains('/breaking-news/')) {
      UiUtils.rootNavigatorKey.currentContext?.read<BreakingNewsCubit>().getBreakingNews(langId: UiUtils.rootNavigatorKey.currentContext!.read<AppLocalizationCubit>().state.id).then((value) {
        BreakingNewsModel? brModel = value[0];
        Navigator.of(context).pushReplacementNamed(Routes.newsDetails, arguments: {"breakModel": brModel, "slug": widget.newsSlug, "isFromBreak": true, "fromShowMore": false});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, value, child) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        });
  }
}
