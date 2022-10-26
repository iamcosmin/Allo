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
  ColorScheme? colorScheme,
}) {
  FocusScope.of(context).unfocus();
  final colors = colorScheme ?? Theme.of(context).colorScheme;
  return showModalBottomSheet(
    isScrollControlled: insets != null ? true : false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    ),
    backgroundColor: colors.surface,
    context: context,
    builder: (context) {
      if (insets != null) {
        return DraggableScrollableSheet(
          initialChildSize: insets.initialChildSize,
          minChildSize: insets.minChildSize,
          maxChildSize: insets.maxChildSize,
          expand: false,
          builder: (context, controller) {
            return SafeArea(
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 15, bottom: 20),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
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
              ),
            );
          },
        );
      } else {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(padding: EdgeInsets.only(top: 10)),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 15, bottom: 20),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
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
          ),
        );
      }
    },
  );
}
