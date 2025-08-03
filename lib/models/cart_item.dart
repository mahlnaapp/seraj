// lib/models/cart_item.dart
import 'dart:convert'; // استيراد لـ jsonEncode/decode إذا كنت ستستخدمها مباشرة

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;
  final String storeId;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.storeId,
  });

  // **** تغيير toMap() إلى toJson() ****
  String toJson() {
    return jsonEncode({
      // استخدام jsonEncode لتحويل الـ Map إلى String JSON
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'storeId': storeId,
    });
  }

  // **** تغيير fromMap() إلى fromJson() ****
  factory CartItem.fromJson(String source) {
    final Map<String, dynamic> map = jsonDecode(source) as Map<String,
        dynamic>; // استخدام jsonDecode لتحويل String JSON إلى Map
    return CartItem(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      imageUrl: map['imageUrl'] as String,
      storeId: map['storeId'] as String,
    );
  }

  // إذا كنت تريد أيضاً دالة لتحويل من/إلى Map (ليست JSON String)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'storeId': storeId,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      imageUrl: map['imageUrl'] as String,
      storeId: map['storeId'] as String,
    );
  }
}
