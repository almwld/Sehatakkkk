// ============================================================
// 🖼️ تحميل أيقونات SVG
// ============================================================
void _loadIcons() {
  _hospitalIcon = SvgAssetLoader('assets/icons/map_pins/hospital.svg').loadPicture(null, null);
  _pharmacyIcon = SvgAssetLoader('assets/icons/map_pins/pharmacy.svg').loadPicture(null, null);
  _laboratoryIcon = SvgAssetLoader('assets/icons/map_pins/laboratory.svg').loadPicture(null, null);
  _medicalIcon = SvgAssetLoader('assets/icons/map_pins/medical.svg').loadPicture(null, null);
  _clinicIcon = SvgAssetLoader('assets/icons/map_pins/clinic.svg').loadPicture(null, null);
}

// ============================================================
// 🎨 الحصول على أيقونة SVG حسب الفئة
// ============================================================
PictureProvider _getIconProviderForCategory(String category) {
  switch (category) {
    case 'hospitals':
      return _hospitalIcon;
    case 'pharmacies':
      return _pharmacyIcon;
    case 'labs':
      return _laboratoryIcon;
    case 'clinics':
      return _clinicIcon;
    case 'other':
      return _medicalIcon;
    default:
      return _medicalIcon;
  }
}

// ============================================================
// 🎨 بناء العلامات (Markers) مع SVG
// ============================================================
List<Marker> _buildMarkers() {
  final filtered = _getFilteredPlaces();
  
  return filtered.map((place) {
    final isSelected = _selectedLocation != null &&
        _selectedLocation!.latitude == place['lat'] &&
        _selectedLocation!.longitude == place['lng'];
    
    final iconProvider = _getIconProviderForCategory(place['category'] as String);
    
    return Marker(
      width: 40,
      height: 40,
      point: LatLng(place['lat'] as double, place['lng'] as double),
      child: GestureDetector(
        onTap: () => _showPlaceDetails(place),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 48 : 36,
          height: isSelected ? 48 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.primary : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : SizedBox(
                    width: 22,
                    height: 22,
                    child: SvgPicture(
                      iconProvider,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }).toList();
}

// ============================================================
// 🎨 أيقونة SVG لعرض التفاصيل
// ============================================================
Widget _getCategoryIcon(String category, {double size = 24}) {
  final provider = _getIconProviderForCategory(category);
  return SvgPicture(
    provider,
    width: size,
    height: size,
    colorFilter: const ColorFilter.mode(
      AppColors.primary,
      BlendMode.srcIn,
    ),
  );
}
