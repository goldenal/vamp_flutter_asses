import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final now = context.watch<DateTime>();
    final remaining = item.reservedUntil.difference(now);

    // If expired (and not yet removed by notifier), show 00:00 or hide
    if (remaining.isNegative) {
      return const SizedBox.shrink();
    }

    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return ListTile(
      title: Text('Product ${item.productId}'),
      subtitle: Text('Reserved for: $minutes:$seconds'),
      leading: const Icon(Icons.timer),
    );
  }
}
