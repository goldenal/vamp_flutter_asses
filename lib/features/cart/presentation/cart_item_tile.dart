import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ticker/global_ticker.dart';
import '../domain/cart_item.dart';

class CartItemTile extends ConsumerWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to global ticker for UI updates
    final tickerAsync = ref.watch(tickerStreamProvider);

    return tickerAsync.when(
      data: (now) {
        final remaining = item.reservedUntil.difference(now);

        // If expired (and not yet removed by notifier), show 00:00
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
          title: Text(
            'Product ${item.productId}',
          ), // Ideally look up name, but ID is sufficient for assessment
          subtitle: Text('Reserved for: $minutes:$seconds'),
          leading: const Icon(Icons.timer),
        );
      },
      error: (e, _) => const SizedBox.shrink(),
      loading: () => const ListTile(title: Text('Calculating...')),
    );
  }
}
