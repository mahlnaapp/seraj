// lib/models/category.dart
import 'package:appwrite/models.dart' show Document;

class Category {
  final String id;
  final String name;
  final String? imageUrl; // اختياري، إذا كان للتصنيفات صور

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Category.fromDocument(Document document) {
    final data = document.data;
    return Category(
      id: document.$id,
      name: data['name'] as String,
      imageUrl: data['imageUrl'] as String?, // تأكد من اسم الحقل في Appwrite
    );
  }
}
