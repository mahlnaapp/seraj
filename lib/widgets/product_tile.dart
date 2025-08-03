// lib/widgets/product_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final String storeId; // **** إضافة هذا المعامل المطلوب ****

  const ProductTile({
    super.key,
    required this.product,
    required this.storeId, // **** جعله مطلوباً في الكونستركتور ****
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final bool isInCart = cartProvider.items.containsKey(product.id);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price.toStringAsFixed(2)} دينار',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      product.isAvailable ? Icons.check_circle : Icons.cancel,
                      color: product.isAvailable ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.isAvailable ? 'متوفر' : 'غير متوفر',
                      style: TextStyle(
                        color: product.isAvailable ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.isAvailable
                        ? () {
                            if (isInCart) {
                              cartProvider.removeItem(product.id);
                            } else {
                              cartProvider.addItem(
                                CartItem(
                                  id: product.id,
                                  name: product.name,
                                  price: product.price,
                                  quantity: 1,
                                  imageUrl: product.imageUrl,
                                  storeId:
                                      storeId, // **** تمرير storeId هنا ****
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCart
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child:
                        Text(isInCart ? 'إزالة من السلة' : 'إضافة إلى السلة'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
