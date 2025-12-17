// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
      productId: json['productId'] as String,
      reservedUntil: DateTime.parse(json['reservedUntil'] as String),
    );

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
      'productId': instance.productId,
      'reservedUntil': instance.reservedUntil.toIso8601String(),
    };

CartResponse _$CartResponseFromJson(Map<String, dynamic> json) => CartResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      serverTime: DateTime.parse(json['serverTime'] as String),
    );

Map<String, dynamic> _$CartResponseToJson(CartResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'serverTime': instance.serverTime.toIso8601String(),
    };
