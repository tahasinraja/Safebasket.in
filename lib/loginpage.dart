import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:safbasketapp/homepage.dart';

import 'package:safbasketapp/mainhome.dart';
import 'package:safbasketapp/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
Future<void> saveloginstutas(bool isLoggedIn, String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', isLoggedIn);
  await prefs.setString('User_id', userId);
  print('✅ Login status saved! User ID: $userId');
}
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  // 🔹 Replace with your backend API URL
  final String apiUrl = 'https://safebasket.in/app/login_check.php';

 Future<void> loginUser() async {
  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ph': usernameController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );

    print('📡 Sending login request...');
    print('➡️ Body: ${jsonEncode({
      'ph': usernameController.text.trim(),
      'password': passwordController.text.trim(),
    })}');
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
  // ✅ Extract correct user_id and phone from nested "result"
  final userId = data['result']['user_id'] ?? '';
  final ph = data['result']['ph'] ?? '';

  print('✅ Extracted user_id: $userId');
  print('✅ Extracted phone: $ph');

  // ✅ Save both values
  await saveloginstutas(true, userId);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('ph', ph);

  print('✅ Login status saved! User ID: $userId, Phone: $ph');


        // ✅ Save login status and user ID
        await saveloginstutas(true, userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Login successful!')),
        );

        // ✅ Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomePage()),
        );
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Invalid credentials';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Server error: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Network error: $e';
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 12,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fastfood, color: Colors.redAccent, size: 64),
                const SizedBox(height: 12),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to continue ordering your favorite food 🍔',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // 🔹 Username
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username/Mobile No.',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔹 Password
          // 🔹 Password
                PinCodeTextField(appContext: context, 
                controller: passwordController,
                length: 4,
                obscureText: true,
                keyboardType: TextInputType.number,
                obscuringCharacter: '🔐',
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 55,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey,
                  
                ),
                ),
                const SizedBox(height: 20),

                // 🔹 Error message
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 16),

                // 🔹 Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Forgot Password / Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?'),
                    ),
                      TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(),));
                      },
                      child: const Text('Home'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
