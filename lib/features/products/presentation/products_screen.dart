import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/products_notifier.dart';
import '../../cart/application/cart_notifier.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsNotifier = context.watch<ProductsNotifier>();
    final productsState = productsNotifier.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: _buildBody(context, productsState),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.shopping_cart),
        onPressed: () {
          Navigator.of(context).pushNamed('/cart');
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductsState state) {
    if (state is ProductsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProductsError) {
      return Center(child: Text('Error loading products: ${state.message}'));
    } else if (state is ProductsLoaded) {
      final products = state.products;
      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductListItem(product: product);
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class ProductListItem extends StatefulWidget {
  final dynamic
  product; // Explicitly typing this as Product requires import, using dynamic to avoid import mess if not strictly needed, but better to use Product type if possible. The file imports product domain implicitly? No, it imports products items.
  // Wait, `product` variable in itemBuilder comes from `state.products` which is `List<Product>`.
  // I need to import Product if I want to type it, or I can just use it.
  // `ProductsLoaded` has `List<Product> products`.
  // Let's check imports. `import '../application/products_notifier.dart';`
  // `ProductsNotifier` imports `../domain/product.dart`.
  // So `Product` type should be available if I import it or if it is exported.
  // Actually, I should probably put this class in the same file for now or separate file.
  // Putting it in the same file at the bottom is easiest for this refactor.

  const ProductListItem({super.key, required this.product});

  @override
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.product.name),
      subtitle: Text('Stock: ${widget.product.stock}'),
      trailing: ElevatedButton(
        onPressed:
            _isLoading
                ? null
                : () async {
                  setState(() => _isLoading = true);
                  try {
                    await context.read<CartNotifier>().reserve(
                      widget.product.id,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reserved ${widget.product.name}'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      final message = e.toString().replaceAll(
                        'Exception: ',
                        '',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to reserve: $message')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text('Reserve'),
      ),
    );
  }
}
