import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media/productForm.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      String apiUrl = "https://spotit.cloud/interview/api/login";
      String email = emailController.text;
      String password = passwordController.text;

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            "email": email,
            "password": password,
          },
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData['status'] == true) {
            String token = responseData['data']['token'];
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CreateProductPage(token: token),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  "Login failed: ${responseData['message']}",
                ),
              ),
            );
          }
        } else if (response.statusCode == 400) {
          Map<String, dynamic> errorResponse = json.decode(response.body);
          String errorMessage = errorResponse['message'] ?? "";
          Map<String, dynamic> errors = errorResponse['errors'] ?? {};

          setState(() {});

          print(". Status code: 400");
          print("Error Message: $errorMessage");
          print("Errors: $errors");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(" $errorMessage"),
            ),
          );
        } else {
          print("Login failed. Status code: ${response.statusCode}");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login failed: Unknown error occurred"),
            ),
          );
        }
      } catch (e) {
        // ignore: unnecessary_null_comparison
        if (e != null) {
          print("Network error: $e");
        } else {
          print("Network error: Unknown error occurred");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network error: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/login.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 52),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "E-Mail",
                      suffixIcon: Icon(Icons.email,
                      color: Colors.grey,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 25),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ForgotPasswordDialog();
                            },
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 52),
                  ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      minimumSize: Size(400, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ForgotPasswordDialog extends StatelessWidget {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Forgot Password"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Please enter your email to reset your password."),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your email';
              } else if (!value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Submit"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
