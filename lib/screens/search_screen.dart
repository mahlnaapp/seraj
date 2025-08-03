// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import '../models/store.dart';
import 'store_products_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Store>>? _searchResults;

  @override
  void initState() {
    super.initState();
    // يمكنك تعيين _searchResults لجميع المتاجر في البداية إذا أردت
    // _searchResults = AppwriteService.instance.getAllStores();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
      });
      return;
    }
    setState(() {
      _searchResults = AppwriteService.instance.searchStores(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث عن المتاجر'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن متجر...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: _performSearch,
              onChanged: _performSearch,
            ),
          ),
        ),
      ),
      body: _searchResults == null
          ? const Center(child: Text('ابدأ البحث عن المتاجر.'))
          : FutureBuilder<List<Store>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('خطأ في البحث: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد نتائج للبحث.'));
                } else {
                  final stores = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: CircleAvatar(
                            // **** التعديل في السطر 92 ****
                            backgroundImage: NetworkImage(store.imageUrl ??
                                'https://via.placeholder.com/100'),
                            onBackgroundImageError: (exception, stackTrace) {
                              // يمكنك إضافة منطق للتعامل مع أخطاء تحميل الصورة هنا
                              debugPrint('Error loading image: $exception');
                            },
                            radius: 30,
                          ),
                          title: Text(
                            store.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // **** التعديل في السطر 106 ****
                              Text(
                                store.description ??
                                    'لا يوجد وصف.', // قيمة افتراضية
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    store.isOpen
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: store.isOpen
                                        ? Colors.green
                                        : Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    store.isOpen ? 'مفتوح' : 'مغلق',
                                    style: TextStyle(
                                      color: store.isOpen
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            if (store.isOpen) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoreProductsScreen(
                                      storeId: store.id, storeName: store.name),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('عذراً، هذا المتجر مغلق حالياً.')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
