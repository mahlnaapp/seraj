// lib/widgets/store_card.dart
import 'package:flutter/material.dart';
import '../models/store.dart';
import '../screens/store_products_screen.dart'; // تأكد من استيراد هذه الشاشة

class StoreCard extends StatelessWidget {
  final Store store;

  const StoreCard({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoreProductsScreen(
                storeId: store.id, // store.id يجب أن يكون String غير null
                storeName: store.name, // store.name يجب أن يكون String غير null
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  store.imageUrl ??
                      'https://via.placeholder.com/100', // **** التعامل مع null ****
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.store,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.description ??
                          'لا يوجد وصف.', // **** التعامل مع null ****
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          store.isOpen ? Icons.check_circle : Icons.cancel,
                          color: store.isOpen ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.isOpen ? 'مفتوح الآن' : 'مغلق',
                          style: TextStyle(
                            color: store.isOpen ? Colors.green : Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
