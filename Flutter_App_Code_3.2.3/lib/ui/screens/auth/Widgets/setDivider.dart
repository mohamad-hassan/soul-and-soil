import 'package:flutter/material.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';

class SetDividerOR extends StatelessWidget {
  const SetDividerOR({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = UiUtils.getColorScheme(context).outline.withOpacity(0.9);
    return Padding(
        padding: const EdgeInsetsDirectional.only(top: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Divider(indent: 10, endIndent: 10, color: color)),
            CustomTextLabel(
              text: 'orLbl',
              textStyle: Theme.of(context).textTheme.titleMedium?.merge(TextStyle(color: color, fontSize: 12.0)),
            ),
            Expanded(child: Divider(indent: 10, endIndent: 10, color: color)),
          ],
        ));
  }
}
