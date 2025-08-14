import 'dart:io';

import 'package:flutter/material.dart';
import 'package:news/ui/screens/auth/Widgets/svgPictureWidget.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';

class CustomAlertDialog extends StatelessWidget {
  final BuildContext context;
  final String yesButtonText;
  final String yesButtonTextPostfix;
  final String noButtonText;
  final String imageName;
  final Widget titleWidget;
  final String messageText;
  final Function() onYESButtonPressed;
  final bool isForceAppUpdate;
  const CustomAlertDialog(
      {super.key,
      required this.context,
      required this.yesButtonText,
      required this.yesButtonTextPostfix,
      required this.noButtonText,
      required this.imageName,
      required this.titleWidget,
      required this.messageText,
      required this.onYESButtonPressed,
      required this.isForceAppUpdate});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20),
      backgroundColor: UiUtils.getColorScheme(context).surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (imageName.isNotEmpty) SvgPictureWidget(assetName: imageName),
          const SizedBox(height: 15),
          titleWidget,
          const SizedBox(height: 5),
          CustomTextLabel(text: messageText, textAlign: TextAlign.center, textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actionsOverflowButtonSpacing: 15,
      actions: <Widget>[
        MaterialButton(
          minWidth: MediaQuery.of(context).size.width / 3.5,
          elevation: 0.0,
          highlightColor: Colors.transparent,
          color: Colors.transparent,
          splashColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer)),
          onPressed: () => (isForceAppUpdate) ? exit(0) : Navigator.of(context).pop(false),
          child: CustomTextLabel(
              text: noButtonText, textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w500)),
        ),
        MaterialButton(
            elevation: 0.0,
            color: UiUtils.getColorScheme(context).primaryContainer,
            splashColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onPressed: onYESButtonPressed,
            child: RichText(
              text: TextSpan(
                  text: UiUtils.getTranslatedLabel(context, yesButtonText),
                  style: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).surface, fontWeight: FontWeight.w500),
                  children: [
                    (yesButtonTextPostfix.isNotEmpty) ? const TextSpan(text: " , ") : const TextSpan(text: ""),
                    TextSpan(
                        text: UiUtils.getTranslatedLabel(context, yesButtonTextPostfix),
                        style: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).surface, fontWeight: FontWeight.w500))
                  ]),
            )),
      ],
    );
  }
}
