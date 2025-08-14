import 'package:flutter/material.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/styles/colors.dart';

class CustomTextButton extends StatelessWidget {
  final Function onTap;
  final Color? color;
  final String? text;
  final ButtonStyle? buttonStyle;
  final Widget? textWidget;

  const CustomTextButton({super.key, required this.onTap, this.color, this.text, this.buttonStyle, this.textWidget});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: buttonStyle ?? ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent), foregroundColor: WidgetStateProperty.all(darkSecondaryColor)),
      onPressed: () {
        onTap();
      },
      child: textWidget ?? CustomTextLabel(text: text!, textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: color, fontWeight: FontWeight.normal)),
    );
  }
}
