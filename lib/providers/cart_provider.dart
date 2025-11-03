import 'package:flutter/foundation.dart';


// The CartItem class remains the same
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  // 1. NEW: Convert CartItem to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // 2. NEW: Create CartItem from Firestore Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 3. NEW: We need to know which user's cart we're managing
  String? _userId;

  List<CartItem> get items => _items;

  int get itemCount {
    int total = 0;
    for (var item in _items) {
      total += item.quantity;
    }
    return total;
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // 4. NEW: Initialize the cart for a specific user
  Future<void> initializeCart(String userId) async {
    _userId = userId;
    await _loadCartFromFirestore();
  }

  // 5. NEW: Load cart items from Firestore
  Future<void> _loadCartFromFirestore() async {
    if (_userId == null) return;

    try {
      // Get the user's cart document
      final cartDoc = await _firestore
          .collection('carts')
          .doc(_userId)
          .get();

      if (cartDoc.exists && cartDoc.data() != null) {
        final data = cartDoc.data()!;

        // 6. The 'items' field is a List of Maps
        final List<dynamic> itemsList = data['items'] ?? [];

        // 7. Convert each Map back to a CartItem
        _items.clear();
        for (var itemMap in itemsList) {
          _items.add(CartItem.fromMap(itemMap as Map<String, dynamic>));
        }

        // 8. Update the UI
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  // 9. NEW: Save the entire cart to Firestore
  Future<void> _saveCartToFirestore() async {
    if (_userId == null) return;

    try {
      // 10. Convert all CartItems to Maps
      final itemsMapList = _items.map((item) => item.toMap()).toList();

      // 11. Save to Firestore (this creates or overwrites the document)
      await _firestore.collection('carts').doc(_userId).set({
        'items': itemsMapList,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // 12. UPDATED: addItem now saves to Firestore
  Future<void> addItem(String id, String name, double price) async {
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(id: id, name: name, price: price));
    }

    notifyListeners();

    // 13. NEW: Save to Firestore after updating
    await _saveCartToFirestore();
  }

  // 14. UPDATED: removeItem now saves to Firestore
  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();

    // 15. NEW: Save to Firestore after updating
    await _saveCartToFirestore();
  }

  // 16. NEW: Clear the entire cart
  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _saveCartToFirestore();
  }
}