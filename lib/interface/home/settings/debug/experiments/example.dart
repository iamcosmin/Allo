import 'package:flutter/material.dart' hide SliverAppBar;

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  Widget buildFakeAvatar() {
    return ClipOval(
      child: Container(
        color: Colors.grey.shade600,
        height: 50,
        width: 50,
        padding: const EdgeInsets.all(10),
        child: const FlutterLogo(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.lightBlue),
          trackColor: MaterialStateProperty.all(Colors.lightBlue.shade700),
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Admin Rights'),
          actions: [
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () => {},
            )
          ],
        ),
        body: ListView(
          children: [
            ListTile(
              leading: buildFakeAvatar(),
              title: const Text('cosmoon'),
              subtitle: const Text('has no access to messages'),
              tileColor: Colors.grey.shade900,
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            ColoredBox(
              color: Colors.grey.shade900,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Text('What can this bot do?'),
                  ),
                  SwitchListTile(
                    value: true,
                    // ignore: avoid_returning_null_for_void
                    onChanged: (_) => null,
                    title: const Text('Change Group Info'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
