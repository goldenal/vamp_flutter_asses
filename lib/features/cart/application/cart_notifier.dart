import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/time/server_time_service.dart';
import '../../../core/ticker/global_ticker.dart';
import '../data/cart_api.dart';
import '../domain/cart_item.dart';

part 'cart_notifier.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  Future<List<CartItem>> build() async {
    // Listen to the ticker to prune expired items.
    // We use listen to avoid rebuilding this notifier (and its consumers) every second
    // unless the state actually changes.
    ref.listen(tickerStreamProvider, (previous, next) {
      if (next.hasValue) {
        _removeExpired(next.value!);
      }
    });

    return _fetchCart();
  }

  Future<List<CartItem>> _fetchCart() async {
    final api = ref.read(cartApiProvider);
    // Hardcoded userId as per assessment instructions
    final response = await api.fetchCart('user_123');

    // Update server time
    ref.read(serverTimeServiceProvider).updateServerTime(response.serverTime);

    return response.items;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCart());
  }

  Future<void> reserve(String productId) async {
    final api = ref.read(cartApiProvider);
    // state = const AsyncValue.loading(); // Optional: keep UI active or show spinner

    try {
      final item = await api.reserveItem('user_123', productId);

      // Update state with new item
      final currentList = state.value ?? [];
      final uniqueList =
          currentList.where((i) => i.productId != productId).toList();
      state = AsyncValue.data([...uniqueList, item]);
    } catch (e, st) {
      // Handle error (show toast or similar - usually handled by UI listening to error state)
      state = AsyncValue.error(e, st);
    }
  }

  void _removeExpired(DateTime now) {
    final currentList = state.value;
    if (currentList == null) return;

    // Filter items that are still valid (reservedUntil > now)
    final validItems =
        currentList.where((item) => item.reservedUntil.isAfter(now)).toList();

    // If the list changed, update state
    if (validItems.length != currentList.length) {
      state = AsyncValue.data(validItems);
    }
  }
}
