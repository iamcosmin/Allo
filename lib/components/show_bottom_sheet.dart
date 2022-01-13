import 'package:flutter/material.dart';

Future<dynamic> showMagicBottomSheet({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  double initialChildSize = 0.4,
  double? minChildSize,
  double? maxChildSize,
}) {
  assert(initialChildSize <= 1.0,
      'The initial child size should be smaller than 1.0.');
  return showModalBottomSheet(
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize ?? initialChildSize,
      maxChildSize: maxChildSize ?? initialChildSize,
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
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: ListView(
                  controller: controller,
                  children: children,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
