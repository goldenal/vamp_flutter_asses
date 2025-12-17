import '../domain/product.dart';
import '../../../core/network/api_client.dart';

class ProductsApi {
  final ApiClient _client;

  ProductsApi(this._client);

  Future<List<Product>> fetchProducts() async {
    final response = await _client.get('/products');
    return (response as List).map((e) => Product.fromJson(e)).toList();
  }
}
