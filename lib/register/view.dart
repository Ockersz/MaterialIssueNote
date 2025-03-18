import 'package:flutter/material.dart';
import 'package:mri/custom_alert/custom_alert.dart';
import 'package:mri/data/user/user_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  static const String routeName = '/register';

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  register(
      {required String username,
      required String password,
      required String confirmPassword}) async {
    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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
      return;
    }

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomAlert(
            title: 'Warning !',
            message: 'Passwords do not match',
            icon: Icons.warning,
            iconColor: Colors.yellow,
            titleColor: Colors.black,
            messageColor: Colors.black54,
            backgroundColor: Colors.white,
          );
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await UserRepository().register(username, password).then((userDetails) {
      if (userDetails.userId.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return const CustomAlert(
              title: 'Success !',
              message: 'Registration successful',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              titleColor: Colors.black,
              messageColor: Colors.black54,
              backgroundColor: Colors.white,
            );
          },
        ).then((value) {
          Navigator.pushNamed(context, '/login');
        });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return const CustomAlert(
              title: 'Error',
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
            title: 'Error',
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Register',
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
          children: <Widget>[
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
              obscureText: _obscureText,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _isLoading
                    ? null
                    : register(
                        username: _usernameController.text,
                        password: _passwordController.text,
                        confirmPassword: _confirmPasswordController.text,
                      );
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
                  'Register',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Go back to login',
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
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
