import 'package:find_dropdown/find_dropdown.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  
  SearchBar({
    @required this.items,
    this.selectedItem,
    this.onChanged,
    this.hint: 'Search...'
  });

  final List items;
  final selectedItem;
  final String hint;
  final Function(dynamic) onChanged;

  @override
  Widget build(BuildContext context) {
    return FindDropdown(
      items: items,
      label: hint,
      onChanged: onChanged,
      selectedItem: selectedItem,
      validate: (item) {
        if (item == null)
          return "Обязательно";
        else
          return null;
      },
    );
  }
}