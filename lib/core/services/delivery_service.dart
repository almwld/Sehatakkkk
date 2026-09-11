import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/delivery/delivery_company_model.dart';

class DeliveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<List<DeliveryCompanyModel>> getDeliveryCompanies() async {
    final snap = await _db.collection('delivery_companies').where('isActive', isEqualTo: true).get();
    return snap.docs.map((d) => DeliveryCompanyModel.fromMap(d.data(), d.id)).toList();
  }
  bool isAreaCovered(DeliveryCompanyModel company, String area) => company.coveredAreas.isEmpty || company.coveredAreas.any((x) => x.trim() == area.trim());
  double calculateDeliveryFee(DeliveryCompanyModel company, double distance) => company.baseFee + (distance < 0 ? 0 : distance) * company.perKmFee;
  int estimateDeliveryTime(DeliveryCompanyModel company, double distance) => company.baseMinutes + ((distance < 0 ? 0 : distance) * company.minutesPerKm).ceil();
}