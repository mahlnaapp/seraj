// lib/models/order.dart
import 'dart:convert';
import 'package:appwrite/models.dart' show Document;
import 'cart_item.dart'; // تأكد من استيراد CartItem

class Order {
  final String id;
  final String userId;
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final List<CartItem> itemsOrdered; // يجب أن يكون هذا List<CartItem>
  final double totalAmount;
  final DateTime orderDate;
  final String status;
  final String? notes; // يمكن أن يكون null

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.itemsOrdered,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    this.notes,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    List<CartItem> parsedItems = [];
    if (map['items_ordered'] is String &&
        (map['items_ordered'] as String).isNotEmpty) {
      try {
        final List<dynamic> itemsJson = json.decode(map['items_ordered']);
        parsedItems = itemsJson
            .map((itemMap) => CartItem.fromMap(itemMap as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error decoding items_ordered from String: $e');
        parsedItems = [];
      }
    } else if (map['items_ordered'] is List) {
      // إذا كانت بالفعل قائمة (مباشرة من Appwrite مثلاً أو من Test)
      parsedItems = (map['items_ordered'] as List)
          .map((itemMap) => CartItem.fromMap(itemMap as Map<String, dynamic>))
          .toList();
    } else {
      // التعامل مع الحالات التي قد تكون فيها القيمة null أو نوع غير متوقع
      print(
          'Warning: items_ordered is not String or List: ${map['items_ordered'].runtimeType}');
      parsedItems = [];
    }

    return Order(
      id: map['\$id'] as String,
      userId: map['userId'] as String,
      customerName: map['customer_name'] as String,
      phoneNumber: map['phone_number'] as String,
      deliveryAddress: map['delivery_address'] as String,
      itemsOrdered: parsedItems,
      totalAmount: (map['total_amount'] as num).toDouble(),
      orderDate: DateTime.parse(map['order_date'] as String),
      status: map['status'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // لا نضع '\$id' هنا عند الإرسال إلى Appwrite لأنه يتم إنشاؤه هناك.
      // ولكن عند الحفظ محليًا، يمكننا تضمينه إذا كنا نريد حفظ الـ ID من Appwrite.
      // بما أننا نحفظ أوفلاين، سنستخدم نفس الـ ID الذي استلمناه أو نولده.
      // لغرض الحفظ في shared_preferences، نضمن وجود الـ ID
      'id':
          id, // نستخدم 'id' بدلاً من '\$id' لتجنب المشاكل في shared_preferences
      'userId': userId,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'delivery_address': deliveryAddress,
      'items_ordered': json.encode(itemsOrdered
          .map((item) => item.toMap())
          .toList()), // تحويل CartItem إلى Map ثم إلى JSON String
      'total_amount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  // **** إضافة دالتين toJson و fromJson بشكل صريح ****
  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  // دالة تحويل من Document (من Appwrite) إلى Order
  factory Order.fromDocument(Document document) {
    // تأكد من أن الـ ID موجود دائمًا
    final data = document.data;
    data['\$id'] = document.$id; // أضف الـ ID المستلم من Appwrite إلى الـ Map
    return Order.fromMap(data);
  }
}
