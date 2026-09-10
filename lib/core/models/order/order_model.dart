import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/cart/cart_item.dart';

enum OrderStatus { pending, confirmed, preparing, ready, delivering, delivered, cancelled }
enum DeliveryType { standard, express, scheduled }

class OrderModel {
  final String id; final String userId; final List<CartItem> items; final OrderStatus status; final DateTime orderDate;
  final double subtotal, discount, deliveryFee, tax, total; final DeliveryType deliveryType;
  final String? deliveryAddress, deliveryInstructions, phoneNumber, paymentMethod, transactionId;
  final Map<String,dynamic>? metadata; final DateTime? estimatedDelivery, deliveredAt; final DateTime createdAt, updatedAt;
  OrderModel({required this.id,required this.userId,required this.items,required this.status,required this.orderDate,required this.subtotal,required this.discount,required this.deliveryFee,required this.tax,required this.total,required this.deliveryType,this.deliveryAddress,this.deliveryInstructions,this.phoneNumber,this.paymentMethod,this.transactionId,this.metadata,this.estimatedDelivery,this.deliveredAt,required this.createdAt,required this.updatedAt});
  String get statusText { switch(status){case OrderStatus.pending:return 'قيد المعالجة';case OrderStatus.confirmed:return 'مؤكد';case OrderStatus.preparing:return 'جاري التحضير';case OrderStatus.ready:return 'جاهز';case OrderStatus.delivering:return 'جاري التوصيل';case OrderStatus.delivered:return 'تم التوصيل';case OrderStatus.cancelled:return 'ملغي';} }
  IconData get statusIcon { switch(status){case OrderStatus.pending:return Icons.hourglass_empty;case OrderStatus.confirmed:return Icons.check_circle_outline;case OrderStatus.preparing:return Icons.build;case OrderStatus.ready:return Icons.inventory;case OrderStatus.delivering:return Icons.delivery_dining;case OrderStatus.delivered:return Icons.home;case OrderStatus.cancelled:return Icons.cancel;} }
  Color get statusColor { switch(status){case OrderStatus.pending:return Colors.orange;case OrderStatus.confirmed:return Colors.blue;case OrderStatus.preparing:return Colors.purple;case OrderStatus.ready:return Colors.teal;case OrderStatus.delivering:return Colors.indigo;case OrderStatus.delivered:return Colors.green;case OrderStatus.cancelled:return Colors.red;} }
  String get deliveryTypeText { switch(deliveryType){case DeliveryType.standard:return 'عادي';case DeliveryType.express:return 'سريع';case DeliveryType.scheduled:return 'مجدول';} }
}
