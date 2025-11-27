import 'dart:convert';



import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:safbasketapp/aboutpage.dart';
import 'package:safbasketapp/basketgrosery.dart';

import 'package:safbasketapp/cart.dart';
import 'package:safbasketapp/fooddetails.dart';
import 'package:safbasketapp/helpsupport.dart';
import 'package:safbasketapp/loginpage.dart';
import 'package:safbasketapp/ordehistorypage.dart';

import 'package:safbasketapp/profilepage.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> sliderimage=[];
  int cartItemCount = 0;
  // cart count
  Future<void> _loadCartCount() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? storedCart = prefs.getStringList('cart');
  setState(() {
    cartItemCount = storedCart?.length ?? 0;
  });
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
// add to cart function
void addToCart(Map<String, dynamic> product) async {
  final prefs = await SharedPreferences.getInstance();

  // Load existing cart
  List<String> existingCart = prefs.getStringList('cart') ?? [];

  // Add this product
  existingCart.add(jsonEncode({
    'pro_code': product['pro_code'],
    'pro_name': product['pro_name'],
    'price': product['price'],
    'discount_price': product['discount_price'],
    'portion_size': product['portion_size'],
    'quantity': 1, // start with 1
    'image': product['image'],
  }));

  // Save cart again
  await prefs.setStringList('cart', existingCart);
  setState(() {
    cartItemCount = existingCart.length;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('🛒 Added ${product['pro_name']} to cart'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );

  print('✅ Product added to cart: ${product['pro_name']}');

  // ✅ Navigate to CartPage after adding
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CartPageFromSharedPrefs()),
  );
}



 Future<void> Logincheckstatusnavigate(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // 🔹 Check whether user is logged in
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // 🔹 For testing (optional): print the value
  print('Login status: $isLoggedIn');

  if (isLoggedIn) {
    // ✅ If user is already logged in, go to Cart Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPageFromSharedPrefs(),
    ));
  } else {
    // ❌ If not logged in, go to Login Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  LoginPage()),
    );
  }
}
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String? userId;
//profile fetch function
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
// banner fetch
Future<void> fetchAllBanners() async {
  print('🚀 Fetch All Banners Called');

  final url = Uri.parse('https://safebasket.in/app/fetch_banner.php');

  try {
    print('🌐 Sending GET request to: $url');

    final response = await http.get(url);

    print('✅ Response Status: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Fix here: check `success` and `result`
      if (data['success'] == true && data['result'] != null) {
        final List<dynamic> banners = data['result'];

        // 🔹 Clean file URLs if needed
        final cleanedBanners = banners.map((item) {
          String fileUrl = item['file'] ?? '';
          if (fileUrl.startsWith('https://safebasket.in/https://')) {
            fileUrl = fileUrl.replaceFirst('https://safebasket.in/', '');
          }
          return {
            'id': item['id'],
            'file': fileUrl,
          };
        }).toList();

        setState(() {
          sliderimage = cleanedBanners;
        });

        print('✅ Total Banners Fetched: ${sliderimage.length}');
        for (var banner in sliderimage) {
          print('🖼️ Banner URL: ${banner['file']}');
        }
      } else {
        print('⚠️ Server Message: No data found');
      }
    } else {
      print('❌ Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('❌ Exception: $error');
  }
}




@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAllBanners();
    fetchCategories();
    fetchproducts();
    fetchProfile();
    _loadCartCount();
  }
// category fetch
 List<Map<String, String>> categories = [];

Future<void> fetchCategories() async {
  final url = Uri.parse('https://safebasket.in/app/fetch_category.php');

  try {
    print('🌐 Fetching categories from: $url');
    final response = await http.get(url);

    print('📦 Response Status: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['result'] != null) {
        final List<dynamic> _categories = data['result'];

        // 🔹 Extract both name and image
        final List<Map<String, String>> categoryList = _categories.map((item) {
          return {
            'name': item['name'].toString(),
            'image': item['image'].toString(),
          };
        }).toList(); // ✅ correct

        setState(() {
          categories = categoryList;
        });

        print('✅ Total Categories: ${categories.length}');
        for (var cat in categories) {
          print('📛 Name: ${cat['name']} 🖼️ Image: ${cat['image']}');
        }
      } else {
        print('⚠️ No data found in response');
      }
    } else {
      print('❌ Request failed: ${response.statusCode}');
    }
  } catch (error) {
    print('🚨 Exception: $error');
  }
}


//fetch product function
List<dynamic> searchSuggestions = [];

