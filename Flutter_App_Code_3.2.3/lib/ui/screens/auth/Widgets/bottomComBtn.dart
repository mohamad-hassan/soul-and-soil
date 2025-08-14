import 'package:flutter/material.dart';
import 'package:news/ui/screens/auth/Widgets/svgPictureWidget.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';

class BottomCommButton extends StatelessWidget {
  final Function onTap;
  final String img;
  final Color? btnColor;
  final String btnCaption;

  const BottomCommButton({super.key, required this.onTap, required this.img, this.btnColor, required this.btnCaption});

  @override
  Widget build(BuildContext context) {
    String textLbl = "${UiUtils.getTranslatedLabel(context, 'continueWith')} ${UiUtils.getTranslatedLabel(context, btnCaption)}";
    return InkWell(
        splashColor: Colors.transparent,
        child: Container(
            height: 45.0,
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: UiUtils.getColorScheme(context).surface, borderRadius: BorderRadius.circular(7.0)),
            padding: const EdgeInsets.all(9.0),
            margin: EdgeInsets.symmetric(vertical: 10),
            //decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: secondaryColor),
            child: Wrap(
              // crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 15,
              children: [
                SvgPictureWidget(assetName: img, width: 20, height: 20, fit: BoxFit.contain, assetColor: btnColor != null ? ColorFilter.mode(btnColor!, BlendMode.srcIn) : null),
                CustomTextLabel(text: textLbl, textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
              ],
            )),
        onTap: () => onTap());
  }
}
