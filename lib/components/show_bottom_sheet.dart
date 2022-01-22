import 'package:flutter/material.dart';

// We should expand the sheet only if the children size exceeds half of the screen size.

/// ScrollableInsets is a helper tool for DraggableScrollableSheet.
class ScrollableInsets {
  const ScrollableInsets({
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
  });
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
}

Future<dynamic> showMagicBottomSheet({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  ScrollableInsets? insets,
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet(
    isScrollControlled: insets != null ? true : false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (context) {
      if (insets != null) {
        return DraggableScrollableSheet(
          initialChildSize: insets.initialChildSize,
          minChildSize: insets.minChildSize,
          maxChildSize: insets.maxChildSize,
          expand: false,
          builder: (context, controller) {
            return Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 10)),
                Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 20),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => children[index],
                      itemCount: children.length,
                      controller: controller,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.only(top: 10)),
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey
                    : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 15, bottom: 20),
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: children,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
            ),
          ],
        );
      }
    },
  );
}
