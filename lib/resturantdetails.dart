import 'package:flutter/material.dart';

class RestaurantDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restaurant Name')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text('Restaurant Banner')),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Restaurant Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('⭐ 4.5 • 25 mins • Italian, Fast Food'),
                  SizedBox(height: 10),
                  Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Column(
                    children: List.generate(
                      5,
                      (index) => Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: Container(width: 60, height: 60, color: Colors.grey[300]),
                          title: Text('Dish ${index + 1}'),
                          subtitle: Text('Description of dish'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('\$${5 + index}'),
                              IconButton(icon: Icon(Icons.add_circle, color: Colors.green), onPressed: () {}),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
