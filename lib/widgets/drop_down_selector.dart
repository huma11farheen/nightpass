import 'package:clubship/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DropDownSelector<T> extends StatefulWidget {
  const DropDownSelector({
    super.key,
    required this.labelText,
    required this.values,
    required this.labels,
    required this.onChanged,
    this.initialValue,
    this.isRequired = false,
  });

  final String labelText;
  final List<T> values;
  final List<String> labels;
  final T? initialValue;
  final void Function(T) onChanged;
  final bool? isRequired;

  @override
  State<DropDownSelector<T>> createState() => _DropDownSelectorState<T>();
}

class _DropDownSelectorState<T> extends State<DropDownSelector<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null &&
        widget.values.contains(widget.initialValue)) {
      selectedValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _showBottomSheet(
          context: context,
          labels: widget.labels,
          onChanged: (index) {
            final newValue = widget.values[index];
            setState(() => selectedValue = newValue);
            widget.onChanged(newValue);
          },
          initialItem: selectedValue != null
              ? widget.values.indexOf(selectedValue as T)
              : 0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ColorPallete.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0,left: 12),
                  child: Text(
                    selectedValue != null
                        ? widget
                            .labels[widget.values.indexOf(selectedValue as T)]
                        : '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFD8D8D8),
                        ),
                  ),
                ),
              ),
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: Text(
              //     selectedValue != null
              //         ? widget.labels[widget.values.indexOf(selectedValue as T)]
              //         : '',
              //     style: Theme.of(context)
              //         .textTheme
              //         .labelMedium
              //         ?.copyWith(color: const Color(0xFFD8D8D8)),
              //   ).pad.right.p16.pad.bottom.p8,
              // ),
            ],
          ),
        ),
      );

  void _showBottomSheet({
    required BuildContext context,
    required List<String> labels,
    required int initialItem,
    required void Function(int index) onChanged,
  }) {
    int selectedIndex = initialItem;

    showCupertinoModalPopup<void>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(8),
        ),
        height: 220.0,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  onChanged(selectedIndex); // 👈 call onChanged manually
                  context.pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16),
                  child: Text(
                    'Done',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: initialItem),
                backgroundColor: const Color(0xFF1D1D1D),
                onSelectedItemChanged: (index) {
                  selectedIndex = index; // 👈 update local selection
                },
                itemExtent: 40.0,
                children: labels
                    .map(
                      (label) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
