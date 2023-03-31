import 'package:flutter/material.dart';

class TextWithTooltip extends StatelessWidget {
  const TextWithTooltip({super.key, required this.text, required this.tooltip});
  final String text;
  final String tooltip;
  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Text(text),
      Tooltip(
        preferBelow: false,
        message: tooltip,
        triggerMode: TooltipTriggerMode.tap,
        child: const Icon(
          Icons.help,
          size: 12,
          color: Colors.grey,
        ),
      ),
    ]);
  }
}
