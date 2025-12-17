import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/products_api.dart';
import '../../cart/application/cart_notifier.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: productsState.when(
        data:
            (products) => ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Stock: ${product.stock}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(cartNotifierProvider.notifier)
                          .reserve(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reserved ${product.name}')),
                      );
                    },
                    child: const Text('Reserve'),
                  ),
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading products: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.shopping_cart),
        onPressed: () {
          Navigator.of(context).pushNamed('/cart');
        },
      ),
    );
  }
}
