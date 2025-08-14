import 'package:flutter/material.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/LiveStreamingModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/uiUtils.dart';

class OtherVideosCard extends StatelessWidget {
  final NewsModel? model;
  final BreakingNewsModel? brModel;
  final LiveStreamingModel? liveModel;
  OtherVideosCard({super.key, this.model, this.brModel, this.liveModel});

  @override
  Widget build(BuildContext context) {
    bool isLive = liveModel != null;
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: UiUtils.getColorScheme(context).surface, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomNetworkImage(
                    networkImageUrl: (isLive)
                        ? liveModel!.image!
                        : (model != null)
                            ? model!.image!
                            : brModel!.image!,
                    height: 60,
                    width: 90,
                    fit: BoxFit.cover)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (!isLive && model != null)
                      ? Container(
                          height: 25.0,
                          width: 65,
                          alignment: Alignment.center,
                          padding: const EdgeInsetsDirectional.only(start: 3.0, end: 3.0, top: 1.0, bottom: 1.0),
                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)), color: UiUtils.getColorScheme(context).secondary.withOpacity(0.85)),
                          child: CustomTextLabel(
                              text: model!.categoryName ?? "",
                              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UiUtils.getColorScheme(context).onPrimary, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true))
                      : SizedBox.shrink(),
                  SizedBox(height: 4),
                  CustomTextLabel(
                      text: (isLive)
                          ? liveModel!.title!
                          : (model != null)
                              ? model!.title ?? ""
                              : brModel!.title ?? "",
                      textStyle: TextStyle(color: UiUtils.getColorScheme(context).onPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
