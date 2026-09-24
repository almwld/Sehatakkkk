import 'package:cloud_functions/cloud_functions.dart';

class CartItem {
  final String productId;
  final String name;
  final double unitPrice;
  int quantity;
  final bool requiresPrescription;
  final String? pharmacyId;
  final String? providerName;
  final String? prescriptionId;

  CartItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
    this.requiresPrescription = false,
    this.pharmacyId,
    this.providerName,
    this.prescriptionId,
  });

  double get total => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'requiresPrescription': requiresPrescription,
        'pharmacyId': pharmacyId,
        'providerName': providerName,
        'prescriptionId': prescriptionId,
      };
}

class UnifiedCartService {
  UnifiedCartService._();
  static final UnifiedCartService instance = UnifiedCartService._();

  final List<CartItem> _items = [];
  String? _checkoutIdempotencyKey;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  void add({
    required String productId,
    required String name,
    required double unitPrice,
    bool requiresPrescription = false,
    String? pharmacyId,
    String? providerName,
    String? prescriptionId,
  }) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(
        productId: productId,
        name: name,
        unitPrice: unitPrice,
        requiresPrescription: requiresPrescription,
        pharmacyId: pharmacyId,
        providerName: providerName,
        prescriptionId: prescriptionId,
      ));
    }
    _checkoutIdempotencyKey ??= 'cart-${DateTime.now().microsecondsSinceEpoch}';
  }

  void increment(String productId) {
    final item = _find(productId);
    if (item != null) item.quantity++;
  }

  void decrement(String productId) {
    final item = _find(productId);
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(item);
    } else {
      item.quantity--;
    }
    if (_items.isEmpty) _checkoutIdempotencyKey = null;
  }

  void remove(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    if (_items.isEmpty) _checkoutIdempotencyKey = null;
  }

  void clear() {
    _items.clear();
    _checkoutIdempotencyKey = null;
  }

  CartItem? _find(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    return index < 0 ? null : _items[index];
  }

  Future<Map<String, dynamic>> checkout({
    double deliveryFee = 0,
    String? deliveryAddress,
    bool deliveryRequired = true,
  }) async {
    if (_items.isEmpty) throw Exception('السلة فارغة');
    _checkoutIdempotencyKey ??= 'cart-${DateTime.now().microsecondsSinceEpoch}';

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final result = await functions.httpsCallable('checkoutCart').call({
      'items': _items.map((item) => {
            'productId': item.productId,
            'quantity': item.quantity,
            'pharmacyId': item.pharmacyId,
            'prescriptionId': item.prescriptionId,
          }).toList(),
      // The trusted backend calculates the actual delivery fee.
      'deliveryFee': deliveryFee,
      'deliveryAddress': deliveryAddress,
      'deliveryRequired': deliveryRequired,
      'idempotencyKey': _checkoutIdempotencyKey,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    clear();
    return data;
  }
}
