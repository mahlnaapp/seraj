// lib/screens/bottom_nav_bar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seraj/screens/my_orders_soon_screen.dart';
import '../providers/cart_provider.dart';
import 'home_screen.dart'; // هذه ستعرض المتاجر
import 'previous_orders_screen.dart'; // الشاشة الجديدة للطلبات
import 'search_screen.dart'; // شاشة البحث
import 'shopping_cart_screen.dart'; // شاشة سلة التسوق (لزر السلة في الشريط العلوي)

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0; // لتعقب الشاشة المحددة في الشريط السفلي

  // قائمة الشاشات التي سيتم عرضها
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // تعرض المتاجر الآن
    const MyOrdersSoonScreen(), // لعرض الطلبات السابقة
    const SearchScreen(), // للبحث عن المتاجر
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتجر'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  // تحتاج إلى تمرير storeId هنا، يمكنك تمرير ID وهمي أو تعديل هذا الجزء
                  // إذا كنت تريد أن تكون سلة التسوق مرتبطة بمتجر معين في كل الأوقات.
                  // أو يمكنك تعديل شاشة سلة التسوق لتتعامل مع أكثر من متجر.
                  // حاليا، لن يظهر زر السلة إلا في شاشة المتجر عند اختيار منتجاته.
                  // هنا، نستخدمها لزر عام.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShoppingCartScreen(
                          storeId: 'global_cart'), // يمكن استخدام ID عام
                    ),
                  );
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartProvider.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex), // عرض الشاشة المحددة
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'المتاجر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'طلباتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'بحث',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
