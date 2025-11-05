import 'package:flutter/material.dart';

class FilterDropdownWidget extends StatelessWidget {
  final String selectedValue;
  final List<String> items;
  final Function(String) onChanged;

  const FilterDropdownWidget({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: selectedValue,
          items:
              items
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}
