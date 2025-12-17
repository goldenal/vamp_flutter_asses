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
import 'core/storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final timeService = ServerTimeService();
  final ticker = GlobalTicker(timeService);
  final productsApi = ProductsApi(apiClient);
  final cartApi = CartApi(apiClient);
  final tickerStream = ticker.tick();

  final localStorage = await LocalStorageService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: timeService),
        Provider.value(value: ticker),
        Provider.value(value: productsApi),
        Provider.value(value: cartApi),
        Provider.value(value: localStorage),
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh cart on resume to get fresh server time and reservations
      context.read<CartNotifier>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserved Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProductsScreen(),
      routes: {'/cart': (context) => const CartScreen()},
    );
  }
}
