import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:news/ui/screens/NewsDetailsVideo.dart';

//TODO: test it with splitting of html content for customisation
// import 'package:html/parser.dart' as html_parser;
// import 'package:html/dom.dart' as dom;

Widget descView({required String desc, required double fontValue, required BuildContext context}) {
//TODO: test it with splitting of html content for customisation
  // final document = html_parser.parse(desc);
  // final List<dom.Node> nodes = document.body?.nodes ?? [];

  return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: HtmlWidget(
        desc,
        onTapUrl: (String? url) async {
          if (await canLaunchUrl(Uri.parse(url!))) {
            await launchUrl(Uri.parse(url));
            return true;
          } else {
            throw 'Could not launch $url';
          }
        },
        onErrorBuilder: (context, element, error) => CustomTextLabel(text: '$element error: $error'),
        onLoadingBuilder: (context, element, loadingProgress) => UiUtils.showCircularProgress(true, Theme.of(context).primaryColor),
        renderMode: RenderMode.column,
        // set the default styling for text
        textStyle: TextStyle(fontSize: fontValue.toDouble()),
        customWidgetBuilder: (element) {
          if ((element.toString() == "<html iframe>") || (element.toString() == "<html video>")) {
            return FittedBox(
              fit: BoxFit.fill,
              child: Container(
                  height: 220,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: (element.toString() == "<html iframe>") ? NewsDetailsVideo(src: element.attributes["src"], type: "1") : NewsDetailsVideo(type: "2", src: element.outerHtml)),
            );
          }
          return null;
        },
      ));
}
