// lib/models/store.dart
import 'package:appwrite/models.dart';

class Store {
  final String id;
  final String name;
  final String? imageUrl; // يمكن أن يكون null
  final String? description; // يمكن أن يكون null
  final String? categoryId; // يمكن أن يكون null
  final String? address; // يمكن أن يكون null
  final bool isOpen;
  final double? latitude; // **** أضف هذا ****
  final double? longitude; // **** أضف هذا ****

  Store({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.categoryId,
    this.address,
    required this.isOpen,
    this.latitude, // **** أضف هذا ****
    this.longitude, // **** أضف هذا ****
  });

  factory Store.fromDocument(Document document) {
    return Store(
      id: document.$id,
      name: document.data['name'] as String,
      imageUrl: document.data['imageUrl'] as String?,
      description: document.data['description'] as String?,
      categoryId: document.data['categoryId'] as String?,
      address: document.data['address'] as String?,
      isOpen: document.data['isOpen'] as bool,
      latitude: (document.data['latitude'] as num?)
          ?.toDouble(), // **** تأكد من التحويل لـ double? ****
      longitude: (document.data['longitude'] as num?)
          ?.toDouble(), // **** تأكد من التحويل لـ double? ****
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'categoryId': categoryId,
      'address': address,
      'isOpen': isOpen,
      'latitude': latitude, // **** أضف هذا ****
      'longitude': longitude, // **** أضف هذا ****
    };
  }
}
