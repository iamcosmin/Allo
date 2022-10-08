import 'package:allo/components/photo.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PersonPicture extends HookConsumerWidget {
  final double radius;
  final String initials;
  final String? profilePicture;

  const PersonPicture({
    required this.initials,
    required this.profilePicture,
    required this.radius,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipOval(
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        color: Theme.of(context).colorScheme.surfaceVariant,
        duration: const Duration(milliseconds: 250),
        key: key,
        height: radius,
        width: radius,
        alignment: Alignment.center,
        child: Center(
          child: _child(context),
        ),
      ),
    );
  }

  Widget _child(BuildContext context) {
    if (profilePicture != null && profilePicture != '') {
      return Photo(
        url: profilePicture!,
        placeholder: AnimatedContainer(
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 250),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            initials,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: radius / 2,
            ),
          ),
        ),
        errorBuilder: (context, error, stacktrace) {
          return AnimatedContainer(
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 250),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              initials,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: radius / 2,
              ),
            ),
          );
        },
      );
    } else {
      return Text(
        initials,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: radius / 2,
        ),
      );
    }
  }
}
