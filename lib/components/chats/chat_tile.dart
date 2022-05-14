import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onTap(),
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
                  children: [title, subtitle],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
