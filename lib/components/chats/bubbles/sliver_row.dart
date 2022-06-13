import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SliverRow extends StatelessWidget {
  const SliverRow({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    super.key,
  });

  final List<SliverRowChildDelegate> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (var child in children)
            if (child.rowBuilder != null)
              child.rowBuilder!(
                context,
                ShrinkWrappingViewport(
                  slivers: child.slivers,
                  offset: ViewportOffset.zero(),
                ),
              )
            else
              ShrinkWrappingViewport(
                slivers: child.slivers,
                offset: ViewportOffset.zero(),
              ),
        ],
      ),
    );
  }
}

class SliverRowChildDelegate {
  final List<Widget> slivers;
  final RenderRow? rowBuilder;

  SliverRowChildDelegate(this.slivers, {this.rowBuilder});
}

typedef RenderRow = Widget Function(BuildContext context, Widget child);