List<dynamic> Products = [];
List<dynamic> filteredProducts = []; // Search results
//searching list
void searchProducts(String query) {
  if (query.isEmpty) {
    setState(() {
      filteredProducts = Products;
      searchSuggestions = [];
    });
    return;
  }

  final results = Products.where((item) {
    final name = item['pro_name'].toString().toLowerCase();
    final input = query.toLowerCase();
    return name.contains(input);
  }).toList();

  setState(() {
    filteredProducts = results;
    searchSuggestions = results.take(5).toList(); // only top 5 suggestions
  });
}




Future<void> fetchproducts() async {
  final fetchUrl = Uri.parse('https://safebasket.in/app/fetch_product.php');
  try {
    print('🚀 Fetching products from: $fetchUrl');
    final response = await http.get(fetchUrl);

    print('✅ Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['result'] is List) {
        final fetchedProducts = data['result'] as List<dynamic>;

        final cleanedProducts = fetchedProducts.map((item) {
          final prices = (item['prices'] as List?) ?? [];
          final firstPriceOption = prices.isNotEmpty
              ? prices.first
              : {'price': '0', 'discount_price': '0', 'portion_size': ''};

          return {
           // "product_code": item['pro_code'],   // ✔ this matches your product fetch key

            'pro_code': item['pro_code'] ?? '',
            'pro_name': item['pro_name'] ?? '',
            'description': item['description'] ?? '',
            'category_id': item['category_id'] ?? '',
            'category_name': item['category_name'] ?? '',
            'p_type': item['p_type'] ?? '',
            'image': item['image'] ?? '',
            'available': item['available'] ?? '0',
            'resture_code': item['resture_code'] ?? '',
            'price': firstPriceOption['price'].toString(),
            'discount_price': firstPriceOption['discount_price'].toString(),
            'portion_size': firstPriceOption['portion_size'] ?? '',
            'prices': prices,
            'quantity': 0,
          };
        }).toList();

        setState(() {
          Products = cleanedProducts;
          filteredProducts = cleanedProducts;   // 👈 By default all products show
        });

        print('✅ Total products fetched: ${Products.length}');
        for (var p in Products) {
          print('🛒 ${p['pro_name']} - ₹${p['price']} (Discount ₹${p['discount_price']})');
        }
      } else {
        print('⚠️ No valid data found or invalid response structure.');
      }
    } else {
      print('❌ Server Error: ${response.statusCode}');
    }
  } catch (e, stack) {
    print('🚨 Exception while fetching products: $e');
    print(stack);
  }
}




 

  Future<void> _refreshPage() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
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
              accountName:  Text(userData?['name']??'Unknown User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail:  Text(userData?['email']??'No Email',),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.redAccent, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.redAccent),
              title: const Text("Profile"),
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
            ),
           
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.redAccent),
              title: const Text("My Orders & History"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => statushistorypage(),));
              },
            ),
             ListTile(
              leading: const Icon(Icons.support_agent_outlined, color: Colors.redAccent),
              title: const Text("Help&Support"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Helpsupport(),));
              }
            ),
            const Divider(),
             ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.redAccent),
              title: const Text("About Us"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage(),));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () => Logout(context),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.redAccent,
              expandedHeight: 80,
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              
             flexibleSpace: FlexibleSpaceBar(
  titlePadding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
  centerTitle: true,
  title: SingleChildScrollView(scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
   
        // 🟠 Welcome Text (Center)
        const Text(
          "Welcome 🙏",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
    
  
      ],
    ),
  ),
  background: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.redAccent, Colors.redAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),

              actions: [
  Stack(
    children: [
      IconButton(
        icon: const Icon(Icons.shopping_cart, size: 30, color: Colors.white),
        onPressed: () => Logincheckstatusnavigate(context).then((_) => _loadCartCount())
      ),
      if (cartItemCount > 0)
        Positioned(
          right: 6,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$cartItemCount',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  ),
],

              
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      children: [
                 SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
     
      SizedBox(width: 16),

      // 🔴 Food House Button
      SizedBox(
        width: 180,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          icon: Icon(Icons.restaurant, size: 24),
          label: Text(
            "Food House",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            shadowColor: Colors.black45,
          ),
        ),
      ),
      SizedBox(width: 16),
       // 🟢 Grocery Button
      SizedBox(
        width: 180, // optional width to make buttons look uniform
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Grocessy()),
            );
          },
          icon: Icon(Icons.shopping_bag, size: 24),
          label: Text(
            "Grocery",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            shadowColor: Colors.black45,
          ),
        ),
      ),
 SizedBox(width: 16),
      // 🟡 Services Button
      SizedBox(
        width: 180,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Grocessy()),
            );
          },
          icon: Icon(Icons.miscellaneous_services, size: 24),
          label: Text(
            "Services",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            shadowColor: Colors.black45,
          ),
        ),
      ),
      SizedBox(width: 16),
    ],
  ),
),

