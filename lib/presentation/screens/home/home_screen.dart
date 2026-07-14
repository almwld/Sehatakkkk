// ... الكود السابق ...

// ✅ دالة عرض المنتجات - باستخدام Image.asset بدلاً من CachedNetworkImage
Widget _buildProductsRow() {
  return SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return GestureDetector(
          onTap: () => _goTo(context, const PharmacyScreen()),
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ استخدام Image.asset بدلاً من CachedNetworkImage
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    product['image'],  // ← مباشرة من assets
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.medication, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: Text(product['category'], style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ),
                const Spacer(),
                Text('${product['price']} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D5257))),
              ],
            ),
          ),
        );
      },
    ),
  );

}

// ✅ دالة عرض المختبرات - باستخدام Image.asset بدلاً من CachedNetworkImage
Widget _buildFeaturedLabsRow(bool isDark) {
  return SizedBox(
    height: 120,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _featuredLabs.length,
      itemBuilder: (context, index) {
        final lab = _featuredLabs[index];
        return GestureDetector(
          onTap: () => _goTo(context, const LabsListScreen()),
          child: Container(
            width: 250,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                // ✅ استخدام Image.asset بدلاً من CachedNetworkImage
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    lab['image'],  // ← مباشرة من assets
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.science, color: Colors.grey, size: 25),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(lab['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(lab['location'], style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

}
