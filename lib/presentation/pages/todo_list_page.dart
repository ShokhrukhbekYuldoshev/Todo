import 'package:flutter/material.dart';
import 'package:todo/data/models/todo.dart';
import 'package:todo/data/services/database.dart';
import 'package:todo/presentation/pages/todo_form_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  void fetchTodos() async {
    final todos = await DB.query('todos');
    setState(() {
      _todos = todos.map((e) => Todo.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TodoFormPage(),
            ),
          );
          if (result != null) {
            setState(() {
              _todos.add(result as Todo);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) {
            final todo = _todos[index];
            return Dismissible(
              background: Container(
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              key: Key(todo.id.toString()),
              onDismissed: (direction) async {
                await DB.deleteById(
                  'todos',
                  todo.id!,
                );
                setState(() {
                  _todos.removeAt(index);
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${todo.title} deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await DB.insert('todos', todo.toMap());
                          setState(() {
                            _todos.insert(index, todo);
                          });
                        },
                      ),
                    ),
                  );
                }
              },
              child: ListTile(
                onTap: () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TodoFormPage(
                        todo: todo,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _todos[index] = result as Todo;
                    });
                  }
                },
                leading: CircleAvatar(
                  backgroundColor: todo.color,
                  child: Text(
                    todo.title[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  todo.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  todo.description == null || todo.description!.isEmpty
                      ? 'No description'
                      : todo.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Checkbox(
                  value: todo.completed,
                  onChanged: (value) async {
                    final updatedTodo = todo.copyWith(
                      completed: value!,
                      completedAt: value ? DateTime.now() : null,
                    );
                    await DB.updateById(
                      'todos',
                      updatedTodo.toMap(),
                      updatedTodo.id!,
                    );
                    setState(() {
                      _todos[index] = updatedTodo;
                    });
                  },
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: _todos.length,
        ),
      ),
    );
  }
}