SizedBox(height: 15,),
// searchbar
                      TextField(
  onChanged: (value) => searchProducts(value),
  decoration: InputDecoration(
    hintText: 'Search for foods or restaurants...',
    prefixIcon: Icon(Icons.search),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  ),
),
//searching list
if (searchSuggestions.isNotEmpty)
  Container(
    margin: EdgeInsets.only(top: 5),
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: searchSuggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[200],
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(22),
              child: Image.network(searchSuggestions [index]['image'],
              width: 50,
      height: 50,
      fit: BoxFit.cover,
              ))),
          title: Text(searchSuggestions[index]['pro_name']),
          
          onTap: () {
            // select item → open details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FoodDetailPage(food: searchSuggestions[index]),
              ),
            );
          },
        );
      },
    ),
  ),



                      ],
                    ),
                  ),
                  // 🔸 Carousel Slider
                CarouselSlider(
  options: CarouselOptions(
    height: 200,
    autoPlay: true,
    enlargeCenterPage: true,
    viewportFraction: 0.9,
    autoPlayInterval: Duration(seconds: 3),
  ),
  items: sliderimage.map((item) {
    return Builder(
      builder: (context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(item['file']),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }).toList(),
),

                  // 🔸 Categories
                  Padding(
  padding: const EdgeInsets.all(8.0),
  child: Column(
    
    children: [
      Text(
        'Eat Fresh. Eat Safe. Eat with Safebasket 🍱',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),textAlign: TextAlign.center,
      ),
      SizedBox(height: 10),
      Center(
     child: Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15),
  ),
  height: 140,
  padding: const EdgeInsets.symmetric(horizontal: 8),
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      final name = category['name'] ?? '';
      final imageUrl = category['image'] ?? ''; // ✅ fixed key

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🖼️ Category Image
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 40),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 🏷️ Category Name
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    },
  ),
),

      ),
    ],
  ),
),

                  SizedBox(height: 10),
                  // 🔸 Popular Foods Grid
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
  children: [
    Text(
      'Popular Foods',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.redAccent,
      ),
    ),
    SizedBox(height: 10),
filteredProducts.isEmpty
    ? const Center(child: Text("No products found"))
    : GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: filteredProducts.length,  // 🔥 search list
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(context).size.width < 600 ? 2 : 3, // responsive grid
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio:
              MediaQuery.of(context).size.width < 600 ? 0.50 : 0.7,
        ),
        itemBuilder: (context, index) {
          final product = filteredProducts[index];    // 🔥 search item

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FoodDetailPage(food: product)),
              );
            },
            child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: 
                    
                   SizedBox(
  width: double.infinity,
  height: 160, // ← fix height rakho (150–200 best)
  child: ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
    child: FadeInImage.assetNetwork(
      placeholder: 'assets/images/placeholder.jpg',
      image: product['image'] ?? '',
      fit: BoxFit.cover, // ← full cover
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/placeholder.jpg',
          fit: BoxFit.cover,
        );
      },
    ),
  ),
),

                  ),

                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['pro_name'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "₹${product['discount_price'] ?? ''}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "₹${product['price']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              ElevatedButton.icon(
                                onPressed: () => addToCart(product),
                                icon: const Icon(Icons.add_shopping_cart,
                                    size: 16, color: Colors.white),
                                label: const Text(
                                  "Add",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  minimumSize: const Size(65, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          if (product['portion_size'] != null &&
                              product['portion_size'].toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.orangeAccent, width: 0.8),
                              ),
                              child: Text(
                                product['portion_size'],
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),



  ],
),

                  ),
                  // 🔸 Top Restaurants
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Top Restaurants 🍽️',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent),
                      ),
                    ),
                  ),
                  Column(
                    children: List.generate(
                      6,
                      (index) => Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(Icons.restaurant, color: Colors.redAccent),
                            ),
                          ),
                          title: Text('Restaurant ${index + 1}',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Italian • 20–30 mins'),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
        
      ),
 
    );
  }
}
