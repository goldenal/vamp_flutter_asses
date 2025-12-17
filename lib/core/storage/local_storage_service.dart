import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/products/domain/product.dart';
import '../../features/cart/domain/cart_item.dart';

class LocalStorageService {
  static const String _keyProducts = 'cached_products';
  static const String _keyCart = 'cached_cart';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // --- Products ---

  Future<void> saveProducts(List<Product> products) async {
    final jsonList = products.map((p) => p.toJson()).toList();
    await _prefs.setString(_keyProducts, jsonEncode(jsonList));
  }

  List<Product>? getProducts() {
    final jsonString = _prefs.getString(_keyProducts);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }

  // --- Cart ---

  Future<void> saveCart(CartResponse cart) async {
    await _prefs.setString(_keyCart, jsonEncode(cart.toJson()));
  }

  CartResponse? getCart() {
    final jsonString = _prefs.getString(_keyCart);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return CartResponse.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }
}
