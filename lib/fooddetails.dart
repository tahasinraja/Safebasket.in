import 'package:flutter/material.dart';
import 'package:safbasketapp/checkoutpage.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, dynamic> food;

  FoodDetailPage({required this.food});

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.food['quantity'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.food['pro_name']??'')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Image placeholder
            Container(
              height: MediaQuery.of(context).size.height*.27,
              width: MediaQuery.of(context).size.width*.7,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(12),
                child: FadeInImage.assetNetwork(placeholder: 'assets/images/placeholder.jpg',
                 image: widget.food['image']??'',fit: BoxFit.cover,),
              ),

            ),
            SizedBox(height: 20),
            Text(widget.food['pro_name']??'', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(widget.food['description']?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
            Text('Price: \₹${widget.food['discount_price']??''}', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              'Delicious food description goes here. You can add details like ingredients, calories, and preparation time.',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                quantity > 0
                    ? IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (quantity > 0) quantity--;
                            widget.food['quantity'] = quantity;
                          });
                        },
                      )
                    : SizedBox(),
                Text('$quantity', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      quantity++;
                      widget.food['quantity'] = quantity;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Go back to previous page
                    Navigator.pop(context);
                  },
                  child: Text('Back'),
                ),
                SizedBox(width: 20,),
ElevatedButton(
  onPressed: () {
    final product = widget.food;

    // if no quantity selected, default to 1
    final qty = (quantity > 0) ? quantity : 1;

    // Convert this single product to a list, because CheckoutPage expects a list
    final productList = [
      {
        "pro_code": product['pro_code'] ?? '',
        "pro_name": product['pro_name'] ?? '',
        "discount_price": product['discount_price'] ?? '0',
        "price": product['price'] ?? product['discount_price'] ?? '0',
        "portion_size": product['portion_size'] ?? '',
        "resture_code": product['resture_code'] ?? 'R001',
        "quantity": qty,
        "image": product['image'] ?? '',
      }
    ];

    // Calculate totals
    final double price = double.tryParse(product['discount_price'].toString()) ?? 0;
    final double totalPrice = price * qty;
    final double totalGst = totalPrice * 0.05; // 5% GST

    // Navigate to CheckoutPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          products: productList,
          totalPrice: totalPrice,
          totalGst: totalGst,
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
  child: const Text('Proceed to Checkout'),
),


                
              ],
            )
          ],
        ),
      ),
    );
  }
}
