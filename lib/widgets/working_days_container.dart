import 'package:clubship/colors.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/app_text_styles.dart';
import 'package:flutter/material.dart';

class WorkingDaysContainer extends StatefulWidget {
  const WorkingDaysContainer({
    super.key,
    required this.color,
    required this.onTagsChanged,
    required this.selectedTags,
    this.canEdit = true,
    this.title,
  });

  final Color color;
  final void Function(List<String> selectedTags) onTagsChanged;
  final List<String> selectedTags;
  final bool canEdit;
  final String? title;

  @override
  State<WorkingDaysContainer> createState() => _WorkingDaysContainerState();
}

class _WorkingDaysContainerState extends State<WorkingDaysContainer> {
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    // Initialize a mutable copy of widget.selectedTags
    selectedTags = List<String>.from(widget.selectedTags);
  }

  @override
  void didUpdateWidget(covariant WorkingDaysContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state when widget.selectedTags changes
    if (widget.selectedTags != oldWidget.selectedTags) {
      setState(() {
        selectedTags = List<String>.from(widget.selectedTags);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> displayedDays = widget.canEdit
        ? ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
        : selectedTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (widget.title == null || widget.title!.isNotEmpty) ...[
          Row(
            children: [
              AppIcons.calender(
                color: Colors.white,
              ),
              const SizedBox(width: 9),
              Text(
                widget.title ?? 'Working days ',
                textAlign: TextAlign.left,
                style: AppTextStyles.titleSmall,
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: [
            for (var day in displayedDays)
              ChoiceChip(
                showCheckmark: false,
                label: Text(
                  day,
                  style: TextStyle(
                    color: selectedTags.contains(day)
                        ? Colors.white
                        : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                selected: selectedTags.contains(day),
                selectedColor: ColorPallete.brightPink.withValues(alpha: 0.8),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selectedTags.contains(day)
                        ? ColorPallete.brightPink
                        : Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                onSelected:
                    widget.canEdit ? (_) => handleTagSelection(day) : (_) {},
              )
          ],
        ),
      ],
    );
  }

  void handleTagSelection(String genre) {
    if (widget.canEdit) {
      setState(() {
        if (selectedTags.contains(genre)) {
          selectedTags.remove(genre);
        } else {
          selectedTags.add(genre);
        }
        widget.onTagsChanged(List<String>.from(selectedTags));
      });
    }
  }
}
