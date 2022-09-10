import 'dart:math';

import 'package:allo/components/material3/switch-own.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

int _createUniqueID() {
  final random = Random();
  return random.nextInt(AwesomeNotifications.maxID);
}

String? randomIcon() {
  final random = Random();
  final icons = [
    null,
    'https://firebasestorage.googleapis.com/v0/b/allo-ms.appspot.com/o/profilePictures%2Fq9zUNtLfikYnfdmAR9xajg1fXFL2.png?alt=media&token=d2cb3b7d-4341-4027-8385-e355fe146836',
    'https://firebasestorage.googleapis.com/v0/b/allo-ms.appspot.com/o/profilePictures%2Fq9zUNtLfikYnfdmAR9xajg1fXFL2.png?alt=media&token=d2cb3b7d-4341-4027-8385-e355fe146836',
    'https://firebasestorage.googleapis.com/v0/b/allo-ms.appspot.com/o/profilePictures%2Fq9zUNtLfikYnfdmAR9xajg1fXFL2.png?alt=media&token=d2cb3b7d-4341-4027-8385-e355fe146836',
    'https://firebasestorage.googleapis.com/v0/b/allo-ms.appspot.com/o/profilePictures%2Fq9zUNtLfikYnfdmAR9xajg1fXFL2.png?alt=media&token=d2cb3b7d-4341-4027-8385-e355fe146836',
    null,
    null,
    null,
  ];
  final number = random.nextInt(icons.length - 1);
  return icons[number];
}

class TestNotificationsPage extends HookConsumerWidget {
  const TestNotificationsPage({super.key});

  @override
  Widget build(context, ref) {
    final name = useState('');
    final chat = useState('');
    final message = useState('');
    final genGroupKey = useState(Random().nextInt(100).toString());
    final group = useState(false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Chat',
              ),
              onChanged: (value) => chat.value = value,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Name',
              ),
              onChanged: (value) => name.value = value,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'GroupKey',
              ),
              onChanged: (value) => genGroupKey.value = value,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Message',
              ),
              onChanged: (value) => message.value = value,
            ),
            ListTile(
              title: const Text('Messaging Group'),
              trailing: AdaptiveSwitch(
                value: group.value,
                onChanged: (_) => group.value = _,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: _createUniqueID(),
              channelKey: 'chats',
              groupKey: genGroupKey.value,
              roundedLargeIcon: true,
              largeIcon: randomIcon(), // User name
              title: name.value,
              notificationLayout: group.value
                  ? NotificationLayout.MessagingGroup
                  : NotificationLayout.Messaging,
              category: NotificationCategory.Message,
              summary: group.value ? chat.value : '',
              // Group name kinda.
              body: message.value,
            ),
          );
        },
        label: const Text('Send Notification'),
      ),
    );
  }
}
