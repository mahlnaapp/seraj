// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import '../models/store.dart';
import 'store_products_screen.dart';
import 'package:geolocator/geolocator.dart'; // **** تم إضافة هذا الاستيراد ****

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // تم تغيير النوع ليكون Future<List<Store>>? ليتيح قيمة null في البداية
  Future<List<Store>>? _storesFuture;
  Position? _currentPosition; // **** لتخزين موقع المستخدم الحالي ****
  final double _searchRadiusKm = 5.0; // **** نطاق البحث بالكيلومتر (5 كم) ****

  @override
  void initState() {
    super.initState();
    _fetchLocationAndStores(); // **** استدعاء الدالة الجديدة عند تهيئة الشاشة ****
  }

  // **** دالة لجلب موقع المستخدم وتصفية المتاجر ****
  Future<void> _fetchLocationAndStores() async {
    // 1. طلب الإذن والتحقق من خدمات الموقع
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // خدمات الموقع غير مفعلة، قم بإبلاغ المستخدم
      _showSnackBar(
          'خدمات الموقع غير مفعلة. يرجى تفعيلها لعرض المتاجر القريبة.',
          isError: true);
      setState(() {
        _storesFuture = Future.value([]); // عرض قائمة فارغة
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // الأذونات مرفوضة
        _showSnackBar('تم رفض أذونات الموقع. لن يتم عرض المتاجر القريبة.',
            isError: true);
        setState(() {
          _storesFuture = Future.value([]); // عرض قائمة فارغة
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // الأذونات مرفوضة بشكل دائم
      _showSnackBar(
          'تم رفض أذونات الموقع بشكل دائم. يرجى تفعيلها من إعدادات التطبيق لعرض المتاجر القريبة.',
          isError: true);
      setState(() {
        _storesFuture = Future.value([]); // عرض قائمة فارغة
      });
      return;
    }

    // 2. الحصول على الموقع الحالي
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      debugPrint(
          'Current Location: Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}');
      _showSnackBar('تم تحديد موقعك بنجاح. يتم عرض المتاجر القريبة.');
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showSnackBar('تعذر الحصول على موقعك الحالي. سأعرض جميع المتاجر المتاحة.',
          isError: true);
      _currentPosition =
          null; // إذا فشل الحصول على الموقع، لا نستخدم التصفية بالموقع
    }

    // 3. جلب جميع المتاجر ثم تصفيتها بناءً على الموقع (إذا كان متاحًا)
    setState(() {
      _storesFuture = _filterStoresByLocation();
    });
  }

  // **** دالة مساعدة لتصفية المتاجر بناءً على الموقع ****
  Future<List<Store>> _filterStoresByLocation() async {
    final allStores =
        await AppwriteService.instance.getAllStores(); // جلب جميع المتاجر

    if (_currentPosition == null) {
      // إذا لم يكن هناك موقع للمستخدم، أعد جميع المتاجر
      return allStores;
    }

    final filteredStores = <Store>[];
    for (var store in allStores) {
      // تأكد أن للمتجر إحداثيات موقع
      if (store.latitude != null && store.longitude != null) {
        double distanceInMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          store.latitude!,
          store.longitude!,
        );
        double distanceInKm = distanceInMeters / 1000;

        // إذا كانت المسافة ضمن النطاق المطلوب
        if (distanceInKm <= _searchRadiusKm) {
          filteredStores.add(store);
        }
      }
    }
    return filteredStores;
  }

  // دالة مساعدة لعرض SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتاجر المتاحة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _storesFuture =
                    null; // إعادة تعيين Future لإعادة عرض مؤشر التحميل
                _currentPosition = null; // مسح الموقع الحالي لإعادة جلبه
                _fetchLocationAndStores(); // إعادة جلب الموقع والمتاجر
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Store>>(
        future: _storesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('خطأ في تحميل المتاجر: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لا توجد متاجر متاحة حالياً ضمن النطاق المحدد.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _storesFuture = null;
                        _currentPosition = null;
                        _fetchLocationAndStores(); // محاولة إعادة جلب الموقع والمتاجر
                      });
                    },
                    child: const Text('إعادة المحاولة / تحديث'),
                  ),
                ],
              ),
            );
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
                      backgroundImage: NetworkImage(
                          store.imageUrl ?? 'https://via.placeholder.com/100'),
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint(
                            'Error loading image for ${store.name}: $exception');
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
                        Text(
                          store.description ?? 'لا يوجد وصف.', // قيمة افتراضية
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              store.isOpen ? Icons.check_circle : Icons.cancel,
                              color: store.isOpen ? Colors.green : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              store.isOpen ? 'مفتوح' : 'مغلق',
                              style: TextStyle(
                                color: store.isOpen ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // عرض المسافة إذا كان الموقع متاحًا للمستخدم والمتجر
                            if (_currentPosition != null &&
                                store.latitude != null &&
                                store.longitude != null) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.location_on,
                                  size: 18, color: Colors.grey[600]),
                              Text(
                                '${(Geolocator.distanceBetween(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                      store.latitude!,
                                      store.longitude!,
                                    ) / 1000).toStringAsFixed(1)} كم', // عرض المسافة بالكيلومتر
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
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
                        _showSnackBar('عذراً، هذا المتجر مغلق حالياً.',
                            isError: true);
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
