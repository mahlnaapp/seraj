// lib/services/offline_order_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seraj/models/order.dart'; // تأكد أن 'seraj' هو اسم مشروعك
import 'dart:convert'; // لاستخدام json.encode و json.decode

class OfflineOrderStorageService {
  static const String _ordersListKey =
      'customerOrders'; // مفتاح لحفظ قائمة الطلبات

  // دالة لحفظ قائمة من الطلبات
  Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    // نحول كل كائن طلب إلى نص JSON ثم نضعها في قائمة من النصوص
    final List<String> ordersJsonList =
        orders.map((order) => order.toJson()).toList();
    await prefs.setStringList(_ordersListKey, ordersJsonList);
    print('تم حفظ ${orders.length} طلب أوفلاين.');
  }

  // دالة لاسترجاع جميع الطلبات المحفوظة
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? ordersJsonList = prefs.getStringList(_ordersListKey);

    if (ordersJsonList != null) {
      // نحول كل نص JSON إلى كائن Order ثم نضعها في قائمة من كائنات Order
      return ordersJsonList
          .map((jsonString) => Order.fromJson(jsonString))
          .toList();
    }
    return []; // إذا لم تكن هناك طلبات محفوظة، نرجع قائمة فارغة
  }

  // دالة لإضافة طلب جديد إلى القائمة الموجودة وحفظها مرة أخرى
  Future<void> addOrder(Order newOrder) async {
    List<Order> existingOrders = await getOrders(); // استرجاع الطلبات الموجودة
    existingOrders.add(newOrder); // إضافة الطلب الجديد
    await saveOrders(existingOrders); // حفظ القائمة المحدثة
  }

  // دالة لمسح جميع الطلبات المحفوظة (إذا أردت ذلك)
  Future<void> clearAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersListKey);
    print('تم مسح جميع الطلبات الأوفلاين.');
  }
}
