// ignore_for_file: library_private_types_in_public_api
import 'auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    // Listen for authentication state changes
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      // User is signed out
      print('User is signed out');
    } else {
      // User is signed in
      print('User is signed in');
    }
  });

  runApp(const TodoApp());
}

enum TaskPriority { high, medium, low }


class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      home: const StartPage(),
      routes: {
        '/todoList': (context) => const TodoList(),
      },
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  _StartPageState createState() => _StartPageState();

}

class _StartPageState extends State<StartPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

   Future<String?> _getEmailFromUser() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Email'),
          content: TextField(
            controller: _emailController,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(_emailController.text),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

   Future<String?> _getPasswordFromUser() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(_passwordController.text),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200, // Define the width here
              child: ElevatedButton(
                onPressed: () async {
                // Show a dialog or navigate to a new screen to get email and password
                  String? email = await _getEmailFromUser();
                  String? password = await _getPasswordFromUser();

                  if (email != null && password != null) {
                    try {
                      await _authService.signInWithEmailAndPassword(email, password);
                      Navigator.of(context).pushReplacementNamed('/todoList');
                      // Handle successful login
                    } catch (e) {
                      // Handle login error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Login failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          )
                        );
                    }
                  }
                },
                child: const Text('Login'),
              ),
            ),
            const SizedBox(height: 8), // Optional spacing between buttons
            SizedBox(
              width: 200, // Same width for consistency
              child: ElevatedButton(
                  onPressed: () async {
                    String? email = await _getEmailFromUser();  // Reuse the existing method to get email
                    String? password = await _getPasswordFromUser();  // Reuse the existing method to get password

                    if (email != null && password != null) {
                      try {
                        await _authService.createUserWithEmailAndPassword(email, password);
                        Navigator.of(context).pushReplacementNamed('/todoList');  // Navigate to Todo list on successful registration
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Registration failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          )
                        );
                      }
                    }
                  },
                child: const Text('Register'),
              ),
            ),
            const SizedBox(height: 8), // Optional spacing between buttons
            SizedBox(
              width: 200, // Same width for consistency
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/todoList');
                },
                child: const Text('Chore List'),
              ),
            ),
            const SizedBox(height: 8), // Optional spacing between buttons
            SizedBox(
              width: 200, // Same width for consistency
              child: ElevatedButton(
                onPressed: () {
                  // Add contact functionality
                },
                child: const Text('Contact Us'),
              ),
            ),
            SizedBox(
              width: 200, // Same width for consistency
              child: ElevatedButton(
                onPressed: () async {
                  await _authService.signOut();
                  // Handle sign-out
                },
                child: const Text('Sign Out'),
              ),
            )
          ],
        ),
      ),
    );
  }

}


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