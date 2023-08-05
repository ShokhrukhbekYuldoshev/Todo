import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:todo/data/models/todo.dart';
import 'package:todo/data/services/database.dart';

class TodoFormPage extends StatefulWidget {
  final Todo? todo;
  const TodoFormPage({Key? key, this.todo}) : super(key: key);

  @override
  State<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.todo?.title,
  );
  late final _descriptionController = TextEditingController(
    text: widget.todo?.description,
  );
  late final _dueAtController = TextEditingController(
    text: widget.todo?.dueAt?.toIso8601String(),
  );
  late final _priorityController = TextEditingController(
    text: widget.todo?.priority.name.capitalize ?? 'Low',
  );
  // color picker
  late Color _color = widget.todo?.color ?? Colors.deepPurple;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueAtController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'New Todo' : 'Edit Todo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    minLines: 1,
                  ),
                  const SizedBox(height: 16),
                  // due at
                  TextFormField(
                    controller: _dueAtController,
                    decoration: const InputDecoration(
                      labelText: 'Due At',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        _dueAtController.text = date.toIso8601String();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // priority
                  TextFormField(
                    readOnly: true,
                    controller: _priorityController,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final priority = await showDialog<TodoPriority>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Select Priority'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  ListTile(
                                    title: const Text('Low'),
                                    onTap: () {
                                      Navigator.pop(context, TodoPriority.low);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Medium'),
                                    onTap: () {
                                      Navigator.pop(
                                          context, TodoPriority.medium);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('High'),
                                    onTap: () {
                                      Navigator.pop(context, TodoPriority.high);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      if (priority != null) {
                        _priorityController.text = priority.name.capitalize;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // color picker
                  Ink(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _color,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () async {
                        Color? color;
                        await showDialog<Color>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  color: _color,
                                  onColorChanged: (Color value) {
                                    color = value;
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    color = null;
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, _color);
                                  },
                                  child: const Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                        if (color != null) {
                          setState(() {
                            _color = color!;
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (widget.todo != null) {
                final todo = widget.todo!.copyWith(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  color: _color,
                  updatedAt: DateTime.now(),
                  dueAt: DateTime.tryParse(_dueAtController.text),
                  priority: todoPriorityFromName(
                    _priorityController.text.trim().toLowerCase(),
                  ),
                );
                int id = await DB.updateById(
                  'todos',
                  todo.toMap(),
                  todo.id!,
                );
                if (mounted) {
                  todo.id = id;
                  Navigator.pop(context, todo);
                }
                return;
              }

              final todo = Todo(
                title: _titleController.text,
                description: _descriptionController.text,
                color: _color,
                completed: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                dueAt: DateTime.tryParse(_dueAtController.text),
                completedAt: null,
                priority: todoPriorityFromName(
                  _priorityController.text.trim().toLowerCase(),
                ),
              );
              int id = await DB.insert('todos', todo.toMap());
              if (mounted) {
                todo.id = id;
                Navigator.pop(context, todo);
              }
            }
          },
          child: const Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
