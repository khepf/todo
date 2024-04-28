// ignore_for_file: library_private_types_in_public_api
import 'auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'todo_list.dart'; 
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
                  // Add contact functionality
                },
                child: const Text('Contact Us'),
              ),
            )
          ],
        ),
      ),
    );
  }

}

