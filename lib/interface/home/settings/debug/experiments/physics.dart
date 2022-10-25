import 'package:allo/components/chat/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PhysicsCardDragDemo extends HookWidget {
  const PhysicsCardDragDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final subtitle = useState('Welcome to this subtitle!');
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChatTile(
            leading: const SizedBox(height: 50, width: 50),
            title: const Text('Hello!'),
            subtitle: Text(subtitle.value),
            index: -1,
          ),
          const Padding(padding: EdgeInsets.all(10)),
          ElevatedButton(
            onPressed: () => subtitle.value = 'Here is another value!',
            child: const Text('Change value'),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          ElevatedButton(
            onPressed: () => subtitle.value = 'The value has been reset!',
            child: const Text('Reset value'),
          ),
        ],
      ),
    );
  }
}
