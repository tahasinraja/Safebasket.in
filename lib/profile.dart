import 'package:flutter/material.dart';
 class Profillepage extends StatefulWidget {
  const Profillepage({super.key});

  @override
  State<Profillepage> createState() => _ProfillepageState();
}

class _ProfillepageState extends State<Profillepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundColor: Colors.grey[300]),
            SizedBox(height: 10),
            Text('John horn', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('john@example.com'),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Order History'),
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}



