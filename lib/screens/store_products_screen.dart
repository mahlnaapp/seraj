// lib/screens/store_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/appwrite_service.dart';
import '../models/product.dart';
import '../models/category.dart'; // **** جديد: استيراد موديل Category ****
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import 'shopping_cart_screen.dart';

class StoreProductsScreen extends StatefulWidget {
  final String storeId;
  final String storeName;

  const StoreProductsScreen(
      {super.key, required this.storeId, required this.storeName});

  @override
  State<StoreProductsScreen> createState() => _StoreProductsScreenState();
}

class _StoreProductsScreenState extends State<StoreProductsScreen> {
  // **** متغيرات الحالة الجديدة ****
  late Future<List<Product>> _productsFuture;
  late Future<List<Category>> _categoriesFuture;
  String? _selectedCategoryId; // لتتبع التصنيف المختار
  final TextEditingController _searchController =
      TextEditingController(); // للبحث
  final ScrollController _scrollController =
      ScrollController(); // للتمرير التلقائي للتصنيفات

  List<Product> _allProducts = []; // لتخزين جميع المنتجات قبل الفلترة
  List<Product> _filteredProducts = []; // لتخزين المنتجات بعد الفلترة والبحث

  @override
  void initState() {
    super.initState();
    _fetchData(); // جلب المنتجات والتصنيفات عند بدء الشاشة

    // إضافة مستمع للتحكم في تحديد التصنيف بناءً على التمرير
    _scrollController.addListener(_scrollListener);
  }

  // **** دالة لجلب المنتجات والتصنيفات ****
  void _fetchData() {
    _categoriesFuture = AppwriteService.instance.getAllCategories();
    // جلب المنتجات بدون فلترة أولية عند التحميل
    _productsFuture = AppwriteService.instance
        .getStoreProducts(widget.storeId)
        .then((products) {
      _allProducts = products;
      _applyFilters(); // تطبيق الفلترة الأولية (لا شيء)
      return products;
    });
  }

  // **** دالة لتطبيق الفلترة والبحث ****
  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesCategory = _selectedCategoryId == null ||
            _selectedCategoryId == 'all' || // 'all' هو تصنيف وهمي لكل المنتجات
            product.categoryId == _selectedCategoryId;

        final matchesSearch = _searchController.text.isEmpty ||
            product.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  // **** دالة لتحديث المنتجات عند تغيير التصنيف أو البحث ****
  void _refreshProducts({String? categoryId, String? searchQuery}) {
    setState(() {
      _selectedCategoryId = categoryId;
      _searchController.text = searchQuery ?? _searchController.text;
      _applyFilters();
    });
  }

  // **** مستمع التمرير التلقائي (لشريط التصنيفات) ****
  void _scrollListener() {
    // هذا الجزء معقد ويتطلب ربط مواقع المنتجات بالتصنيفات.
    // لتبسيط الأمر، لنقوم بتطبيق التمرير التلقائي للتصنيفات عند التمرير إلى منتجاتها.
    // هذه ميزة متقدمة وتتطلب حسابات دقيقة لارتفاعات العناصر.
    // سنقوم بتضمينها هنا كمثال، ولكن قد تحتاج إلى تعديلات دقيقة.

    // مثال بسيط: يمكننا تحديث _selectedCategoryId بناءً على أول منتج مرئي
    // ولكن لضبطه بدقة، ستحتاج إلى ScrollablePositionedList أو قياسات دقيقة.
    // حالياً، لن أدمج التمرير التلقائي للتصنيفات لأنه سيعقد الكود بشكل كبير دون معرفة هيكل بيانات المنتجات والتصنيفات التفصيلي.
    // سنركز على ميزة النقر للفلترة أولاً.
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // **** SliverAppBar الرئيسي (مع شريط البحث) ****
          SliverAppBar(
            title: Text('منتجات ${widget.storeName}'),
            pinned: true, // يثبت الـ AppBar في الأعلى
            floating: true, // يظهر الـ AppBar عندما تبدأ بالتمرير للأعلى
            snap: true, // يكمل الظهور/الاختفاء بسرعة
            expandedHeight: 120.0, // ارتفاع أكبر لاستيعاب شريط البحث
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'البحث عن منتج...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {
                    _refreshProducts(searchQuery: value);
                  },
                ),
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShoppingCartScreen(storeId: widget.storeId),
                        ),
                      );
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartProvider.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // **** شريط التصنيفات (مثبت أيضاً) ****
          FutureBuilder<List<Category>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )));
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                    child: Center(
                        child:
                            Text('خطأ في تحميل التصنيفات: ${snapshot.error}')));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('لا توجد تصنيفات حالياً.'),
                )));
              } else {
                final categories = snapshot.data!;
                // إضافة تصنيف "الكل" للسماح بعرض جميع المنتجات
                final allCategories = [
                  Category(id: 'all', name: 'الكل', imageUrl: null),
                  ...categories
                ];

                return SliverPersistentHeader(
                  delegate: _CategorySelectionHeaderDelegate(
                    categories: allCategories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (categoryId) {
                      _refreshProducts(
                          categoryId: categoryId,
                          searchQuery:
                              null); // إعادة ضبط البحث عند تغيير التصنيف
                    },
                  ),
                  pinned: true, // يثبت شريط التصنيفات أسفل الـ AppBar
                );
              }
            },
          ),

          // **** قائمة المنتجات ****
          FutureBuilder<List<Product>>(
            future:
                _productsFuture, // ما زلنا نستخدم هذا الـ Future الأصلي لجلب الكل
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                    child: Center(
                        child:
                            Text('خطأ في تحميل المنتجات: ${snapshot.error}')));
              } else if (!snapshot.hasData || _filteredProducts.isEmpty) {
                // نستخدم _filteredProducts هنا
                return const SliverFillRemaining(
                    child: Center(
                        child:
                            Text('لا توجد منتجات مطابقة للمعايير المحددة.')));
              } else {
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product =
                          _filteredProducts[index]; // نستخدم المنتجات المفلترة
                      final bool isInCart =
                          cartProvider.items.containsKey(product.id);

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
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
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
                                        product.isAvailable
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: product.isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.isAvailable
                                            ? 'متوفر'
                                            : 'غير متوفر',
                                        style: TextStyle(
                                          color: product.isAvailable
                                              ? Colors.green
                                              : Colors.red,
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
                                                cartProvider
                                                    .removeItem(product.id);
                                              } else {
                                                cartProvider.addItem(
                                                  CartItem(
                                                    id: product.id,
                                                    name: product.name,
                                                    price: product.price,
                                                    quantity: 1,
                                                    imageUrl: product.imageUrl,
                                                    storeId: product.storeId,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                      ),
                                      child: Text(isInCart
                                          ? 'إزالة من السلة'
                                          : 'إضافة إلى السلة'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _filteredProducts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// **** SliverPersistentHeaderDelegate لتثبيت شريط التصنيفات ****
class _CategorySelectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const _CategorySelectionHeaderDelegate({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // خلفية لضمان الوضوح
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category.id);
                } else {
                  onCategorySelected(null); // لإلغاء التحديد وعرض الكل
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.grey[200],
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 70.0; // ارتفاع شريط التصنيفات
  @override
  double get minExtent => 70.0; // ارتفاع شريط التصنيفات
  @override
  bool shouldRebuild(_CategorySelectionHeaderDelegate oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.selectedCategoryId != selectedCategoryId ||
        oldDelegate.onCategorySelected != onCategorySelected;
  }
}
