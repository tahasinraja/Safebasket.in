import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safbasketapp/ordertracking.dart';
import 'package:shared_preferences/shared_preferences.dart';
class statushistorypage extends StatefulWidget {
  const statushistorypage({super.key});

  @override
  State<statushistorypage> createState() => _statushistorypageState();
}

class _statushistorypageState extends State<statushistorypage> {
  bool isloading=false;
  String? userId;
  List<dynamic>  orderlist=[];
  
  Future<void> fetchorder()async{


try{
  print('user id Fetching...');
  


  final prefs= await SharedPreferences.getInstance();
  userId= prefs.getString('User_id');


     if (userId == null || userId!.isEmpty) {
        print('❌ User_id not found in SharedPreferences!');
        return;
      }  print('userid:$userId');


final historyurl=Uri.parse('https://safebasket.in/app/fetch_order.php?user_id=$userId');
 setState(() {
   isloading=true;
 });
   

final responce= await http.get(historyurl);
if(responce.statusCode==200){


  print('Status Code:${responce.statusCode}');
  print('Responce:${responce.body}');


  final data= jsonDecode(responce.body);
  if(data['success']==true && data['data']is List){
  setState(() {
    orderlist=data['data'];

  });
print('Order list Fetch:${orderlist.length}');
  } else{
    print("Orderlist not found/invalid ");
  }
 
} else{
  print('Http error:${responce.statusCode}');
}
}
catch(e){
  print('Error:$e');
} finally{
  setState(() {
    isloading=false;
  });
}
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchorder();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order History'),centerTitle: true,),
      body: isloading?
      Center(child: CircularProgressIndicator(),):
      orderlist.isEmpty? Center(
        child: Text('No Order Found')
      ):
      ListView.builder(itemCount: orderlist.length, itemBuilder: (context, index) {
        final order= orderlist[index];
        return Card(
  margin: const EdgeInsets.all(12),
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder:
         (context) => OrderTrackingPage(orderData: order),));
      },
      leading: Icon(Icons.receipt_long, color: Colors.redAccent),
      title: Text(order['order_code'] ?? 'No Code', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text('Product Name:${order['']??''}'),
          Text("Status: ${order['order_status'] ?? 'Unknown'}"),
          Text("Total: ₹${order['total_amount'] ?? '0.00'}"),
          Text("Payment: ${order['payment_mode'] ?? 'N/A'}"),
        ],
      ),
    ),
  ),
);

      },)
    );
  }
}