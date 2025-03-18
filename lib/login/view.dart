import 'package:flutter/material.dart';
import 'package:mri/custom_alert/custom_alert.dart';
import 'package:mri/data/user/user_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  login(username, password) async {
    //check if username and password are not empty
    if (!username.isNotEmpty && !password.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomAlert(
            title: 'Warning !',
            message: 'Username and Password cannot be empty',
            icon: Icons.warning,
            iconColor: Colors.yellow,
            titleColor: Colors.black,
            messageColor: Colors.black54,
            backgroundColor: Colors.white,
          );
        },
      );
    }

    await UserRepository().login(username, password).then((userDetails) {
      //navigate to home page
      if (userDetails.userId.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/material-issue-note');
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return const CustomAlert(
              title: 'Error WE!',
              message: 'Invalid username or password',
              icon: Icons.error,
              iconColor: Colors.red,
              titleColor: Colors.black,
              messageColor: Colors.black54,
              backgroundColor: Colors.white,
            );
          },
        );
      }
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlert(
            title: 'Error !',
            message: error.toString(),
            icon: Icons.error,
            iconColor: Colors.red,
            titleColor: Colors.black,
            messageColor: Colors.black54,
            backgroundColor: Colors.white,
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Login',
            style: TextStyle(color: Colors.black, fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text;
                String password = _passwordController.text;
                login(username, password);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text(
                'Don\'t have a login? Register',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
