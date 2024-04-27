// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'To-Do App',
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class TodoItem {
  String title;
  bool completed;

  TodoItem({required this.title, this.completed = false});
}

class _TodoListState extends State<TodoList> {
  final List<TodoItem> _todoItems = [];


void _addTodoItem(String task) {
  if (task.isNotEmpty) {
    setState(() {
      _todoItems.add(TodoItem(title: task));
    });
  }
}


Widget _buildTodoList() {
  return ListView.builder(
    itemCount: _todoItems.length,
    itemBuilder: (context, index) {
      return _buildTodoItem(_todoItems[index], index);
    },
  );
}


Widget _buildTodoItem(TodoItem item, int index) {
  return Dismissible(
    key: Key(item.title + index.toString()),
    background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20.0), child: const Icon(Icons.delete, color: Colors.white)),
    direction: DismissDirection.endToStart,
    confirmDismiss: (direction) async {
      return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete")
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel")
              ),
            ],
          );
        },
      );
    },
    onDismissed: (direction) {
      _removeTodoItem(index);
    },
    child: ListTile(
      title: Text(
        item.title,
        style: TextStyle(
          decoration: item.completed ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      trailing: Checkbox(
        value: item.completed,
        onChanged: (bool? checked) {
          setState(() {
            item.completed = checked!;
          });
        },
      ),
      onTap: () {
        _pushAddEditTodoScreen(initialTask: item.title, index: index);
      },
    ),
  );
}


void _pushAddEditTodoScreen({String? initialTask, int? index}) {
  TextEditingController textEditingController = TextEditingController(text: initialTask);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text(initialTask == null ? 'Add a new task' : 'Edit task')),
          body: TextField(
            controller: textEditingController,
            autofocus: true,
            onSubmitted: (val) {
              if (index == null) {
                _addTodoItem(val);
              } else {
                _updateTodoItem(index, val);
              }
              Navigator.pop(context);
            },
            decoration: const InputDecoration(
              hintText: 'Enter something to do...',
              contentPadding: EdgeInsets.all(16.0)
            ),
          ),
        );
      },
    ),
  );
}




void _removeTodoItem(int index) {
  setState(() {
    _todoItems.removeAt(index);
  });
}

void _updateTodoItem(int index, String newTask) {
  setState(() {
    if (newTask.isNotEmpty) {
      _todoItems[index].title = newTask;
    }
  });
}



  void _pushAddTodoScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add a new task')),
            body: TextField(
              autofocus: true,
              onSubmitted: (val) {
                _addTodoItem(val);
                Navigator.pop(context); // Close the add todo screen
              },
              decoration: const InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: EdgeInsets.all(16.0)
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To Do List')),
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pushAddEditTodoScreen(),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),

    );
  }
}
