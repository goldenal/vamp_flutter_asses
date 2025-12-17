import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/products/presentation/products_screen.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'features/cart/application/cart_notifier.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
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
      // This handles background -> foreground transition
      ref.read(cartNotifierProvider.notifier).refresh();
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
