// lib/models/product.dart
import 'package:appwrite/models.dart' show Document;

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String storeId;
  final String categoryId; // **** تأكد من وجود هذا الحقل ****
  final bool isAvailable; // **** تأكد من وجود هذا الحقل ****

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.storeId,
    required this.categoryId,
    required this.isAvailable, // **** أضف هذا في constructor ****
  });

  factory Product.fromDocument(Document document) {
    final data = document.data;
    return Product(
      id: document.$id,
      name: data['name'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] as String,
      storeId: data['storeId'] as String,
      categoryId: data['categoryId']
          as String, // **** تأكد من اسم الحقل في Appwrite ****
      isAvailable: data['isAvailable']
          as bool, // **** تأكد من اسم الحقل في Appwrite كـ Boolean ****
    );
  }

  // إذا كنت تحتاج إلى toMap أو toJson
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'storeId': storeId,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
    };
  }
}
