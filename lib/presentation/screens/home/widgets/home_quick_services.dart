import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class QuickServiceModel {
  final String icon;
  final String label;
  final Widget screen;

  const QuickServiceModel({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

class HomeQuickServices extends StatelessWidget {
  final bool isDark;
  final List<QuickServiceModel> services;
  final Function(Widget) onServiceTap;

  const HomeQuickServices({
    super.key,
    required this.isDark,
    required this.services,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildServicesGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'خدمات سريعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('عرض الكل'),
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceItem(service);
        },
      ),
    );
  }

  Widget _buildServiceItem(QuickServiceModel service) {
    return GestureDetector(
      onTap: () => onServiceTap(service.screen),
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Image.asset(
                  service.icon,
                  width: 28,
                  height: 28,
                  color: AppColors.primary,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.circle, color: AppColors.primary, size: 28);
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              service.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
