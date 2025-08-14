import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/models/CommentModel.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/delAndReportReplyComm.dart';
import 'package:news/ui/styles/colors.dart';

import 'package:news/ui/widgets/customTextLabel.dart';

import 'package:news/utils/uiUtils.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/NewsComment/likeAndDislikeCommCubit.dart';
import 'package:news/cubits/NewsComment/setCommentCubit.dart';
import 'package:news/cubits/commentNewsCubit.dart';
import 'package:news/data/repositories/NewsComment/LikeAndDislikeComment/likeAndDislikeCommRepository.dart';

class ReplyCommentView extends StatefulWidget {
  final int replyComIndex;
  final Function replyComFun;
  final String newsId;

  const ReplyCommentView({super.key, required this.replyComIndex, required this.replyComFun, required this.newsId});

  @override
  ReplyCommentViewState createState() => ReplyCommentViewState();
}

class ReplyCommentViewState extends State<ReplyCommentView> {
  bool isReply = false, replyComEnabled = false, isSending = false;
  final TextEditingController _replyComC = TextEditingController();
  TextEditingController reportC = TextEditingController();

  Widget allReplyComView(CommentModel model) {
    return Row(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(children: [
            CustomTextLabel(
                text: 'allLbl',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6), fontSize: 12.0, fontWeight: FontWeight.w600)),
            CustomTextLabel(
                text: " ${model.replyComList!.length} ",
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6), fontSize: 12.0, fontWeight: FontWeight.w600)),
            CustomTextLabel(
                text: (model.replyComList!.length == 1) ? 'replyLbl' : 'repliesLbl',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6), fontSize: 12.0, fontWeight: FontWeight.w600)),
          ])),
      const Spacer(),
      Align(
          alignment: Alignment.topRight,
          child: InkWell(
              child: const Icon(Icons.close),
              onTap: () {
                setState(() => isReply = false);
                widget.replyComFun(false, widget.replyComIndex);
              }))
    ]);
  }

  replyComProfileWithCom(CommentModel modelCom) {
    return BlocBuilder<LikeAndDislikeCommCubit, LikeAndDislikeCommState>(
      builder: (context, state) {
        DateTime replyTime = DateTime.parse(modelCom.date!);
        return Container(
            decoration: BoxDecoration(border: Border.all(width: 2, color: borderColor)),
            padding: const EdgeInsets.all(10),
            child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              modelCom.profile != null && modelCom.profile != ""
                  ? UiUtils.setFixedSizeboxForProfilePicture(childWidget: CircleAvatar(backgroundImage: NetworkImage(modelCom.profile!), radius: 32))
                  : UiUtils.setFixedSizeboxForProfilePicture(childWidget: const Icon(Icons.account_circle, size: 35)),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomTextLabel(
                                  text: modelCom.name!,
                                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 13)),
                              Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 10.0),
                                  child: Icon(Icons.circle, size: 4.0, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7))),
                              Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 10.0),
                                  child: CustomTextLabel(
                                      text: UiUtils.convertToAgo(context, replyTime, 1)!,
                                      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 10)))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: CustomTextLabel(
                                text: modelCom.message!,
                                textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.normal)),
                          ),
                        ],
                      ))),
            ]));
      },
    );
  }

  replyComSendReplyView(CommentModel model) {
    return context.read<AuthCubit>().getUserId() != "0"
        ? Padding(
            padding: const EdgeInsetsDirectional.only(top: 10.0),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: context.read<AuthCubit>().getProfile() != ""
                        ? UiUtils.setFixedSizeboxForProfilePicture(childWidget: CircleAvatar(backgroundImage: NetworkImage(context.read<AuthCubit>().getProfile()), radius: 32))
                        : UiUtils.setFixedSizeboxForProfilePicture(childWidget: const Icon(Icons.account_circle, size: 35))),
                BlocListener<SetCommentCubit, SetCommentState>(
                    bloc: context.read<SetCommentCubit>(),
                    listener: (context, state) {
                      if (state is SetCommentFetchSuccess) {
                        context.read<CommentNewsCubit>().commentUpdateList(state.setComment, state.total);
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        _replyComC.clear();
                        isSending = false;
                        setState(() {});
                      }
                      if (state is SetCommentFetchInProgress) {
                        setState(() => isSending = true);
                      }
                    },
                    child: Expanded(
                        flex: 7,
                        child: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 18.0),
                            child: TextField(
                              controller: _replyComC,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7)),
                              onChanged: (String val) {
                                if (_replyComC.text.trim().isNotEmpty) {
                                  setState(() => replyComEnabled = true);
                                } else {
                                  setState(() => replyComEnabled = false);
                                }
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
                                  isDense: true,
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5), width: 1.5)),
                                  hintText: UiUtils.getTranslatedLabel(context, 'publicReply'),
                                  hintStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7)),
                                  suffixIconConstraints: const BoxConstraints(maxHeight: 35, maxWidth: 30),
                                  suffixIcon: (_replyComC.text.trim().isNotEmpty)
                                      ? (!isSending)
                                          ? IconButton(
                                              icon: Icon(Icons.send, color: replyComEnabled ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8) : Colors.transparent, size: 20.0),
                                              onPressed: () async {
                                                if (context.read<AuthCubit>().getUserId() != "0") {
                                                  context.read<SetCommentCubit>().setComment(parentId: model.id!, newsId: widget.newsId, message: _replyComC.text);
                                                } else {
                                                  UiUtils.loginRequired(context);
                                                }
                                              },
                                            )
                                          : SizedBox(height: 12, width: 12, child: UiUtils.showCircularProgress(true, Theme.of(context).primaryColor))
                                      : SizedBox.shrink()),
                            ))))
              ],
            ))
        : const SizedBox.shrink();
  }

  replyAllComListView(CommentModel model) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5)),
                shrinkWrap: true,
                reverse: true,
                padding: const EdgeInsets.only(top: 20.0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.replyComList!.length,
                itemBuilder: (context, index) {
                  DateTime time1 = DateTime.parse(model.replyComList![index].date!);
                  return Builder(builder: (context) {
                    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      model.replyComList![index].profile != null && model.replyComList![index].profile != ""
                          ? UiUtils.setFixedSizeboxForProfilePicture(childWidget: CircleAvatar(backgroundImage: NetworkImage(model.replyComList![index].profile!), radius: 32))
                          : UiUtils.setFixedSizeboxForProfilePicture(childWidget: const Icon(Icons.account_circle, size: 35)),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsetsDirectional.only(start: 15.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomTextLabel(
                                          text: model.replyComList![index].name!,
                                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 13)),
                                      Padding(
                                          padding: const EdgeInsetsDirectional.only(start: 10.0),
                                          child: Icon(Icons.circle, size: 4.0, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7))),
                                      Padding(
                                          padding: const EdgeInsetsDirectional.only(start: 10.0),
                                          child: CustomTextLabel(
                                            text: UiUtils.convertToAgo(context, time1, 1)!,
                                            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 10),
                                          )),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: CustomTextLabel(
                                      text: model.replyComList![index].message!,
                                      textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                  BlocBuilder<LikeAndDislikeCommCubit, LikeAndDislikeCommState>(builder: (context, state) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            child: const Icon(Icons.thumb_up_off_alt_rounded),
                                            onTap: () {
                                              (context.read<AuthCubit>().getUserId() != "0")
                                                  ? context.read<LikeAndDislikeCommCubit>().setLikeAndDislikeComm(
                                                      langId: context.read<AppLocalizationCubit>().state.id,
                                                      commId: model.replyComList![index].id!,
                                                      status: (model.replyComList![index].like == "1") ? "0" : "1",
                                                      fromLike: true)
                                                  : UiUtils.loginRequired(context);
                                            },
                                          ),
                                          model.replyComList![index].totalLikes! != "0"
                                              ? Padding(
                                                  padding: const EdgeInsetsDirectional.only(start: 4.0),
                                                  child: CustomTextLabel(
                                                      text: model.replyComList![index].totalLikes!,
                                                      textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)))
                                              : const SizedBox(width: 12),
                                          Padding(
                                              padding: const EdgeInsetsDirectional.only(start: 35),
                                              child: InkWell(
                                                child: const Icon(Icons.thumb_down_alt_rounded),
                                                onTap: () {
                                                  (context.read<AuthCubit>().getUserId() != "0")
                                                      ? context.read<LikeAndDislikeCommCubit>().setLikeAndDislikeComm(
                                                          langId: context.read<AppLocalizationCubit>().state.id,
                                                          commId: model.replyComList![index].id!,
                                                          status: (model.replyComList![index].dislike == "1") ? "0" : "2",
                                                          fromLike: false)
                                                      : UiUtils.loginRequired(context);
                                                },
                                              )),
                                          model.replyComList![index].totalDislikes! != "0"
                                              ? Padding(
                                                  padding: const EdgeInsetsDirectional.only(start: 4.0),
                                                  child: CustomTextLabel(
                                                      text: model.replyComList![index].totalDislikes!,
                                                      textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)))
                                              : const SizedBox.shrink(),
                                          const Spacer(),
                                          if (context.read<AuthCubit>().getUserId() != "0")
                                            InkWell(
                                                child: Icon(Icons.more_vert_outlined, color: UiUtils.getColorScheme(context).primaryContainer, size: 17),
                                                onTap: () => delAndReportReplyComm(model: model, context: context, reportC: reportC, newsId: widget.newsId, setState: setState, replyIndex: index))
                                        ],
                                      ),
                                    );
                                  })
                                ],
                              ))),
                    ]);
                  });
                })));
  }

  Widget replyCommentView() {
    return BlocBuilder<CommentNewsCubit, CommentNewsState>(builder: (context, state) {
      if (state is CommentNewsFetchSuccess && state.commentNews.isNotEmpty) {
        return BlocListener<LikeAndDislikeCommCubit, LikeAndDislikeCommState>(
          listener: (context, likeDislikeState) {
            if (likeDislikeState is LikeAndDislikeCommSuccess) {
              final defaultIndex = state.commentNews.indexWhere((element) => element.id == likeDislikeState.comment.id);
              if (defaultIndex != -1) {
                state.commentNews[defaultIndex].replyComList = likeDislikeState.comment.replyComList;
                context.read<CommentNewsCubit>().emitSuccessState(state.commentNews);
              }
            }
          },
          child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  allReplyComView(state.commentNews[widget.replyComIndex]),
                  replyComProfileWithCom(state.commentNews[widget.replyComIndex]),
                  replyComSendReplyView(state.commentNews[widget.replyComIndex]),
                  replyAllComListView(state.commentNews[widget.replyComIndex])
                ],
              )),
        );
      }
      if (state is CommentNewsFetchFailure) {
        return Center(child: CustomTextLabel(text: state.errorMessage, textAlign: TextAlign.center));
      }
      //state is CommentNewsFetchInProgress || state is CommentNewsInitial
      return const Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0), child: SizedBox.shrink());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => LikeAndDislikeCommCubit(LikeAndDislikeCommRepository()), child: replyCommentView());
  }
}
