// lib/screens/my_orders_soon_screen.dart
import 'package:flutter/material.dart';

class MyOrdersSoonScreen extends StatelessWidget {
  const MyOrdersSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0), // إخفاء الـ AppBar
        // هذا هو السطر المهم، تأكد أنه لا يوجد هنا 'const'
        child: AppBar(), // <--- لا يوجد 'const' هنا!
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'هذه الخانة ستتوفر قريباً!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'نحن نعمل بجد لإحضار أفضل تجربة لك.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
