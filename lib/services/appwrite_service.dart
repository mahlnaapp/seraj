// lib/services/appwrite_service.dart
import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import '../models/order.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/category.dart' as app_category;

class AppwriteService {
  late Client client;
  late Databases databases;
  late Account account;

  String? _currentUserId;

  static final AppwriteService _instance = AppwriteService._internal();

  factory AppwriteService() {
    return _instance;
  }

  AppwriteService._internal() {
    client = Client()
        .setEndpoint('https://fra.cloud.appwrite.io/v1')
        .setProject('6887ee78000e74d711f1'); // ✅ تمت إزالة setSelfSigned

    databases = Databases(client);
    account = Account(client);
  }

  static AppwriteService get instance => _instance;

  Future<String> initUserSession() async {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      debugPrint('Existing user session found: $_currentUserId');
      return _currentUserId!;
    }

    try {
      User user = await account.get();
      _currentUserId = user.$id;
      debugPrint('Existing user session found: $_currentUserId');
      return _currentUserId!;
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        debugPrint(
            'No active user session found. Attempting anonymous login...');
        try {
          Session anonymousSession = await account.createAnonymousSession();
          _currentUserId = anonymousSession.userId;
          debugPrint('Anonymous user created: $_currentUserId');
          return _currentUserId!;
        } on AppwriteException catch (anonError) {
          debugPrint(
              'Failed to create anonymous session: ${anonError.message}');
          rethrow;
        }
      }
      debugPrint('Appwrite Service Error (initUserSession): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Service Error (initUserSession): $e');
      rethrow;
    }
  }

  Future<String> getUserId() async {
    return await initUserSession();
  }

  Future<Document> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await databases.createDocument(
        databaseId: 'mahllnadb',
        collectionId: 'orders',
        documentId: ID.unique(),
        data: orderData,
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(orderData['userId'])),
          Permission.delete(Role.user(orderData['userId'])),
        ],
      );
      return response;
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Service Error (createOrder): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Service Error (createOrder): $e');
      rethrow;
    }
  }

  Future<List<Store>> getAllStores() async {
    try {
      final DocumentList response = await databases.listDocuments(
        databaseId: 'mahllnadb',
        collectionId: 'Stores',
        queries: [
          Query.limit(100),
          Query.orderAsc('name'),
        ],
      );
      return response.documents.map((doc) => Store.fromDocument(doc)).toList();
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Service Error (getAllStores): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Service Error (getAllStores): $e');
      rethrow;
    }
  }

  Future<List<Store>> searchStores(String query) async {
    try {
      final DocumentList response = await databases.listDocuments(
        databaseId: 'mahllnadb',
        collectionId: 'Stores',
        queries: [
          Query.search('name', query),
          Query.limit(100),
          Query.orderAsc('name'),
        ],
      );
      return response.documents.map((doc) => Store.fromDocument(doc)).toList();
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Service Error (searchStores): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Service Error (searchStores): $e');
      rethrow;
    }
  }

  Future<List<app_category.Category>> getAllCategories() async {
    try {
      final DocumentList response = await databases.listDocuments(
        databaseId: 'mahllnadb',
        collectionId: 'categories',
        queries: [
          Query.limit(100),
          Query.orderAsc('name'),
        ],
      );
      return response.documents
          .map((doc) => app_category.Category.fromDocument(doc))
          .toList();
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Service Error (getAllCategories): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Service Error (getAllCategories): $e');
      rethrow;
    }
  }

  Future<List<Product>> getStoreProducts(
    String storeId, {
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      List<String> queries = [
        Query.equal('storeId', storeId),
        Query.limit(100),
        Query.orderAsc('name'),
      ];

      if (categoryId != null && categoryId.isNotEmpty) {
        queries.add(Query.equal('categoryId', categoryId));
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queries.add(Query.search('name', searchQuery));
      }

      final DocumentList response = await databases.listDocuments(
        databaseId: 'mahllnadb',
        collectionId: 'products',
        queries: queries,
      );
      return response.documents
          .map((doc) => Product.fromDocument(doc))
          .toList();
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Service Error (getStoreProducts): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Service Error (getStoreProducts): $e');
      rethrow;
    }
  }

  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final DocumentList response = await databases.listDocuments(
        databaseId: 'mahllnadb',
        collectionId: 'orders',
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('orderDate'),
          Query.limit(50),
        ],
      );
      return response.documents.map((doc) => Order.fromMap(doc.data)).toList();
    } on AppwriteException catch (e) {
      debugPrint('Appwrite Service Error (getUserOrders): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Service Error (getUserOrders): $e');
      rethrow;
    }
  }
}
