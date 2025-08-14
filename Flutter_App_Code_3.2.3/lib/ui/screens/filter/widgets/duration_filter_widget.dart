import 'package:flutter/material.dart';
import 'package:news/utils/strings.dart';
import 'package:news/utils/uiUtils.dart';

abstract class DurationFilter {
  Map<String, String> toMap();
  String toText(BuildContext context);
}

class LastDays extends DurationFilter {
  final int daysCount;
  LastDays({required this.daysCount});
  @override
  toMap() {
    return {
      LAST_N_DAYS: daysCount.toString(),
    };
  }

  @override
  String toText(BuildContext context) {
    if (daysCount == 1) {
      return UiUtils.getTranslatedLabel(context, 'today');
    }

    return UiUtils.getTranslatedLabel(context, 'last') +
        ' $daysCount ' +
        UiUtils.getTranslatedLabel(context, 'days');
  }

  @override
  bool operator ==(covariant DurationFilter other) {
    if (identical(this, other)) return true;
    if (other is LastDays) {
      return other.daysCount == daysCount;
    }
    return false;
  }

  @override
  int get hashCode => daysCount.hashCode;
}

class Year extends DurationFilter {
  final int year;
  Year({required this.year});
  @override
  Map<String, String> toMap() {
    return {
      YEAR: year.toString(),
    };
  }

  @override
  String toText(BuildContext context) {
    return year.toString();
  }

  @override
  bool operator ==(covariant DurationFilter other) {
    if (identical(this, other)) return true;
    if (other is Year) {
      return other.year == year;
    }
    return false;
  }

  @override
  int get hashCode => year.hashCode;
}

class DurationFilterWidget extends StatefulWidget {
  final DurationFilter? selectedFilter;
  final List<DurationFilter> filters;
  final void Function(DurationFilter? filter)? onSelected;
  const DurationFilterWidget(
      {super.key, required this.filters, this.onSelected, this.selectedFilter});

  @override
  State<DurationFilterWidget> createState() => _DurationFilterWidgetState();
}

class _DurationFilterWidgetState extends State<DurationFilterWidget> {
  late DurationFilter? selectedFilter = widget.selectedFilter;

  @override
  void didUpdateWidget(DurationFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFilter != oldWidget.selectedFilter) {
      selectedFilter = widget.selectedFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Widget ${widget.selectedFilter}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.filters.map(
        (DurationFilter e) {
          return _buildDurationFilter(context, e);
        },
      ).toList(),
    );
  }

  Widget _buildDurationFilter(BuildContext context, DurationFilter filter) {
    return GestureDetector(
      onTap: () {
        if (selectedFilter == filter) {
          selectedFilter = null;
        } else {
          selectedFilter = filter;
        }
        widget.onSelected?.call(selectedFilter);

        setState(() {});
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: selectedFilter == filter
              ? UiUtils.getColorScheme(context)
                  .secondaryContainer
                  .withValues(alpha: 0.2)
              : UiUtils.getColorScheme(context).surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(filter.toText(context)),
        ),
      ),
    );
  }
}
