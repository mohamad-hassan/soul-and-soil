import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/LiveStreamingModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/screens/Videos/Widgets/otherVideosCard.dart';
import 'package:news/ui/screens/Videos/Widgets/videoCard.dart';
import 'package:news/ui/widgets/customAppBar.dart';
import 'package:news/utils/uiUtils.dart';

class VideoDetailsScreen extends StatefulWidget {
  int from;
  LiveStreamingModel? liveModel;
  NewsModel? model;
  BreakingNewsModel? breakModel;
  List<NewsModel>? otherVideos;
  List<BreakingNewsModel>? otherBreakingVideos;
  List<LiveStreamingModel>? otherLiveVideos;

  VideoDetailsScreen({super.key, this.model, required this.from, this.liveModel, this.breakModel, required this.otherVideos, this.otherLiveVideos, this.otherBreakingVideos});

  @override
  State<StatefulWidget> createState() => VideoDetailsState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
        builder: (_) => VideoDetailsScreen(
            from: arguments['from'],
            liveModel: arguments['liveModel'],
            model: arguments['model'],
            breakModel: arguments['breakModel'],
            otherVideos: arguments['otherVideos'],
            otherLiveVideos: arguments['otherLiveVideos'],
            otherBreakingVideos: arguments['otherBreakingVideos']));
  }
}

class VideoDetailsState extends State<VideoDetailsScreen> {
  bool isLiveVideo = false, isBreakingNewsVideo = false, isNewsVideo = true;
  //FROM VAL 1 = news, 2 = liveNews , 3 = breakingNews

  @override
  void initState() {
    isLiveVideo = (widget.from == 2);
    isBreakingNewsVideo = (widget.from == 3);
    isNewsVideo = !(isLiveVideo || isBreakingNewsVideo);
    super.initState();
  }

  @override
  void dispose() {
    // set screen back to portrait mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return Scaffold(
      backgroundColor: UiUtils.getColorScheme(context).surface,
      appBar: CustomAppBar(height: 45, isBackBtn: true, label: 'videosLbl', isConvertText: true),
      // AppBar(
      //     title: Text(UiUtils.getTranslatedLabel(context, 'videosLbl')),
      //     backgroundColor: UiUtils.getColorScheme(context).surface,
      //     foregroundColor: UiUtils.getColorScheme(context).onPrimary,
      //     elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VideoCard(
                model: (widget.model != null) ? widget.model : null, brModel: (widget.breakModel != null) ? widget.breakModel : null, liveModel: (widget.liveModel != null) ? widget.liveModel : null),
            const SizedBox(height: 16),
            ((isLiveVideo && widget.otherLiveVideos != null && widget.otherLiveVideos!.isNotEmpty) ||
                    ((widget.otherVideos != null && widget.otherVideos!.isNotEmpty) || (widget.otherBreakingVideos != null && widget.otherBreakingVideos!.isNotEmpty)))
                ? Text(
                    UiUtils.getTranslatedLabel(context, 'recentVidLbl'),
                    style: TextStyle(color: UiUtils.getColorScheme(context).onPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                  )
                : SizedBox.shrink(),
            const SizedBox(height: 8),
            ((isLiveVideo && widget.otherLiveVideos != null && widget.otherLiveVideos!.isNotEmpty) ||
                    ((widget.otherVideos != null && widget.otherVideos!.isNotEmpty) || (widget.otherBreakingVideos != null && widget.otherBreakingVideos!.isNotEmpty)))
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (isLiveVideo)
                        ? widget.otherLiveVideos!.length
                        : (widget.otherVideos != null && widget.otherVideos!.isNotEmpty)
                            ? widget.otherVideos!.length
                            : widget.otherBreakingVideos!.length,
                    itemBuilder: (context, index) => OtherVideosCard(
                        brModel: (widget.otherBreakingVideos != null && widget.otherBreakingVideos!.isNotEmpty) ? widget.otherBreakingVideos![index] : null,
                        model: (widget.otherVideos != null && widget.otherVideos!.isNotEmpty) ? widget.otherVideos![index] : null,
                        liveModel: (widget.otherLiveVideos != null && widget.otherLiveVideos!.isNotEmpty) ? widget.otherLiveVideos![index] : null),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
