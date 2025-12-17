import 'package:json_annotation/json_annotation.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final String productId;
  final DateTime reservedUntil;

  CartItem({required this.productId, required this.reservedUntil});

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}

@JsonSerializable()
class CartResponse {
  final List<CartItem> items;
  final DateTime serverTime;

  CartResponse({required this.items, required this.serverTime});

  factory CartResponse.fromJson(Map<String, dynamic> json) =>
      _$CartResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CartResponseToJson(this);
}
