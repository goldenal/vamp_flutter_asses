import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/cart_notifier.dart';
import 'cart_item_tile.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cartState.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return CartItemTile(item: items[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
