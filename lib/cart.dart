import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:safbasketapp/checkoutpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPageFromSharedPrefs extends StatefulWidget {
  @override
  _CartPageFromSharedPrefsState createState() =>
      _CartPageFromSharedPrefsState();
}

class _CartPageFromSharedPrefsState extends State<CartPageFromSharedPrefs> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedCart = prefs.getStringList('cart');

    if (storedCart != null && storedCart.isNotEmpty) {
      setState(() {
        cartItems = storedCart
            .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
            .toList();
      });
    }
  }

  Future<void> _updateCartInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedCart =
        cartItems.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('cart', updatedCart);
  }

  void _incrementQty(int index) {
    setState(() {
      cartItems[index]['quantity']++;
    });
    _updateCartInPrefs();
  }

  void _decrementQty(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        // Optional: remove item if qty == 1 and user presses minus again
        cartItems.removeAt(index);
      }
    });
    _updateCartInPrefs();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    for (var item in cartItems) {
      final price = double.tryParse(item['discount_price'].toString()) ?? 0;
      final qty = item['quantity'] ?? 1;
      totalPrice += price * qty;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: cartItems.isEmpty
          ? const Center(child: Text("🛒 Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: ListTile(
                          leading: Image.network(
                            item['image'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.fastfood),
                          ),
                          title: Text(item['pro_name'] ?? ''),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.redAccent),
                                onPressed: () => _decrementQty(index),
                              ),
                              Text(
                                "${item['quantity']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.green),
                                onPressed: () => _incrementQty(index),
                              ),
                            ],
                          ),
                          trailing: Text(
                            "₹${(double.tryParse(item['discount_price'].toString()) ?? 0) * (item['quantity'] ?? 1)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0, -1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ₹${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
       ElevatedButton(
  onPressed: () {
    if (cartItems.isEmpty) return;

    final gst = totalPrice * 0.05; // Example 5% GST
    final grandTotal = totalPrice + gst;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          products: cartItems, // ✅ send all items
          totalPrice: grandTotal,
          totalGst: gst,
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
  child: const Text("Checkout"),
),

                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
