import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/time/server_time_service.dart';
import 'core/ticker/global_ticker.dart';
import 'features/products/data/products_api.dart';
import 'features/products/application/products_notifier.dart';
import 'features/cart/data/cart_api.dart';
import 'features/cart/application/cart_notifier.dart';
import 'features/products/presentation/products_screen.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'dart:async';
import 'core/storage/local_storage_service.dart';
import 'core/network/network_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final timeService = ServerTimeService();
  final ticker = GlobalTicker(timeService);
  final productsApi = ProductsApi(apiClient);
  final cartApi = CartApi(apiClient);
  final tickerStream = ticker.tick();

  final localStorage = await LocalStorageService.init();
  final networkMonitor = NetworkMonitor();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: timeService),
        Provider.value(value: ticker),
        Provider.value(value: productsApi),
        Provider.value(value: cartApi),
        Provider.value(value: localStorage),
        Provider.value(value: networkMonitor),
        StreamProvider<DateTime>.value(
          value: tickerStream,
          initialData: timeService.now(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductsNotifier(productsApi, localStorage),
        ),
        ChangeNotifierProvider(
          create:
              (_) => CartNotifier(
                cartApi,
                timeService,
                tickerStream,
                localStorage,
                networkMonitor,
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserved Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return NetworkStatusListener(child: child!);
      },
      home: const ProductsScreen(),
      routes: {'/cart': (context) => const CartScreen()},
    );
  }
}

class NetworkStatusListener extends StatefulWidget {
  final Widget child;

  const NetworkStatusListener({super.key, required this.child});

  @override
  State<NetworkStatusListener> createState() => _NetworkStatusListenerState();
}

class _NetworkStatusListenerState extends State<NetworkStatusListener> {
  StreamSubscription<bool>? _networkSubscription;

  @override
  void initState() {
    super.initState();
    final networkMonitor = context.read<NetworkMonitor>();
    _networkSubscription = networkMonitor.onConnectivityChanged
        .distinct()
        .listen((isOnline) {
          if (!mounted) return;

          // Clear any existing snackbars first
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          if (isOnline) {
            _refreshData();
          } else {
            _showOfflineSnackBar();
          }
        });
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

  void _showOfflineSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No Internet Connection'),
        backgroundColor: Colors.red,
        duration: Duration(days: 365),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  Future<void> _refreshData() async {
    // Re-fetch products and cart
    context.read<ProductsNotifier>().fetchProducts();
    context.read<CartNotifier>().refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Back online - Refreshing data...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
