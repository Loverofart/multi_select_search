import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:multi_select_search/src/search_field.dart';

/// Make sure your model class must contain fromJson & toJson method/
/// If you want to change selected item [Chip] theme change it in your AppTheme
class MultiSelectSearch<T> extends StatefulWidget {
  /// A builder to display list of widgets that you can select/unselect from.
  final Widget Function(T) itemBuilder;

  /// A field name of your model to show its value in [Chip]
  /// For examle: You have a List<Contact> and when a user selects from the list
  /// you want to show the selected contact's name in the chip.  e.g.Contact.name
  /// In this situation, you define chipLabelKey: 'name'
  final String chipLabelKey;

  /// List of all items to select from.
  final List<T> items;

  /// The list of initial selected values
  final List<T> initialValue;

  /// Search field & selected items [Container]'s max height
  final double? maxHeight;

  /// Search field & selected items [Container] decoration
  final Decoration? decoration;

  /// Search field & selected items [Container] decoration
  final EdgeInsetsGeometry? padding;

  /// Called everytime when user selects or unselects an item.
  /// Returns selected items.
  /// If user selects an item it gets added to the selected items.
  /// If user unselect by tapping on deleteIcon on the chip it gets removed from the selected items.
  final void Function(List<T> data) onChanged;

  /// Search field input decoration to change its style, hint text and more.
  final InputDecoration? searchFieldDecoration;

  // Chip related
  /// Selected item [Chip]'s text style
  final TextStyle? chipTextStyle;

  /// A widget to display when there is no more item to choose in the list
  final Widget? emptyListIndicator;

  /// When clicked, all selected items will be cleared.
  /// Don't give button widgets because they have their own onPressed method.
  final Widget? clearAll;

  const MultiSelectSearch({
    Key? key,
    this.padding,
    this.clearAll,
    this.maxHeight,
    this.decoration,
    this.chipTextStyle,
    required this.items,
    this.emptyListIndicator,
    required this.onChanged,
    required this.itemBuilder,
    required this.initialValue,
    this.searchFieldDecoration,
    required this.chipLabelKey,
  }) : super(key: key);

  @override
  State<MultiSelectSearch<T>> createState() => _MultiSelectSearchState<T>();
}

class _MultiSelectSearchState<T> extends State<MultiSelectSearch<T>> {
  final _contactListScrollController = ScrollController();
  final _chipsScrollController = ScrollController();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  late final ValueNotifier<List<T>> _listViewItems;
  List<T> _selectedItems = [];
  List<T> _availableItems = [];

  @override
  void initState() {
    super.initState();
    try {
      jsonDecode(jsonEncode(widget.items.first));
    } on JsonUnsupportedObjectError {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
            '${widget.items.first.runtimeType} must contain fromJson and toJson method.'),
      ]);
    }
    _selectedItems = [...widget.initialValue];
    _listViewItems = ValueNotifier(_removeSelectedItems());
    _availableItems = [..._listViewItems.value];
    _controller.addListener(() => _searchFilter());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _chipsScrollController.dispose();
    _contactListScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chips = List<Widget>.generate(_selectedItems.length, (index) {
      final label =
          jsonDecode(jsonEncode(_selectedItems[index]))[widget.chipLabelKey];
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Chip(
          label: Text(label, style: widget.chipTextStyle),
          labelPadding:
              const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
          onDeleted: () => _deleteChip(_selectedItems[index]),
        ),
      );
    });

    chips.add(
      SearchField(
        stepWidth: 100,
        controller: _controller,
        focusNode: _focusNode,
        decoration: widget.searchFieldDecoration,
      ),
    );

    return ValueListenableBuilder(
      valueListenable: _listViewItems,
      builder: ((context, listItems, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 100.0),
              padding: widget.padding ?? const EdgeInsets.only(left: 8.0),
              decoration: widget.decoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () =>
                          FocusScope.of(context).requestFocus(_focusNode),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: _chipsScrollController,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Wrap(
                            spacing: 6.0,
                            alignment: WrapAlignment.start,
                            children: chips,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.clearAll != null)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _clearAll(),
                        child: widget.clearAll,
                      ),
                    )
                ],
              ),
            ),
            // Item list view
            Flexible(
              child: listItems.isEmpty
                  ? widget.emptyListIndicator ??
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No more items"),
                      )
                  : ListView.builder(
                      shrinkWrap: true,
                      controller: _contactListScrollController,
                      itemCount: listItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () => _selectItem(listItems[index]),
                          child: widget.itemBuilder(listItems[index]),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  void _clearAll() {
    setState(() => _selectedItems = []);
    _controller.clear();
    _listViewItems.value = [...widget.items];
    _availableItems = [...widget.items];
  }

  void _deleteChip(T item) {
    setState(() => _selectedItems.remove(item));
    _listViewItems.value.insert(0, item);
    _availableItems.insert(0, item);

    if (_controller.text.isNotEmpty) _searchFilter();
    widget.onChanged.call(_selectedItems);
  }

  void _selectItem(T item) {
    _controller.clear();
    _selectedItems.add(item);
    _listViewItems.value.remove(item);
    _availableItems.remove(item);
    FocusScope.of(context).requestFocus(_focusNode);
    widget.onChanged(_selectedItems.cast<T>());
  }

  List<T> _removeSelectedItems() {
    final items = [...widget.items];
    for (var i = 0; i < _selectedItems.length; i++) {
      items.remove(_selectedItems[i]);
    }
    return items;
  }

  void _searchFilter() {
    List<T> items = [..._availableItems];

    final itemsMap = jsonDecode(jsonEncode(items));

    List<T> filteredItems = [];
    for (var i = 0; i < _availableItems.length; i++) {
      if (itemsMap[i][widget.chipLabelKey]
          .toString()
          .toLowerCase()
          .contains(_controller.text.toLowerCase())) {
        filteredItems.add(_availableItems[i]);
      }
    }

    _listViewItems.value = filteredItems;
  }
}
