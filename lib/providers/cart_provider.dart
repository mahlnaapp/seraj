// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
// import 'package:collection/collection.dart'; // هذا الاستيراد قد لا يكون ضرورياً إذا لم تستخدم firstWhereOrNull

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.values
      .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  void addItem(CartItem item) {
    if (_items.containsKey(item.id)) {
      _items.update(
          item.id,
          (existingItem) => CartItem(
                id: existingItem.id,
                name: existingItem.name,
                price: existingItem.price,
                quantity: existingItem.quantity + item.quantity,
                imageUrl: existingItem.imageUrl,
                storeId:
                    existingItem.storeId, // **** الآن هذه الخاصية موجودة ****
              ));
    } else {
      _items[item.id] = item;
    }
    notifyListeners();
    debugPrint(
        'Item added: ${item.name}, Total items: $itemCount, Total price: $totalPrice');
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
    debugPrint(
        'Item removed: $productId, Total items: $itemCount, Total price: $totalPrice');
  }

  void updateItemQuantity(String productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      if (newQuantity <= 0) {
        removeItem(productId);
      } else {
        _items.update(
            productId,
            (existingItem) => CartItem(
                  id: existingItem.id,
                  name: existingItem.name,
                  price: existingItem.price,
                  quantity: newQuantity,
                  imageUrl: existingItem.imageUrl,
                  storeId:
                      existingItem.storeId, // **** الآن هذه الخاصية موجودة ****
                ));
        notifyListeners();
      }
      debugPrint('Item quantity updated for $productId to $newQuantity');
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    debugPrint('Cart cleared');
  }
}
