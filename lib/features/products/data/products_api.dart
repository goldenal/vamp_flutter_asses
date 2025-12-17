import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/product.dart';

class ProductsApi {
  final ApiClient _client;

  ProductsApi(this._client);

  Future<List<Product>> fetchProducts() async {
    final response = await _client.get('/products');
    return (response as List).map((e) => Product.fromJson(e)).toList();
  }
}

final productsApiProvider = Provider<ProductsApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductsApi(client);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(productsApiProvider);
  return api.fetchProducts();
});
