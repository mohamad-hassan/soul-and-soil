import 'package:flutter/material.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';

showSnackBar(String msg, BuildContext context, {int? durationInMiliSeconds}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: CustomTextLabel(text: msg, textAlign: TextAlign.center, textStyle: TextStyle(color: Theme.of(context).colorScheme.surface)),
      showCloseIcon: false,
      duration: Duration(milliseconds: durationInMiliSeconds ?? 1500), //bydefault 4000 ms
      backgroundColor: UiUtils.getColorScheme(context).primaryContainer,
      elevation: 1.0,
    ),
  );
}
