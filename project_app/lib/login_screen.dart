/*
Name:Nur Siti Dahlia S62584
Program: implementation of login screen
*/

import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userid = "";
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  void _signIn(BuildContext context) async {
    final url = Uri.https(
      'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'project-monitor-app.json',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      print('Fetched data: $data');

      final username = _usernameController.text;
      final password = _passwordController.text;

     
      if (data.values.any((user) => user['username'] == username && user['password'] == password)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: username),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid username or password. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('Failed to fetch data. HTTP Status Code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch data. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(199, 1, 37, 138),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80.0),
                ),
              ),
              padding: EdgeInsets.fromLTRB(100.0, 100.0, 100.0, 50.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'NovaPlan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Let's Track & Manage",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 75),
                  ],
                ),
              ),
            ),
            SizedBox(height: 58),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(.0),
                ),
              ),
              padding: EdgeInsets.all(45.0),
              child: Form(
                key: _formKey, 
                child: Column(
                  children: [
                    _buildCircularRectangleTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                    ),
                    SizedBox(height: 17),
                    _buildCircularRectangleTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: !_isPasswordVisible,
                      trailingIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final usernameError = _validateUsername(_usernameController.text);
                          final passwordError = _validatePassword(_passwordController.text);

                          if (usernameError == null && passwordError == null) {
                            _signIn(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(usernameError ?? passwordError ?? 'Please enter valid credentials'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(199, 1, 37, 138),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Sign up here',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 90),
            Text(
              '© 2023 S62584. All rights reserved.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularRectangleTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    Widget? trailingIcon,
  }) {
    return Container(
      width: 300,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 142, 204, 255),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                color: Colors.grey,
              ),
              border: InputBorder.none,
            ),
        
          ),
        ),
        trailing: trailingIcon,
      ),
    );
  }
}
