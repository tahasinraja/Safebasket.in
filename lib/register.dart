import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safbasketapp/loginpage.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  final String apiUrl = 'https://safebasket.in/app/create_profile.php';

Future<void> registerUser() async {
  final name = nameController.text.trim();
  final ph = phController.text.trim();
  final password = passwordController.text.trim();

  // 🧠 Basic validation
  if (name.isEmpty || ph.isEmpty || password.isEmpty) {
    setState(() => errorMessage = 'Please fill all fields');
    return;
  }

  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    // 🔹 Generate unique user ID
    String uniqueUserId = 'U${DateTime.now().millisecondsSinceEpoch}';

    print('🟢 Registering new user...');
    print('➡️ User ID: $uniqueUserId');
    print('➡️ Name: $name');
    print('➡️ Phone: $ph');
    print('➡️ Password: $password');

    // 🔹 Try POST first
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'user_id': uniqueUserId,
        'name': name,
        'ph': ph,
        'password': password,
      },
    );

    // 🔁 Fallback to GET if POST fails
    if (response.statusCode != 200 || response.body.contains('Missing required fields')) {
      print('⚠️ POST failed, trying GET...');
      final getResponse = await http.get(
        Uri.parse(
          '$apiUrl?user_id=$uniqueUserId&name=$name&ph=$ph&password=$password',
        ),
      );
      response = getResponse;
    }

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // ✅ Save user info locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('User_id', uniqueUserId);
        await prefs.setString('ph', ph);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );

        // 🔹 Navigate to Login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  LoginPage()),
        );
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Registration failed';
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
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join us and start ordering your favorite meals 😋',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // 🔹 Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Phone
                TextField(
                  controller: phController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile No.',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Password (4-digit PIN)
                PinCodeTextField(
                  appContext: context,
                  controller: passwordController,
                  length: 4,
                  obscureText: true,
                  obscuringCharacter: '●',
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 55,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.grey.shade200,
                    selectedFillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 16),

                // 🔹 Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
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
                            'Register',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.redAccent),
                      ),
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
