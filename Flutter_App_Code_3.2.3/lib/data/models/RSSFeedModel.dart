import 'package:news/data/models/CategoryModel.dart';
import 'package:news/utils/strings.dart';

class RSSFeedModel {
  String? id, feedName, feedUrl, categoryId, categoryName, subCatName, tagName;

  RSSFeedModel({this.id, this.feedName, this.feedUrl, this.categoryId, this.tagName, this.categoryName, this.subCatName});

  factory RSSFeedModel.fromJson(Map<String, dynamic> json) {
    String? tagName;

    tagName = (json[TAG] == null) ? "" : json[TAG];
    var categoryName = (json.containsKey(CATEGORY_NAME))
        ? json[CATEGORY_NAME]
        : (json.containsKey(CATEGORY) && (json[CATEGORY] != null))
            ? CategoryModel.fromJson(json[CATEGORY]).categoryName
            : '';
    var subcategoryName =
        (json.containsKey(SUBCAT_NAME)) ? json[SUBCAT_NAME] : ((json.containsKey(SUBCATEGORY) && json[SUBCATEGORY] != null) ? SubCategoryModel.fromJson(json[SUBCATEGORY]).subCatName : '');

    return RSSFeedModel(id: json[ID].toString(), feedName: json[FEED_NAME].toString(), feedUrl: json[FEED_URL], tagName: tagName, categoryName: categoryName, subCatName: subcategoryName);
  }
}
