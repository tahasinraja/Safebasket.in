import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final List<String> _sliderImages = [
    'assets/images/offer1.jpg',
    'assets/images/offer2.jpg',
    'assets/images/offer3.jpg',
  ];

  final List<Map<String, dynamic>> _foodItems = [
    {"name": "Paneer Butter Masala", "price": 180, "image": "assets/images/paneer.jpg"},
    {"name": "Chicken Biryani", "price": 220, "image": "assets/images/biryani.jpg"},
    {"name": "Veg Burger", "price": 90, "image": "assets/images/burger.jpg"},
    {"name": "Cold Coffee", "price": 70, "image": "assets/images/coffee.jpg"},
    {"name": "Pizza Margherita", "price": 150, "image": "assets/images/pizza.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          "SafeBasket Restaurant",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Slider Section
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                autoPlayInterval: const Duration(seconds: 3),
              ),
              items: _sliderImages.map((image) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(image, fit: BoxFit.cover, width: double.infinity),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // 🔹 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search your favorite food...",
                  prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 Offer Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.redAccent, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Get 20% OFF on all online orders above ₹299!",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 Food Item Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _foodItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 230,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final food = _foodItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(2, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.asset(
                            food["image"],
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            food["name"],
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "₹${food["price"]}",
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              minimumSize: const Size(double.infinity, 35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text("Add"),
                            onPressed: () {},
                          ),
                        )
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
