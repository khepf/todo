import 'package:flutter/material.dart';
import 'auth_service.dart';

enum TaskPriority { high, medium, low }

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}


class _TodoListState extends State<TodoList> {
  final List<TodoItem> _todoItems = [];
  final AuthService _authService = AuthService();
  TaskPriority selectedPriority = TaskPriority.low;
  TaskPriority? _currentTaskPriority;

void _updateSelectedPriority(TaskPriority newPriority) {
  setState(() {
    selectedPriority = newPriority;
  });
}


void _addTodoItem(String task) {
  if (task.isNotEmpty) {
    setState(() {
      _todoItems.add(TodoItem(title: task, priority: _currentTaskPriority!));
    });
  }
}

void _updateTodoItem(int index, String newTask) {
  if (newTask.isNotEmpty) {
    setState(() {
      _todoItems[index].title = newTask;
      _todoItems[index].priority = _currentTaskPriority!;
    });
  }
}

String _getPriorityText(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return 'High';
    case TaskPriority.medium:
      return 'Medium';
    case TaskPriority.low:
      return 'Low';
  }
}


Widget _buildTodoList() {
  // Sort tasks by priority: high, medium, then low
  var sortedItems = List<TodoItem>.from(_todoItems);
  sortedItems.sort((a, b) => b.priority.index.compareTo(a.priority.index));

  return ListView.builder(
    itemCount: sortedItems.length,
    itemBuilder: (context, index) {
      return _buildTodoItem(sortedItems[index], index);
    },
  );
}

Widget _buildTodoItem(TodoItem item, int index) {
  return Dismissible(
    key: Key(item.title + index.toString()),
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
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
                child: const Text("Delete"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
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
      title: Text(item.title),
      subtitle: Text(_getPriorityText(item.priority)), // Display priority text
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: item.completed,
            onChanged: (bool? checked) {
              setState(() {
                item.completed = checked!;
              });
            },
          ),
        ],
      ),
      onTap: () {
        _pushAddEditTodoScreen(initialTask: item.title, index: index, initialPriority: item.priority);
      },
    ),
  );
}

void _pushAddEditTodoScreen({String? initialTask, int? index, TaskPriority? initialPriority}) {
  TextEditingController textEditingController = TextEditingController(text: initialTask);

  // Set _currentTaskPriority to initialPriority if provided, or TaskPriority.low
  _currentTaskPriority = initialPriority ?? TaskPriority.low;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text(initialTask == null ? 'Add a new task' : 'Edit task')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: textEditingController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter something to do...',
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButton<TaskPriority>(
                  value: _currentTaskPriority,
                  onChanged: (TaskPriority? newValue) {
                    setState(() {
                      _currentTaskPriority = newValue;
                    });
                  },
                  items: TaskPriority.values.map((TaskPriority priority) {
                    return DropdownMenuItem<TaskPriority>(
                      value: priority,
                      child: Text(priority.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newTask = textEditingController.text;
                    if (index == null) {
                      _addTodoItem(newTask);
                    } else {
                      _updateTodoItem(index, newTask);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(initialTask == null ? 'Add Task' : 'Update Task'),
                )
              ],
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
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
    ),
  );
}

}

class TodoItem {
    String title;
  bool completed;
  TaskPriority priority;

  TodoItem({required this.title, this.completed = false, this.priority = TaskPriority.low});
}