import 'package:cloud_firestore/cloud_firestore.dart';

enum CartItemType { medicine, labTest, consultation, product, service }
class CartItem {
  final String id,name; final CartItemType type; final double price; final int quantity; final String? imageUrl,category,providerId,providerName; final double? discount; final bool isPrescription; final Map<String,dynamic>? metadata; final DateTime addedAt;
  CartItem({required this.id,required this.type,required this.name,required this.price,this.quantity=1,this.imageUrl,this.category,this.providerId,this.providerName,this.discount,this.isPrescription=false,this.metadata,required this.addedAt});
  double get totalPrice=>price*quantity; double get totalWithDiscount=>discount!=null?totalPrice*(1-discount!/100):totalPrice; double get discountAmount=>discount!=null?totalPrice*discount!/100:0;
  String get typeIcon=>switch(type){CartItemType.medicine=>'💊',CartItemType.labTest=>'🔬',CartItemType.consultation=>'🩺',CartItemType.product=>'📦',CartItemType.service=>'🛠️'};
  Map<String,dynamic> toMap()=>{'id':id,'type':type.name,'name':name,'price':price,'quantity':quantity,'imageUrl':imageUrl,'category':category,'providerId':providerId,'providerName':providerName,'discount':discount,'isPrescription':isPrescription,'metadata':metadata,'addedAt':addedAt.toIso8601String()};
  Map<String,dynamic> toJson()=>toMap();
  factory CartItem.fromMap(Map<String,dynamic> map)=>CartItem(id:map['id']?.toString()??'',type:_parseType(map['type']?.toString()??'medicine'),name:map['name']?.toString()??'',price:(map['price'] as num?)?.toDouble()??0,quantity:(map['quantity'] as num?)?.toInt()??1,imageUrl:map['imageUrl']?.toString(),category:map['category']?.toString(),providerId:map['providerId']?.toString(),providerName:map['providerName']?.toString(),discount:(map['discount'] as num?)?.toDouble(),isPrescription:map['isPrescription']==true,metadata:map['metadata'] is Map?Map<String,dynamic>.from(map['metadata']):null,addedAt:DateTime.tryParse(map['addedAt']?.toString()??'')??DateTime.now());
  static CartItemType _parseType(String value)=>CartItemType.values.firstWhere((e)=>e.name==value,orElse:()=>CartItemType.medicine);
}
