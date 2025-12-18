import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/time/server_time_service.dart';
import '../data/cart_api.dart';
import '../domain/cart_item.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/network/network_monitor.dart';

sealed class CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  CartLoaded(this.items);
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

class CartNotifier extends ChangeNotifier {
  final CartApi _api;
  final ServerTimeService _timeService;
  final Stream<DateTime> _tickerStream;
  final LocalStorageService _localStorage;
  final NetworkMonitor _networkMonitor;
  StreamSubscription<DateTime>? _tickerSubscription;

  CartState _state = CartLoading();
  CartState get state => _state;

  CartNotifier(
    this._api,
    this._timeService,
    this._tickerStream,
    this._localStorage,
    this._networkMonitor,
  ) {
    _init();
  }

  void _init() {
    _fetchCart();
    _tickerSubscription = _tickerStream.listen((now) {
      _removeExpired(now);
    });
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchCart() async {
    try {
      // 1. Try to fetch from API
      final response = await _api.fetchCart('user_123');
      _timeService.updateServerTime(response.serverTime);
      _state = CartLoaded(response.items);

      // 2. Save to local storage
      await _localStorage.saveCart(response);
    } catch (e) {
      // 3. Fallback to cache
      final cachedCart = _localStorage.getCart();
      if (cachedCart != null) {
        // Note: Server time might be stale, but better than nothing
        _timeService.updateServerTime(cachedCart.serverTime);
        _state = CartLoaded(cachedCart.items);
      } else {
        _state = CartError(e.toString());
      }
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    _state = CartLoading();
    notifyListeners();
    await _fetchCart();
  }

  Future<void> reserve(String productId) async {
    if (!_networkMonitor.isOnline) {
      throw Exception('No Internet Connection');
    }

    try {
      final item = await _api.reserveItem('user_123', productId);

      if (_state is CartLoaded) {
        final currentItems = (_state as CartLoaded).items;
        final uniqueItems =
            currentItems.where((i) => i.productId != productId).toList();
        _state = CartLoaded([...uniqueItems, item]);
        notifyListeners();
      }
    } catch (e) {
      // Re-throw to let UI handle the error (e.g. show SnackBar)
      debugPrint('Error reserving item: $e');
      rethrow;
    }
  }

  void _removeExpired(DateTime now) {
    if (_state is CartLoaded) {
      final currentItems = (_state as CartLoaded).items;
      final validItems =
          currentItems
              .where((item) => item.reservedUntil.isAfter(now))
              .toList();

      if (validItems.length != currentItems.length) {
        _state = CartLoaded(validItems);
        notifyListeners();
      }
    }
  }
}
