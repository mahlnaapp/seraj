import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Map<String, dynamic>> _myOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? ordersJson = prefs.getString('my_local_orders');
      if (ordersJson != null && ordersJson.isNotEmpty) {
        final List<dynamic> decodedOrders = json.decode(ordersJson);
        setState(() {
          _myOrders = decodedOrders.cast<Map<String, dynamic>>();
          _myOrders.sort((a, b) => DateTime.parse(b['order_date']).compareTo(
              DateTime.parse(a['order_date']))); // ترتيب من الأحدث للأقدم
        });
      } else {
        _myOrders = [];
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل الطلبات: ${e.toString()}';
      });
      print('Error loading local orders: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الطلبات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrders,
            tooltip: 'تحديث الطلبات',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 80, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                )
              : _myOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt_outlined,
                              size: 100, color: Colors.grey[400]),
                          const SizedBox(height: 20),
                          Text(
                            'لم تقم بأي طلبات بعد.\nابـدأ بالتسوق الآن!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: _myOrders.length,
                      itemBuilder: (context, index) {
                        final order = _myOrders[index];
                        final List<dynamic> items =
                            order['items_ordered'] ?? [];
                        final DateTime orderDate =
                            DateTime.parse(order['order_date']);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0)),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              'طلب رقم: ${order['\$id'].substring(0, 8)}', // عرض جزء من الـ ID
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.black87),
                            ),
                            subtitle: Text(
                              'بتاريخ: ${orderDate.toLocal().toString().split(' ')[0]} | ${orderDate.toLocal().toString().split(' ')[1].substring(0, 5)}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                            trailing: Text(
                              '${order['total_price']?.toStringAsFixed(2) ?? ' '} دينار',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildOrderInfoRow(Icons.person_outline,
                                        'الاسم', order['customer_name']),
                                    _buildOrderInfoRow(Icons.phone_outlined,
                                        'الهاتف', order['phone_number']),
                                    _buildOrderInfoRow(
                                        Icons.location_on_outlined,
                                        'الموقع',
                                        order['location_details']),
                                    _buildOrderInfoRow(Icons.info_outline,
                                        'الحالة', order['status'],
                                        color:
                                            _getStatusColor(order['status'])),
                                    const Divider(height: 20, thickness: 1),
                                    const Text(
                                      'تفاصيل المنتجات:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87),
                                    ),
                                    const SizedBox(height: 8),
                                    ...items.map((item) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 6.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item['name']}',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey[800]),
                                                ),
                                              ),
                                              Text(
                                                'الكمية: ${item['quantity']} | السعر: ${item['price']?.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildOrderInfoRow(IconData icon, String label, String? value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value ?? 'غير متوفر',
              style: TextStyle(fontSize: 15, color: color ?? Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
