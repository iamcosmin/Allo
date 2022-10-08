import 'package:allo/components/empty.dart';
import 'package:allo/logic/client/extensions.dart';
import 'package:flutter/material.dart';

class TileHeading extends StatelessWidget {
  const TileHeading(this.heading, {super.key});
  final String heading;
  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: Text(
        heading,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}

class TileCard extends StatelessWidget {
  const TileCard(this.children, {this.startFromIndex, super.key});
  final List<Widget> children;
  final int? startFromIndex;

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        shadowColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            type: MaterialType.transparency,
            child: SeparatedColumn(
              separatorBuilder: (context, index) {
                if (startFromIndex == null || index >= startFromIndex!) {
                  return Divider(
                    height: 1,
                    thickness: 2,
                    color: context.colorScheme.surface,
                  );
                } else {
                  return const Empty();
                }
              },
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class SeparatedColumn extends StatelessWidget {
  final List<Widget> children;
  final TextBaseline? textBaseline;
  final bool includeOuterSeparators;
  final TextDirection? textDirection;
  final MainAxisSize mainAxisSize;
  final VerticalDirection verticalDirection;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final IndexedWidgetBuilder separatorBuilder;

  const SeparatedColumn({
    required this.separatorBuilder,
    super.key,
    this.textBaseline,
    this.textDirection,
    this.children = const <Widget>[],
    this.includeOuterSeparators = false,
    this.mainAxisSize = MainAxisSize.max,
    this.verticalDirection = VerticalDirection.down,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final index = includeOuterSeparators ? 1 : 0;

    if (this.children.isNotEmpty) {
      if (includeOuterSeparators) {
        children.add(separatorBuilder(context, 0));
      }

      for (var i = 0; i < this.children.length; i++) {
        children.add(this.children[i]);

        if (this.children.length - i != 1) {
          children.add(separatorBuilder(context, i + index));
        }
      }

      if (includeOuterSeparators) {
        children.add(separatorBuilder(context, this.children.length));
      }
    }

    return Column(
      key: key,
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
