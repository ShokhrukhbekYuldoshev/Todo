import 'package:flutter/material.dart';
import 'package:todo/data/services/database.dart';
import 'package:todo/presentation/pages/todo_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoListPage(),
    );
  }
}
