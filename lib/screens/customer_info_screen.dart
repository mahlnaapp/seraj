// lib/screens/customer_info_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // لاستخدام jsonEncode

// تم إزالة استيراد 'package:uuid/uuid.dart'
import '../providers/cart_provider.dart';
import '../services/appwrite_service.dart';
// تم إزالة استيراد '../models/order.dart';
// تم إزالة استيراد '../services/offline_order_storage_service.dart';

// يجب أن تظل لديك CartItem إذا كنت تستخدم سلة التسوق

class CustomerInfoScreen extends StatefulWidget {
  final String storeId;
  final VoidCallback onOrderPlaced;

  const CustomerInfoScreen(
      {super.key, required this.storeId, required this.onOrderPlaced});

  @override
  State<CustomerInfoScreen> createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  // تم إزالة تهيئة Uuid و OfflineOrderStorageService

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final appwriteService = AppwriteService.instance;

    // تم إزالة كل ما يتعلق بإنشاء كائن Order محليًا
    // وتم إزالة كل ما يتعلق بحفظ الطلب في التخزين الأوفلاين

    // محاولة إرسال الطلب إلى Appwrite مباشرة (كما كان في الأصل)
    try {
      final userId = await appwriteService.getUserId(); // الحصول على userId

      if (userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('خطأ: لا يمكن إتمام الطلب بدون معرف مستخدم.')),
          );
        }
        return;
      }

      // تحويل قائمة CartItem إلى List<Map<String, dynamic>> ثم إلى JSON string
      // هذا الجزء مطلوب لإرسال البيانات إلى Appwrite لأنك خزنتها كـ String في Appwrite
      final itemsOrderedJson = jsonEncode(
          cartProvider.items.values.map((item) => item.toMap()).toList());

      final orderData = {
        'userId': userId,
        'storeId': widget.storeId, // إضافة storeId هنا
        'customer_name': _nameController.text,
        'phone_number': _phoneController.text,
        'delivery_address': _addressController.text,
        'items_ordered': itemsOrderedJson, // استخدام String JSON هنا
        'total_amount': cartProvider.totalPrice,
        'order_date': DateTime.now().toIso8601String(), // تاريخ ووقت الطلب
        'status': 'Pending', // الحالة الأولية للطلب
        'notes':
            _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      // إرسال الطلب إلى Appwrite
      await appwriteService.createOrder(orderData);

      cartProvider.clearCart(); // مسح السلة بعد نجاح الطلب

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تأكيد الطلب بنجاح!')),
        );
        widget.onOrderPlaced(); // استدعاء الدالة عند إتمام الطلب
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تأكيد الطلب: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات العميل وتأكيد الطلب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تفاصيل الطلب:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.items.values.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.name} x ${item.quantity}'),
                        Text(
                            '${(item.price * item.quantity).toStringAsFixed(2)} دينار'),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الإجمالي الكلي:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${cartProvider.totalPrice.toStringAsFixed(2)} دينار',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'معلومات العميل:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم الكامل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'عنوان التوصيل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان التوصيل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات إضافية (اختياري)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _placeOrder,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('تأكيد الطلب والدفع'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
