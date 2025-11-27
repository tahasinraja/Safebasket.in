import 'package:flutter/material.dart';
import 'homepage.dart'; // ⚠️ Make sure you have a HomePage widget in your project

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🌅 Hero Section
            Stack(
              children: [
                Image.asset(
                  'assets/images/christmas_2012_new_1771.jpg',
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Safebasket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Healthy Food • Fast Delivery • Affordable Services',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 🍔 About Safebasket
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'About Safebasket',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Safebasket is a multi-service platform that delivers hygienic food, groceries, and home services at affordable prices. '
                    'We focus on quality, safety, and convenience — ensuring that every order and service is handled with care and professionalism.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 🥗 Food Hygiene & Delivery Section
            buildImageInfoSection(
              imagePath: 'assets/images/placeholder.jpg',
              title: 'Food Hygiene & Delivery Process',
              text:
                  'Every meal we deliver is prepared in clean, sanitized kitchens with top-quality ingredients. '
                  'Our delivery partners follow strict hygiene protocols — wearing gloves, masks, and maintaining food safety during transit.',
            ),

            // 💰 Affordable Pricing
            buildImageInfoSection(
              imagePath: 'assets/images/fastfood.jpg',
              title: 'Affordable Price & Best Quality',
              text:
                  'We believe that good food and reliable services should be affordable for every family. '
                  'Our pricing model ensures premium quality without breaking your budget.',
            ),

            // 🧰 Services Grid
            buildServicesGrid(),

            // 👨‍💼 Founder Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                // 👨‍💼 Team Section: Founder, CEO & Director
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text(
        'Our Leadership Team',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
      const SizedBox(height: 20),

      // 🧑‍💼 Grid of Team Members
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 20,
        children: [
             buildTeamCard(
            image: 'assets/director.jpg',
            name: 'Kusum Kumari',
            title: 'Founder & Co. Founder',
            description:
            'Visionary behind Safebasket. Focused on innovation, transparency, and customer satisfaction'
                
          ),
          buildTeamCard(
            image: 'assets/images/1762523794402.jpeg',
            name: ' Mr.Chandrashekhar Kumar ',
            title: 'Operation Manager',
            description:
                 'Drives growth, quality, and operational excellence across Safebasket’s multi-service platform.',
          ),
          buildTeamCard(
            image: 'assets/images/Adibphoto.jpeg',
            name: 'Ms.Adib Ahmad Ansari ',
            title: 'Managing Director',
            description:
            'Leads strategic partnerships and ensures smooth service delivery and customer support.'
               
          ),
       
        ],
      ),
    ],
  ),
),

                ],
              ),
            ),

            // 🚀 Get Started Button
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) =>  HomePage()),
                );
              },
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text(
                'Explore Safebasket',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 40),

            // 📞 Footer
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Text(
                    'Safebasket Pvt. Ltd.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'support@safebasket.in | +91 123456789',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '© 2025 Safebasket. All Rights Reserved.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for info section with image background
  Widget buildImageInfoSection({
    required String imagePath,
    required String title,
    required String text,
  }) {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(text,
                style: const TextStyle(color: Colors.white70, height: 1.5)),
          ],
        ),
      ),
    );
  }

  // Widget for Services Grid
  Widget buildServicesGrid() {
    final services = [
      'Electrician',
      'Plumber',
      'Carpenter',
      'Mechanic',
      'Tutor',
      'Driver',
      'Party Organiser',
      'Astrologist',
      'Medicine Delivery',
      'Ticket Provider',
      'Tour & Travel',
      'Software Maker',
    ];

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Services',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: services.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3.3,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        services[index],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget buildTeamCard({
  required String image,
  required String name,
  required String title,
  required String description,
}) {
  return Container(
    width: 260,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: const Offset(2, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            image,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
      ],
    ),
  );
}

}
