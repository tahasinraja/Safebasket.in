import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:safbasketapp/cart.dart';
import 'package:safbasketapp/loginpage.dart';

import 'package:safbasketapp/profilepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VegPage extends StatefulWidget {
  const VegPage({super.key});

  @override
  State<VegPage> createState() => _VegPageState();
}

class _VegPageState extends State<VegPage> {
  List<Map<String, dynamic>> foods = [];
  List<Map<String, dynamic>> filteredFoods = [];
  bool isLoading = true;
  String searchQuery = "";

  // 🔹 Fetch food from API
  Future<void> fetchFoods() async {
    try {
      final response = await http.get(Uri.parse("https://example.com/api/vegfoods"));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          foods = data.map((item) {
            return {
              "name": item["name"],
              "price": item["price"],
              "image": item["image"],
              "quantity": 0
            };
          }).toList();
          filteredFoods = foods;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load food items");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔹 Login check
  Future<void> loginCheckNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isloggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartPageFromSharedPrefs()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.orangeAccent],
                ),
              ),
              accountName: const Text("Guest User",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: const Text("guest@foodbasket.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.redAccent, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.redAccent),
              title: const Text("Profile"),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ProfilePage())),
            ),
            ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.redAccent),
                title: const Text("Cart"),
                onTap: () => loginCheckNavigate(context)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text("Veg Foods"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => loginCheckNavigate(context),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  // 🔹 Image Slider
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: [
                      'https://i.imgur.com/2nCt3Sbl.jpg',
                      'https://i.imgur.com/wfP7hPnl.jpg',
                      'https://i.imgur.com/b9zDbybl.jpg'
                    ].map((url) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(url, fit: BoxFit.cover, width: 1000),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search Veg Food...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          filteredFoods = foods
                              .where((item) => item['name']
                                  .toLowerCase()
                                  .contains(searchQuery))
                              .toList();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Food grid
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3, // 🔹 Responsive grid
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: MediaQuery.of(context).size.width < 600 ? 0.65 : 0.8, // 🔹 Adjusts for small screens
      ),
                      itemCount: filteredFoods.length,
                      itemBuilder: (context, index) {
                        final food = filteredFoods[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                offset: const Offset(2, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18)),
                                child: Image.network(
                                  food['image'],
                                  fit: BoxFit.cover,
                                  
                                  width: double.infinity,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  food['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text("₹${food['price']}",
                                  style: TextStyle(color: Colors.grey[700])),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (food['quantity'] > 0)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() {
                                          if (food['quantity'] > 0)
                                            food['quantity']--;
                                        });
                                      },
                                    ),
                                  Text('${food['quantity']}',
                                      style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        food['quantity']++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
