import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/cart_notifier.dart';
import 'cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartNotifier = context.watch<CartNotifier>();
    final cartState = cartNotifier.state;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: _buildBody(cartState),
    );
  }

  Widget _buildBody(CartState state) {
    if (state is CartLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is CartError) {
      return Center(child: Text('Error: ${state.message}'));
    } else if (state is CartLoaded) {
      final items = state.items;
      if (items.isEmpty) {
        return const Center(child: Text('Cart is empty'));
      }
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return CartItemTile(item: items[index]);
        },
      );
    }
    return const SizedBox.shrink();
  }
}
