import 'package:flutter/material.dart';

class OrderTrackingPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  OrderTrackingPage({required this.orderData});

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

List<String> steps = [
  "Pending",
  "Confirmed",
  "Processing",
  "Completed",
  "Cancelled"
];




int getStatusIndex(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 0;
    case 'confirmed':
      return 1;
    case 'processing':
      return 2;
    case 'completed':
      return 3;
    case 'cancelled':
      return 4;
    default:
      return 0;
  }
}




  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;

    final orderCode = order['order_code'] ?? "-";
    final orderStatus = order['order_status'] ?? "Pending";

    final firstItem = order['items'][0];
    final productName = firstItem['product_name'] ?? "Product";
    final productImage = firstItem['product_image'] ?? "";
    final productQty = firstItem['quantity'] ?? "1";

    int activeStep = getStatusIndex(orderStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Tracking"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            /// PRODUCT CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      productImage,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productName,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Qty: $productQty"),
                        SizedBox(height: 4),
                        Text("Order Code: $orderCode",
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            /// TRACKING TIMELINE
            Column(
              children: List.generate(steps.length, (index) {
                bool isActive = index <= activeStep;

                return AnimatedOpacity(
                  duration: Duration(milliseconds: 400),
                  opacity: isActive ? 1 : 0.3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 600),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color:
                                  isActive ? Colors.green : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),

                          if (index != steps.length - 1)
                            Container(
                              width: 3,
                              height: 45,
                              color: isActive
                                  ? Colors.green
                                  : Colors.grey.shade400,
                            ),
                        ],
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            steps[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isActive ? FontWeight.bold : FontWeight.w400,
                              color: isActive ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
