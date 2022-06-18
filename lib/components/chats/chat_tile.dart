import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../space.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.index,
    this.onTap,
    super.key,
  });
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final int index;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 275),
      child: SlideAnimation(
        verticalOffset: 30,
        child: FadeInAnimation(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Container(
                height: 65,
                padding: const EdgeInsets.only(left: 5, right: 5),
                margin: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Container(
                      child: leading,
                    ),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, const Space(0.1), subtitle],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
