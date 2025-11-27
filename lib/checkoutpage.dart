import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safbasketapp/homepage.dart';
import 'package:safbasketapp/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final double totalPrice;
  final double totalGst;

  const CheckoutPage({
    super.key,
    required this.products,
    required this.totalPrice,
    required this.totalGst,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

//   Map<String, String> productIdMap = {
//   "P001": "1",
//   "P002": "2",
//   "P003": "3", // Veg Fried Rice
//   "P004": "4",
//   "P005": "5",
//   "P006": "6",
// };



  bool isLoading = true;
  Map<String, dynamic>? userData;
  String? userId;
  String paymentMode = 'Cash';

  // Controllers
  final nameCtrl = TextEditingController();
  final phCtrl = TextEditingController();
  final altPhCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final postCtrl = TextEditingController();
  final psCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  // 🔹 Fetch user profile
  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('User_id') ?? '';

    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ User not logged in. Please login again.')),
        
      );
      await Future.delayed(Duration(microseconds: 2));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
      return;
    }

    final url = Uri.parse('https://safebasket.in/app/fetch_profile.php?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true &&
          data['result'] != null &&
          data['result'].isNotEmpty) {
        setState(() {
          userData = data['result'][0];
          isLoading = false;
        });
        _fillControllers();
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  void _fillControllers() {
    nameCtrl.text = userData?['name'] ?? '';
    phCtrl.text = userData?['ph'] ?? '';
    altPhCtrl.text = userData?['alt_ph'] ?? '';
    emailCtrl.text = userData?['email'] ?? '';
    addressCtrl.text = userData?['fulladdress'] ?? '';
    cityCtrl.text = userData?['city'] ?? '';
    postCtrl.text = userData?['post'] ?? '';
    psCtrl.text = userData?['policestation'] ?? '';
    districtCtrl.text = userData?['district'] ?? '';
    stateCtrl.text = userData?['state'] ?? '';
    countryCtrl.text = userData?['country'] ?? '';
    pincodeCtrl.text = userData?['pincode'] ?? '';
  }

  // 🔹 Create order
Future<void> createOrder() async {
  final orderUrl = Uri.parse('https://safebasket.in/app/insert_order.php');
  final orderCode = 'ORD${DateTime.now().millisecondsSinceEpoch}';

  print('🟢 Step 1️⃣: Starting order creation...');
  print('🟢 Products in cart: ${widget.products.length}');
  print('🟢 Total Price: ${widget.totalPrice}');
  print('🟢 Total GST: ${widget.totalGst}');

  if (widget.products.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠️ No products in cart!')),
    );
    return;
  }

  // ✅ Extract resture_code from first product (required by backend)
  final restureCode = widget.products.first['resture_code'] ?? 'R001';
  print('🟢 Step 2️⃣: Using resture_code = $restureCode');

  // ✅ Prepare body data
  final bodyData = {
    "user_id": userId ?? '',
    "resture_code": restureCode,
    "cus_name": nameCtrl.text,
    "cus_ph": phCtrl.text,
    "alt_ph": altPhCtrl.text,
    "email": emailCtrl.text,
    "cus_fulladdress": addressCtrl.text,
    "cus_city": cityCtrl.text,
    "cus_post": postCtrl.text,
    "cus_policestation": psCtrl.text,
    "cus_district": districtCtrl.text,
    "cus_state": stateCtrl.text,
    "cus_country": countryCtrl.text,
    "cus_pincode": pincodeCtrl.text,
    "order_code": orderCode,
    "payment_mode": paymentMode,
    "total_gst": widget.totalGst.toStringAsFixed(2),
    "total_price": widget.totalPrice.toStringAsFixed(2),
    "status": "Pending",

    // 🟢 All items as JSON string
 "items": widget.products.map((p) => {
  "product_code": p["pro_code"], 
  //"product_id": p['pro_code'] ?? '',  // 🔥 FIXED
  "pro_name": p['pro_name'] ?? '',
  "quantity": (p['quantity'] ?? 1).toString(),
  "portion_size": p['portion_size'] ?? '',
  "price": p['price'] ?? '0',
  "discount_price": p['discount_price'] ?? '0',
  "gst_percent": "5.00",
  "total_price": ((double.tryParse(p['discount_price'].toString()) ?? 0) *
          (p['quantity'] ?? 1))
      .toStringAsFixed(2),
}).toList(),

};
  
print("🧩 Product Map: ${jsonEncode(widget.products)}");

  print('🟢 Step 3️⃣: FINAL Body Data (Before Sending):');
  print(jsonEncode(bodyData));

  try {
    final response = await http.post(
      orderUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyData),
    );

    print('📦 Step 4️⃣: Response Status: ${response.statusCode}');
    print('📦 Step 5️⃣: Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
if (data['success'] == true) {
  // ✅ Step 1: Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('✅ Order placed successfully!'),
      duration: Duration(seconds: 2),
    ),
  );

  // ✅ Step 2: Clear cart
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('cart');

  // ✅ Step 3: Delay a little to show message
  await Future.delayed(const Duration(seconds: 2));

  // ✅ Step 4: Navigate to HomePage with animation (replaces current page)
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // nice fade + slide animation
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: FadeTransition(opacity: animation, child: child));
      },
    ),
  );
}


       else {
        print('⚠️ Step 6️⃣: Order failed - ${data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ ${data['message']}')),
        );
      }
    } else {
      print('❌ Step 6️⃣: Server error - ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('😊 Order successfully Proceed please  wait while  ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('💥 Step 7️⃣: Exception occurred: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('💥 Network error: $e')),
    );
  }
}
/// 🧹 Clear saved cart items from SharedPreferences
// Future<void> _clearCart() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('cart');
//   print('🧹 Cart cleared from SharedPreferences!');
// }


  // 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧾 Order Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // 🔹 Product list
                  ...widget.products.map((product) {
                    final price = double.tryParse(product['discount_price'].toString()) ?? 0;
                    final qty = product['quantity'] ?? 1;
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          product['image'] ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.fastfood),
                        ),
                        title: Text(product['pro_name'] ?? ''),
                        subtitle: Text('₹${price.toStringAsFixed(2)} × $qty'),
                        trailing: Text(
                          '₹${(price * qty).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),
                  Text('Total (incl. GST): ₹${widget.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),
                  const Text('🏠 Delivery Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),
                  _buildTextField('Full Name', nameCtrl),
                  _buildTextField('Phone', phCtrl),
                  _buildTextField('Alt Phone', altPhCtrl),
                  _buildTextField('Email', emailCtrl),
                  _buildTextField('Full Address', addressCtrl),
                  _buildTextField('City', cityCtrl),
                  _buildTextField('Post', postCtrl),
                  _buildTextField('Police Station', psCtrl),
                  _buildTextField('District', districtCtrl),
                  _buildTextField('State', stateCtrl),
                  _buildTextField('Country', countryCtrl),
                  _buildTextField('Pincode', pincodeCtrl),

                  const SizedBox(height: 20),
                  const Text('💳 Payment Method',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  RadioListTile<String>(
                    title: const Text('Cash on Delivery'),
                    value: 'Cash',
                    groupValue: paymentMode,
                    onChanged: (val) => setState(() => paymentMode = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Online Payment'),
                    value: 'Online',
                    groupValue: paymentMode,
                    onChanged: (val) => setState(() => paymentMode = val!),
                  ),

                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Place Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      ),
                      onPressed: createOrder,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
