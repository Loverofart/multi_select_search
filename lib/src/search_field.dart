import 'package:flutter/material.dart';

/// A text field to search item from the list
class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
    this.onTap,
    this.stepWidth,
    this.onChanged,
    this.decoration,
    required this.focusNode,
    required this.controller,
  }) : super(key: key);

  final double? stepWidth;
  final FocusNode focusNode;
  final GestureTapCallback? onTap;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      stepWidth: stepWidth,
      child: TextField(
        scrollPadding: EdgeInsets.zero,
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 2,
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        onChanged: (newValue) {
          onChanged!(newValue);
        },
        focusNode: focusNode,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        onTap: onTap,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        decoration: decoration ??
            const InputDecoration(
              hintText: 'Search here..',
              border: InputBorder.none,
            ),
        cursorHeight: 20,
      ),
    );
  }
}
