import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/imagekit_config.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/unified_cart_service.dart';
import 'cart_screen.dart';
import 'pharmacy_detail_screen.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class PharmacyMarketplaceScreen extends StatefulWidget {
  const PharmacyMarketplaceScreen({super.key});
  @override
  State<PharmacyMarketplaceScreen> createState() =>
      _PharmacyMarketplaceScreenState();
}

class _PharmacyMarketplaceScreenState extends State<PharmacyMarketplaceScreen>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  final _cart = UnifiedCartService.instance;
  late final TabController _tabController;
  bool _loading = true;
  String? _error;
  int _tab = 0;
  String _category = 'الكل';
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _pharmacies = [];
  List<Map<String, dynamic>> _orders = [];

  static const _tabLabels = ['متاجر مميزة', 'المنتجات', 'العروض', 'الطلبات'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _tab = _tabController.index;
        _category = 'الكل';
      });
      if (_tab == 3) _loadOrders();
    });
    _search.addListener(_refresh);
    _loadAll();
  }

  @override
  void dispose() {
    _search.removeListener(_refresh);
    _search.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('products')
            .where('approvalStatus', isEqualTo: 'approved')
            .where('isPublished', isEqualTo: true)
            .where('isActive', isEqualTo: true)
            .limit(300)
            .get(),
        FirebaseFirestore.instance.collection('pharmacies').limit(100).get(),
      ]);
      _products = (results[0] as QuerySnapshot<Map<String, dynamic>>)
          .docs
          .map((d) => {...d.data(), 'id': d.id})
          .toList();
      _pharmacies = (results[1] as QuerySnapshot<Map<String, dynamic>>)
          .docs
          .map((d) => {...d.data(), 'id': d.id})
          .toList();
      _pharmacies.sort((a, b) => ((b['rating'] as num?)?.toDouble() ?? 0)
          .compareTo((a['rating'] as num?)?.toDouble() ?? 0));
      if (mounted) setState(() => _error = null);
      if (_tab == 3) await _loadOrders();
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحميل بيانات الصيدلية حالياً');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _orders = []);
      return;
    }
    try {
      final orders = await OrderService.getUserOrders(user.uid);
      if (!mounted) return;
      setState(() => _orders = orders.map((o) => o.toJson()).toList());
    } catch (_) {
      if (mounted) setState(() => _orders = []);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<String> get _categories {
    if (_tab == 0) return const ['الكل', 'مفتوحة الآن', 'توصيل'];
    if (_tab == 3)
      return const ['الكل', 'جديد', 'قيد التجهيز', 'قيد التوصيل', 'مكتمل'];
    final values = _products
        .map((p) => '${p['category'] ?? ''}'.trim())
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['الكل', ...values];
  }

  String _searchText(Map<String, dynamic> p) => [
        p['name'],
        p['genericName'],
        p['activeIngredient'],
        p['category'],
        p['sellerName'],
        p['companyName']
      ].map((v) => '${v ?? ''}').join(' ').toLowerCase();

  List<Map<String, dynamic>> get _visibleProducts {
    final q = _search.text.trim().toLowerCase();
    return _products
        .where((p) =>
            (_category == 'الكل' || '${p['category'] ?? ''}' == _category) &&
            (q.isEmpty || _searchText(p).contains(q)))
        .toList();
  }

  List<Map<String, dynamic>> get _offers => _products.where((p) {
        final hasDiscount = p['isOffer'] == true ||
            p['discountPrice'] != null ||
            p['offerPrice'] != null ||
            p['discount'] != null ||
            p['discountPercent'] != null;
        final categoryOk =
            _category == 'الكل' || '${p['category'] ?? ''}' == _category;
        final q = _search.text.trim().toLowerCase();
        return hasDiscount &&
            categoryOk &&
            (q.isEmpty || _searchText(p).contains(q));
      }).toList();

  List<Map<String, dynamic>> get _visiblePharmacies {
    final q = _search.text.trim().toLowerCase();
    return _pharmacies.where((p) {
      final open = p['isOpen'] == true || p['openNow'] == true;
      final delivery = p['deliveryAvailable'] == true ||
          p['hasDelivery'] == true ||
          p['delivery'] == true;
      final categoryOk = _category == 'الكل' ||
          (_category == 'مفتوحة الآن' && open) ||
          (_category == 'توصيل' && delivery);
      final text = '${p['name'] ?? ''} ${p['address'] ?? ''} ${p['city'] ?? ''}'
          .toLowerCase();
      return categoryOk && (q.isEmpty || text.contains(q));
    }).toList();
  }

  List<Map<String, dynamic>> get _visibleOrders {
    final q = _search.text.trim().toLowerCase();
    return _orders.where((o) {
      final statusText = _statusLabel('${o['status'] ?? ''}');
      final categoryOk = _category == 'الكل' || statusText == _category;
      final text =
          '${o['id'] ?? ''} ${o['orderId'] ?? ''} ${o['providerName'] ?? ''} ${o['pharmacyName'] ?? ''}'
              .toLowerCase();
      return categoryOk && (q.isEmpty || text.contains(q));
    }).toList();
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'new':
        return 'جديد';
      case 'processing':
      case 'preparing':
        return 'قيد التجهيز';
      case 'shipped':
      case 'out_for_delivery':
      case 'delivering':
        return 'قيد التوصيل';
      case 'completed':
      case 'delivered':
        return 'مكتمل';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  void _add(Map<String, dynamic> p) {
    final id = '${p['productId'] ?? p['id'] ?? ''}';
    final price = (p['price'] as num?)?.toDouble() ?? 0;
    final stock = (p['stock'] as num?)?.toInt() ?? 0;
    if (id.isEmpty || price <= 0 || stock <= 0) return;
    _cart.add(
        productId: id,
        name: '${p['name'] ?? 'منتج'}',
        unitPrice: price,
        requiresPrescription: p['requiresPrescription'] == true);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة المنتج إلى السلة')));
  }

  double? _oldPrice(Map<String, dynamic> p) {
    final v = p['oldPrice'] ?? p['originalPrice'];
    return v is num ? v.toDouble() : double.tryParse('${v ?? ''}');
  }

  double? _offerPrice(Map<String, dynamic> p) {
    final v = p['offerPrice'] ?? p['discountPrice'];
    return v is num ? v.toDouble() : double.tryParse('${v ?? ''}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(34))),
        title: const Text('صيدلية صحتك',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: Image.asset('assets/icons/top_bar/notifications.png', width: 24, height: 24),
              onPressed: () => Navigator.pushNamed(context, '/notifications')),
          Stack(children: [
            IconButton(
                icon: Image.asset('assets/icons/top_bar/Shopping cart.png', width: 24, height: 24),
                onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CartScreen())).then((_) {
                      if (mounted) setState(() {});
                    })),
            if (_cart.itemCount > 0)
              Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.red,
                      child: Text('${_cart.itemCount}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9)))),
          ]),
        ],
      ),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: UnifiedSearchBar(controller: _search, hintText: 'ابحث عن دواء، منتج، أو صيدلية')),
        TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: _tabLabels.map((t) => Tab(text: t)).toList()),
        SizedBox(
            height: 48,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 7),
                itemBuilder: (_, i) {
                  final c = _categories[i];
                  return ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c));
                })),
        Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorView()
                    : TabBarView(controller: _tabController, children: [
                        _storesTab(),
                        _productsTab(),
                        _offersTab(),
                        _ordersTab()
                      ])),
      ]),
    );
  }

  Widget _errorView() => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: _loadAll, child: const Text('إعادة المحاولة'))
      ]));

  Widget _storesTab() {
    final stores = _visiblePharmacies;
    if (stores.isEmpty)
      return const Center(
          child: Text('لا توجد صيدليات منشورة تطابق البحث حالياً'));
    return RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stores.length,
            itemBuilder: (_, i) {
              final p = stores[i];
              final open = p['isOpen'] == true || p['openNow'] == true;
              final delivery = p['deliveryAvailable'] == true ||
                  p['hasDelivery'] == true ||
                  p['delivery'] == true;
              return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                      isThreeLine: true,
                      leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(.1),
                          child: SvgPicture.asset('assets/icons/map_pins/pharmacy.svg', width: 28, height: 28)),
                      title: Text('${p['name'] ?? 'صيدلية'}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${p['address'] ?? p['city'] ?? 'الموقع غير محدد'}\n${open ? 'مفتوحة الآن' : 'مغلقة'} • ${delivery ? 'توصيل متاح' : 'التوصيل غير متاح'}'),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PharmacyDetailScreen(pharmacy: p)))));
            }));
  }

  Widget _productsTab() => _productList(
      _visibleProducts, 'لا توجد منتجات منشورة تطابق البحث حالياً');
  Widget _offersTab() => _productList(_offers, 'لا توجد عروض منشورة حالياً');

  Widget _productList(List<Map<String, dynamic>> products, String empty) {
    if (products.isEmpty) return Center(child: Text(empty));
    return RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (_, i) => _productCard(products[i])));
  }

  Widget _productCard(Map<String, dynamic> p) {
    final stock = (p['stock'] as num?)?.toInt() ?? 0;
    final offer = _offerPrice(p);
    final old = _oldPrice(p);
    final price = offer ?? (p['price'] as num?)?.toDouble() ?? 0;
    final available = stock > 0;
    final prescription = p['requiresPrescription'] == true;
    return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (() {
                    final url = ''.trim();
                    if (!url.startsWith('http')) {
                      return buildImageShimmer(
                        context,
                        width: 78,
                        height: 78,
                        radius: BorderRadius.circular(12),
                      );
                    }
                    return AppImage(
                      imageUrl: url,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    );
                  })()),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('${p['name'] ?? 'منتج'}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (p['companyName'] != null || p['genericName'] != null)
                      Text('${p['companyName'] ?? p['genericName']}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    if (p['strength'] != null || p['activeIngredient'] != null)
                      Text('${p['strength'] ?? p['activeIngredient']}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Row(children: [
                      Text('${price.toStringAsFixed(0)} ر.ي',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                      if (old != null && old > price) ...[
                        const SizedBox(width: 7),
                        Text('${old.toStringAsFixed(0)} ر.ي',
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 11))
                      ]
                    ]),
                    const SizedBox(height: 4),
                    Wrap(spacing: 5, children: [
                      Text(
                          available
                              ? (stock <= 5
                                  ? 'متوفر — المتبقي $stock'
                                  : 'متوفر')
                              : 'نفد المخزون',
                          style: TextStyle(
                              fontSize: 11,
                              color: available ? Colors.green : Colors.red)),
                      if (prescription)
                        const Text('يتطلب وصفة',
                            style: TextStyle(
                                fontSize: 10, color: Colors.deepOrange))
                    ]),
                  ])),
              IconButton(
                  onPressed: available ? () => _add(p) : null,
                  icon: SvgPicture.asset('assets/icons/services/pharmacy.svg', width: 24, height: 24)),
            ])));
  }

  Widget _ordersTab() {
    if (FirebaseAuth.instance.currentUser == null)
      return const Center(child: Text('سجّل الدخول لعرض طلباتك'));
    final orders = _visibleOrders;
    if (orders.isEmpty)
      return RefreshIndicator(
          onRefresh: _loadOrders,
          child: ListView(children: const [
            SizedBox(height: 180),
            Center(child: Text('لا توجد طلبات صيدلية حالياً'))
          ]));
    return RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final o = orders[i];
              final status = _statusLabel('${o['status'] ?? ''}');
              return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                      title: Text('طلب #${o['id'] ?? o['orderId'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${o['pharmacyName'] ?? o['providerName'] ?? 'طلب صيدلية'}\n$status'),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {}));
            }));
  }
}
