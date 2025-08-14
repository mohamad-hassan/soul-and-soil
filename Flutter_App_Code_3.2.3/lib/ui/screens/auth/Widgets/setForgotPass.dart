import 'package:flutter/material.dart';
import 'package:news/ui/widgets/customTextBtn.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';

setForgotPass(BuildContext context) {
  return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Align(
          alignment: Alignment.topRight,
          child: CustomTextButton(
              onTap: () => Navigator.of(context).pushNamed(Routes.forgotPass),
              buttonStyle: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent), foregroundColor: WidgetStateProperty.all(UiUtils.getColorScheme(context).outline.withOpacity(0.7))),
              textWidget: const CustomTextLabel(text: 'forgotPassLbl'))));
}
