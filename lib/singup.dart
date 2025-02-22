import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore added
import 'package:scootrusl/homescreen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _universityController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _isSignUp = false; // Toggle between sign-up and login

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _authenticate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential;
      if (_isSignUp) {
        // Sign-up logic
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Store user data in Firestore
        final userRef = FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid);
        await userRef.set({
          'uid': userCredential.user?.uid,
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'name': _regNumberController.text.trim(),
          'reg_number': _universityController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(), // Store user creation timestamp
        });

        print('User signed up: ${userCredential.user?.email}');
      } else {
        // Login logic
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print('User logged in: ${userCredential.user?.email}');
      }

      // Navigate to the home screen after authentication success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Home()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred, please try again.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak. Please use a stronger password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard when tapping outside
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            height: MediaQuery.of(context).size.height,
             width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.cyan],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Row(
                  children: [
                    TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text(
                        _isSignUp ? 'Log in' : 'Sign up',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                    Spacer(),
                    Text(
                      _isSignUp ? 'Sign Up' : 'Log In',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_isSignUp) ...[
                        TextField(
                          controller: _regNumberController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _universityController,
                          decoration: InputDecoration(
                            labelText: 'Reg Number',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone number',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _authenticate,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.blue,
                              ),
                              child: Text(
                                _isSignUp ? 'Sign Up' : 'Log In',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                      SizedBox(height: 10),
                      if (!_isSignUp)
                        TextButton(
                          onPressed: _toggleAuthMode,
                          child: Text('Don\'t have an account? Sign up here'),
                        ),
                      if (_isSignUp)
                        TextButton(
                          onPressed: _toggleAuthMode,
                          child: Text('Already have an account? Log in here'),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // Adjust for keyboard
              ],
            ),
          ),
        ),
      ),
    );
  }
}
