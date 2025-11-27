import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:safbasketapp/cart.dart';
import 'package:safbasketapp/fooddetails.dart';
import 'package:safbasketapp/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NonVegPage extends StatefulWidget {
  const NonVegPage({super.key});

  @override
  State<NonVegPage> createState() => _NonVegPageState();
}

class _NonVegPageState extends State<NonVegPage> {
  List<Map<String, dynamic>> foods = [];

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


  // 🔹 Image Slider Images
  final List<String> _sliderImages = [
    'assets/images/chicken_banner.jpg',
   'assets/images/fastfood.jpg',
    'unnamed.jpg',
  ];

  // 🔹 Dummy Product Data (API se replace kar sakte ho)
  final List<Map<String, dynamic>> nonVegFoods = List.generate(8, (index) {
    return {
      "name": "Non-Veg Dish ${index + 1}",
      "price": 100 + index * 20,
      "image":
          'assets/images/pre-prepared-food-showcasing-ready-eat-delicious-meals-go.jpg',
    };
  });

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredFoods = nonVegFoods
        .where((food) =>
            food["name"].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(" Non Veg Foods"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => loginCheckNavigate(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Image Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
              items: _sliderImages.map((img) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // 🔹 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Non-Veg dishes...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                itemCount: filteredFoods.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3, // 🔹 Responsive grid
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: MediaQuery.of(context).size.width < 600 ? 0.65 : 0.8, // 🔹 Adjusts for small screens
      ),
                itemBuilder: (context, index) {
                  final food = filteredFoods[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailPage(food: food),));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.asset(
                                food["image"],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              food["name"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("₹${food["price"]}",
                                style: const TextStyle(color: Colors.green)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.add_shopping_cart, size: 18),
                              label: const Text("Add"),
                            ),
                          ),
                        ],
                      ),
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
