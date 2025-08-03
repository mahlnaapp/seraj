// lib/screens/previous_orders_screen.dart
import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import '../models/order.dart';
// import '../models/cart_item.dart'; // **** تم حذف هذا السطر ****
import 'package:flutter/foundation.dart'; // لإضافة debugPrint

class PreviousOrdersScreen extends StatefulWidget {
  const PreviousOrdersScreen({super.key});

  @override
  State<PreviousOrdersScreen> createState() => _PreviousOrdersScreenState();
}

class _PreviousOrdersScreenState extends State<PreviousOrdersScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      String userId = await AppwriteService.instance.getUserId();
      if (userId.isNotEmpty) {
        setState(() {
          _ordersFuture = AppwriteService.instance.getUserOrders(userId);
        });
      } else {
        debugPrint('User ID is empty. Cannot fetch orders.');
        setState(() {
          _ordersFuture = Future.value([]); // Return an empty list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول لعرض طلباتك.')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching user ID for orders: $e');
      setState(() {
        _ordersFuture = Future.error('فشل تحميل الطلبات: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي السابقة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد طلبات سابقة.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16.0),
                    leading:
                        const Icon(Icons.receipt, color: Colors.blueAccent),
                    title: Text(
                      'طلب رقم: ${order.id.substring(0, 8)}...',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                            'التاريخ: ${order.orderDate.toLocal().toString().split(' ')[0]}'),
                        Text(
                            'الإجمالي: ${order.totalAmount.toStringAsFixed(2)} دينار'),
                        Text(
                          'الحالة: ${order.status}',
                          style: TextStyle(
                            color: order.status == 'Pending'
                                ? Colors.orange
                                : order.status == 'Delivered'
                                    ? Colors.green
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تفاصيل العميل:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text('الاسم: ${order.customerName}'),
                            Text('الهاتف: ${order.phoneNumber}'),
                            Text('العنوان: ${order.deliveryAddress}'),
                            const SizedBox(height: 10),
                            const Text(
                              'المنتجات المطلوبة:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (order.itemsOrdered.isEmpty)
                              const Text('لا توجد منتجات في هذا الطلب.')
                            else
                              ...order.itemsOrdered.map((item) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${item.name} x ${item.quantity}'),
                                      Text(
                                          '${item.price.toStringAsFixed(2)} دينار'),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
