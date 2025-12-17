import 'package:flutter/foundation.dart';
import '../data/products_api.dart';
import '../domain/product.dart';
import '../../../core/storage/local_storage_service.dart';

sealed class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  ProductsLoaded(this.products);
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}

class ProductsNotifier extends ChangeNotifier {
  final ProductsApi _api;
  final LocalStorageService _localStorage;
  ProductsState _state = ProductsInitial();

  ProductsNotifier(this._api, this._localStorage) {
    fetchProducts();
  }

  ProductsState get state => _state;

  Future<void> fetchProducts() async {
    _state = ProductsLoading();
    notifyListeners();

    try {
      // 1. Try to fetch from API
      final products = await _api.fetchProducts();
      _state = ProductsLoaded(products);

      // 2. Save to local storage
      await _localStorage.saveProducts(products);
    } catch (e) {
      // 3. If API fails, try to load from local storage
      final cachedProducts = _localStorage.getProducts();
      if (cachedProducts != null) {
        _state = ProductsLoaded(cachedProducts);
      } else {
        _state = ProductsError(e.toString());
      }
    }
    notifyListeners();
  }
}
