import 'package:sehatak/presentation/widgets/common/custom_bottom_nav_bar.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/delivery/delivery_company_model.dart';
import 'package:sehatak/core/services/delivery_service.dart';

class DeliveryCompanyScreen extends StatefulWidget {
  final String? selectedCompanyId;
  final Function(DeliveryCompanyModel) onSelect;
  final double distance; // المسافة بالكيلومترات
  final String area;

  const DeliveryCompanyScreen({
    super.key,
    this.selectedCompanyId,
    required this.onSelect,
    this.distance = 5,
    required this.area,
  });

  @override
  State<DeliveryCompanyScreen> createState() => _DeliveryCompanyScreenState();
}

class _DeliveryCompanyScreenState extends State<DeliveryCompanyScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  List<DeliveryCompanyModel> _companies = [];
  bool _isLoading = true;
  String? _selectedCompanyId;

  @override
  void initState() {
    super.initState();
    _selectedCompanyId = widget.selectedCompanyId;
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    final companies = await _deliveryService.getDeliveryCompanies();
    
    // ✅ تصفية الشركات التي تغطي المنطقة
    final available = companies.where((c) => 
      _deliveryService.isAreaCovered(c, widget.area)
    ).toList();

    setState(() {
      _companies = available;
      _isLoading = false;
      
      // ✅ اختيار أول شركة إذا لم تكن محددة
      if (_selectedCompanyId == null && _companies.isNotEmpty) {
        _selectedCompanyId = _companies.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'اختر شركة التوصيل',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _companies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delivery_dining_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد شركات توصيل متاحة في منطقتك',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'سيتم إضافة خدمات التوصيل قريباً',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _companies.length,
                  itemBuilder: (context, index) {
                    final company = _companies[index];
                    final isSelected = _selectedCompanyId == company.id;
                    final fee = _deliveryService.calculateDeliveryFee(
                      company,
                      widget.distance,
                    );
                    final time = _deliveryService.estimateDeliveryTime(
                      company,
                      widget.distance,
                    );

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCompanyId = company.id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.05)
                              : (isDark ? const Color(0xFF1A2540) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // ✅ شعار الشركة
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage(company.logoPath),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              child: company.logo == null
                                  ? Icon(
                                      Icons.delivery_dining,
                                      color: Colors.grey.shade400,
                                      size: 30,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            // ✅ معلومات الشركة
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${company.rating}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${company.reviewCount})',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: company.isActive
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          company.isActive ? 'متاح' : 'غير متاح',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: company.isActive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '⏱️ $time دقيقة',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.attach_money,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${fee.toStringAsFixed(0)} ريال',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // ✅ زر الاختيار
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 28,
                              )
                            else
                              OutlinedButton(
                                onPressed: () {
                                  setState(() => _selectedCompanyId = company.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('اختيار'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _selectedCompanyId != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final selected = _companies.firstWhere(
                      (c) => c.id == _selectedCompanyId,
                    );
                    widget.onSelect(selected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تأكيد التوصيل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
