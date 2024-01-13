/*
Name:Nur Siti Dahlia S62584
Program: implementation of sign up screen
*/

import 'package:flutter/material.dart';
import 'login_screen.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
          'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
          'project-monitor-app.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _nameController.text,
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          
          Image.asset(
            'images/bg4.png', 
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(35.0, 200.0, 35.0, 35.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create New Account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, 
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildCircularRectangleTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                    ),
                    SizedBox(height: 20),
                    _buildCircularRectangleTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                    ),
                    SizedBox(height: 20),
                    _buildCircularRectangleTextField(
                      controller: _emailController,
                      labelText: 'Email',
                    ),
                    SizedBox(height: 20),
                    _buildCircularRectangleTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _saveItem();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(199, 1, 37, 138),
                        onPrimary: Colors.white,
                        minimumSize: Size(160, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularRectangleTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.black54),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      style: TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }
}
