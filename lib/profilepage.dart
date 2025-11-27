import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safbasketapp/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }
  
//update profile
Future<void> updateProfile() async {
  final updateUrl = Uri.parse('https://safebasket.in/app/update_profile.php');

  try {
    print('🟡 Step 1️⃣: Preparing to update profile...');
    print('🟡 Checking User ID...');
    if (userId == null || userId!.isEmpty) {
      print('❌ ERROR: User ID not found in SharedPreferences');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ User ID not found. Please login again.')),
      );
      return;
    }

    print('🟢 Step 2️⃣: User ID found → $userId');
    print('🟢 Preparing body data...');

    final Map<String, String> bodyData = {
      'user_id': userId!, // ✅ must be uppercase "U"
      'name': userData?['name'] ?? '',
      'email': userData?['email'] ?? '',
      'alt_ph': userData?['alt_ph'] ?? '',
     // 'password': userData?['password'] ?? '',
      'gender': userData?['gender'] ?? '',
      'dob': userData?['dob'] ?? '',
      'fulladdress': userData?['fulladdress'] ?? '',
      'city': userData?['city'] ?? '',
    //  'post': userData?['post'] ?? '',
     // 'policestation': userData?['policestation'] ?? '',
      'district': userData?['district'] ?? '',
      'state': userData?['state'] ?? '',
      'country': userData?['country'] ?? '',
      'pincode': userData?['pincode'] ?? '',
    };

    print('📦 Step 3️⃣: POST Body Data →');
    bodyData.forEach((key, value) {
      print('   🔹 $key : $value');
    });

    print('🌐 Step 4️⃣: Sending POST request to: $updateUrl');

  final response = await http.post(
  updateUrl,
  headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  body: bodyData,
);


    print('📤 Step 5️⃣: Request sent successfully.');
    print('📥 Step 6️⃣: Response received:');
    print('   🔸 Status Code → ${response.statusCode}');
    print('   🔸 Body → ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('🧩 Step 7️⃣: Decoded JSON → $data');

      if (data['success'] == true) {
        print('✅ Step 8️⃣: Profile updated successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${data['message'] ?? "Profile updated successfully"}'),
            backgroundColor: Colors.green,
          ),
        );
        await fetchProfile(); // 🔄 Refresh updated profile
      } else {
        print('⚠️ Step 8️⃣: Update failed → ${data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ ${data['message'] ?? "Update failed"}')),
        );
      }
    } else {
      print('❌ Step 9️⃣: Server returned error status → ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Server error: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('💥 Step 🔟: Exception caught → $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('💥 Network error: $e')),
    );
  }
}



  //logout function
  Future<void>Logout(BuildContext context)async{
final prefss= await SharedPreferences.getInstance();
print('Remove User_id & ph from this Device');
await prefss.remove('User_id');
await prefss.remove('ph');
//show snacbaR
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('👋 Logged out successfully'),
backgroundColor: Colors.green,
duration: Duration(seconds: 2),
));
 // 🔹 Navigate to login screen
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) =>  LoginPage()),
    (route) => false, // Removes all previous routes
  );
  }

  Future<void> fetchProfile() async {
    try {
      print('🟡 Step 1: Fetching SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('User_id') ?? '';

      print('🟢 Step 2: Saved User_id in device: "$userId"');

      if (userId == null || userId!.isEmpty) {
        print('❌ No User_id found — probably not saved during login.');
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse('https://safebasket.in/app/fetch_profile.php?user_id=$userId');
      print('🌐 Step 3: Fetching profile from $url');

      final response = await http.get(url);
      print('📥 Step 4: Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['result'] != null && data['result'].isNotEmpty) {
          setState(() {
            userData = data['result'][0];
            isLoading = false;
          });
          print('✅ Step 5: Profile data loaded successfully');
        } else {
          print('⚠️ No user data found.');
          setState(() => isLoading = false);
        }
      } else {
        print('❌ Server Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('💥 Exception while fetching profile: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : userData == null
              ? const Center(child: Text('No profile found'))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/placeholder.jpg'),
                        backgroundColor: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userData!['name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('📞 ${userData!['ph'] ?? 'N/A'}'),
                      const Divider(height: 40, thickness: 1),
                      _buildDetailRow('Alter-No.', userData!['alt_ph']),
                      _buildDetailRow('Email', userData!['email']),
                      _buildDetailRow('Gender', userData!['gender']),
                      _buildDetailRow('DOB', userData!['dob']),
                      _buildDetailRow('Address', userData!['fulladdress']),
                      _buildDetailRow('City', userData!['city']),
                      _buildDetailRow('District', userData!['district']),
                      _buildDetailRow('State', userData!['state']),
                      _buildDetailRow('Pincode', userData!['pincode']),

                      const SizedBox(height: 30),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
  
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => _buildEditProfileDialog(),
        );
      },
      child: const Text('Update Profile',style: TextStyle(color: Colors.black),),
    ),
  ],
),

                    ],
                  ),
                  
                ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value?.isNotEmpty == true ? value! : 'N/A'),
        ],
      ),
    );
  }
  Widget _buildEditProfileDialog() {
  // Create controllers for editable fields
  final nameCtrl = TextEditingController(text: userData?['name'] ?? '');
  final emailCtrl = TextEditingController(text: userData?['email'] ?? '');
  final altPhCtrl = TextEditingController(text: userData?['alt_ph'] ?? '');
  final passwordCtrl = TextEditingController(text: userData?['password'] ?? '');
  final genderCtrl = TextEditingController(text: userData?['gender'] ?? '');
  final dobCtrl = TextEditingController(text: userData?['dob'] ?? '');
  final addressCtrl = TextEditingController(text: userData?['fulladdress'] ?? '');
  final cityCtrl = TextEditingController(text: userData?['city'] ?? '');
  final districtCtrl = TextEditingController(text: userData?['district'] ?? '');
  final stateCtrl = TextEditingController(text: userData?['state'] ?? '');
  final pincodeCtrl = TextEditingController(text: userData?['pincode'] ?? '');

  return AlertDialog(
    title: const Text('Edit Profile'),
    content: SingleChildScrollView(
      child: Column(
        children: [
          _textField('Name', nameCtrl),
          _textField('Email', emailCtrl),
          _textField('Alt Phone', altPhCtrl),
          _textField('Password', passwordCtrl, obscure: true),
          _textField('Gender', genderCtrl),
          _textField('DOB', dobCtrl),
          _textField('Full Address', addressCtrl),
          _textField('City', cityCtrl),
          _textField('District', districtCtrl),
          _textField('State', stateCtrl),
          _textField('Pincode', pincodeCtrl),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          // Update userData map
          setState(() {
            userData?['email'] = emailCtrl.text;
            userData?['name'] = nameCtrl.text;
            userData?['alt_ph'] = altPhCtrl.text;
            userData?['password'] = passwordCtrl.text;
            userData?['gender'] = genderCtrl.text;
            userData?['dob'] = dobCtrl.text;
            userData?['fulladdress'] = addressCtrl.text;
            userData?['city'] = cityCtrl.text;
            userData?['district'] = districtCtrl.text;
            userData?['state'] = stateCtrl.text;
            userData?['pincode'] = pincodeCtrl.text;
          });

          Navigator.pop(context);
          updateProfile();
        },
        child: const Text('Save'),
      ),
    ],
  );
}

Widget _textField(String label, TextEditingController ctrl, {bool obscure = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

}
