import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/cart_item.dart';

class CartApi {
  final ApiClient _client;

  CartApi(this._client);

  Future<CartResponse> fetchCart(String userId) async {
    final response = await _client.get('/cart?userId=$userId');
    return CartResponse.fromJson(response);
  }

  Future<CartItem> reserveItem(String userId, String productId) async {
    final response = await _client.post('/cart/reserve', {
      'userId': userId,
      'productId': productId, // API expects productId
    });
    return CartItem.fromJson(response);
  }
}

final cartApiProvider = Provider<CartApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return CartApi(client);
});
