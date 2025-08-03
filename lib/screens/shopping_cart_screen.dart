// lib/screens/shopping_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'customer_info_screen.dart';

class ShoppingCartScreen extends StatefulWidget {
  final String storeId; // **** اجعله String غير قابلة لـ null هنا ****

  // **** ويجب أن يكون مطلوباً في الكونستركتور ****
  const ShoppingCartScreen({super.key, required this.storeId});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
      ),
      body: cartProvider.itemCount == 0
          ? const Center(child: Text('سلة التسوق فارغة.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final cartItem =
                          cartProvider.items.values.elementAt(index);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  cartItem.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${cartItem.price.toStringAsFixed(2)} دينار',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                          onPressed: () {
                                            if (cartItem.quantity > 1) {
                                              cartProvider.updateItemQuantity(
                                                  cartItem.id,
                                                  cartItem.quantity - 1);
                                            } else {
                                              cartProvider
                                                  .removeItem(cartItem.id);
                                            }
                                          },
                                        ),
                                        Text('${cartItem.quantity}'),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          onPressed: () {
                                            cartProvider.updateItemQuantity(
                                                cartItem.id,
                                                cartItem.quantity + 1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cartProvider.removeItem(cartItem.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الإجمالي:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${cartProvider.totalPrice.toStringAsFixed(2)} دينار',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // إذا كان storeId مطلوبًا دائماً، لا داعي للتحقق من null هنا
                            // فقط تأكد أن السلة ليست فارغة
                            if (cartProvider.itemCount == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'الرجاء إضافة منتجات للسلة أولاً.')),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerInfoScreen(
                                  storeId: widget
                                      .storeId, // الآن widget.storeId هو String غير قابل للـ null
                                  onOrderPlaced: () {
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('تأكيد الطلب'),
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
              ],
            ),
    );
  }
}
