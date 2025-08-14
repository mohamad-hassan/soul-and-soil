// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/categoryCubit.dart';
import 'package:news/cubits/tagCubit.dart';
import 'package:news/data/models/CategoryModel.dart';
import 'package:news/data/models/TagModel.dart';
import 'package:news/ui/screens/filter/widgets/custom_date_selector.dart';
import 'package:news/ui/screens/filter/widgets/duration_filter_widget.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/utils/uiUtils.dart';

class NewsFilterData {
  final List<CategoryModel> selectedCategories;
  final List<TagModel> selectedTags;
  final DateTime? selectedDate;
  final DurationFilter? durationFilter;

  NewsFilterData({required this.selectedCategories, required this.selectedTags, this.selectedDate, this.durationFilter});

  @override
  String toString() {
    return 'NewsFilterData(selectedCategories: $selectedCategories, selectedTags: $selectedTags, selectedDate: $selectedDate, durationFilter: $durationFilter)';
  }
}

class FilterBottomSheet extends StatefulWidget {
  final NewsFilterData initialFilters;
  final bool isCategoryModeON;

  const FilterBottomSheet({
    Key? key,
    required this.isCategoryModeON,
    required this.initialFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late final ValueNotifier<int> selectedFilterTabIndex = ValueNotifier(0);
  late List<CategoryModel> selectedCategories;
  late List<TagModel> selectedTags;
  DateTime? selectedDate;

  List<String> filterTabs = [];

  late DurationFilter? durationFilter = widget.initialFilters.durationFilter;
  @override
  void initState() {
    super.initState();
    filterTabs = [if (widget.isCategoryModeON) "catLbl", "tagLbl", "date"];

    selectedCategories = List.from(widget.initialFilters.selectedCategories);
    selectedTags = List.from(widget.initialFilters.selectedTags);
    selectedDate = widget.initialFilters.selectedDate;
  }

  @override
  void dispose() {
    selectedFilterTabIndex.dispose();
    super.dispose();
  }

  Widget _buildFilterTabItem({required String title, required int index}) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedFilterTabIndex,
      builder: (context, value, child) {
        final isSelected = value == index;
        return InkWell(
          onTap: () {
            selectedFilterTabIndex.value = index;
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: isSelected ? UiUtils.getColorScheme(context).secondaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? UiUtils.getColorScheme(context).secondary : UiUtils.getColorScheme(context).primaryContainer,
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? UiUtils.getColorScheme(context).surface : UiUtils.getColorScheme(context).onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryFetchInProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoryFetchFailure) {
          return Center(child: Text(state.errorMessage));
        }
        if (state is CategoryFetchSuccess) {
          return NotificationListener(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
                  if (context.read<CategoryCubit>().hasMoreCategory()) {
                    context.read<CategoryCubit>().getMoreCategory(langId: context.read<AppLocalizationCubit>().state.id);
                  }
                }
              }
              return true;
            },
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: state.category.length,
              itemBuilder: (context, index) {
                final category = state.category[index];
                final isSelected = selectedCategories.contains(category);

                return CheckboxListTile(
                  title: Text(
                    category.categoryName ?? "",
                    style: TextStyle(
                      color: UiUtils.getColorScheme(context).onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: isSelected,
                  activeColor: UiUtils.getColorScheme(context).primary,
                  checkColor: UiUtils.getColorScheme(context).onPrimary,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (!selectedCategories.contains(category)) {
                          selectedCategories.add(category);
                        }
                      } else {
                        selectedCategories.remove(category);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildTagList() {
    return BlocBuilder<TagCubit, TagState>(
      builder: (context, state) {
        if (state is TagFetchInProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TagFetchFailure) {
          return Center(child: Text(state.errorMessage));
        }
        if (state is TagFetchSuccess) {
          return NotificationListener(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
                  if (context.read<TagCubit>().hasMoreTags()) {
                    context.read<TagCubit>().getMoreTags(langId: context.read<AppLocalizationCubit>().state.id);
                  }
                }
              }
              return true;
            },
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: state.tag.length,
              itemBuilder: (context, index) {
                final tag = state.tag[index];
                final isSelected = selectedTags.contains(tag);

                return CheckboxListTile(
                  title: Text(
                    tag.tagName ?? "",
                    style: TextStyle(
                      color: UiUtils.getColorScheme(context).onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: isSelected,
                  activeColor: UiUtils.getColorScheme(context).primary,
                  checkColor: UiUtils.getColorScheme(context).onPrimary,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (!selectedTags.contains(tag)) {
                          selectedTags.add(tag);
                        }
                      } else {
                        selectedTags.remove(tag);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 250,
                child: CustomCalendarView(
                  selectedDate: selectedDate,
                  onDateSelected: (day) {
                    selectedDate = day;
                    setState(() {});
                  },
                )),
            DurationFilterWidget(
              selectedFilter: durationFilter,
              filters: [
                LastDays(daysCount: 1),
                LastDays(daysCount: 7),
                LastDays(daysCount: 30),
                LastDays(daysCount: 60),
                LastDays(daysCount: 90),
                ...List.generate(
                  7,
                  (int index) {
                    return Year(year: DateTime.now().year - index);
                  },
                ),
              ],
              onSelected: (DurationFilter? filter) {
                durationFilter = filter;
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterContent() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedFilterTabIndex,
      builder: (context, selectedIndex, _) {
        final views = widget.isCategoryModeON ? [_buildCategoryList(), _buildTagList(), _buildDatePicker()] : [_buildTagList(), _buildDatePicker()];
        return views[selectedIndex];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('>>>durationFilter $durationFilter');
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: UiUtils.getColorScheme(context).surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            UiUtils.getTranslatedLabel(context, "filter"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UiUtils.getColorScheme(context).onSurface,
            ),
          ),
          Divider(),
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: filterTabs
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: _buildFilterTabItem(
                                  title: UiUtils.getTranslatedLabel(context, entry.value),
                                  index: entry.key,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.grey[300],
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
                Expanded(
                  flex: 7,
                  child: _buildFilterContent(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategories = <CategoryModel>[];
                        selectedTags = <TagModel>[];
                        selectedDate = null;
                        durationFilter = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      UiUtils.getTranslatedLabel(context, 'clear'),
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final result = NewsFilterData(selectedCategories: selectedCategories, selectedTags: selectedTags, selectedDate: selectedDate, durationFilter: durationFilter);
                      Navigator.pop(context, result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      UiUtils.getTranslatedLabel(context, 'apply'),
                      style: TextStyle(
                        color: UiUtils.getColorScheme(context).onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Function to show the filter bottom sheet
Future<NewsFilterData?> showFilterBottomSheet({
  required BuildContext context,
  required bool isCategoryModeON,
  required NewsFilterData initialFilters,
}) async {
  return await showModalBottomSheet<NewsFilterData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
            isCategoryModeON: isCategoryModeON,
            initialFilters: initialFilters,
          ));
}
