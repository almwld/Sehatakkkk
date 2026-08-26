import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class WeatherHealthScreen extends StatefulWidget {
  const WeatherHealthScreen({super.key});

  @override
  State<WeatherHealthScreen> createState() => _WeatherHealthScreenState();
}

class _WeatherHealthScreenState extends State<WeatherHealthScreen> {
  final List<Map<String, dynamic>> _weatherData = [
    {
      'day': 'اليوم',
      'icon': '☀️',
      'temp': '32°C',
      'condition': 'مشمس',
      'humidity': '45%',
      'wind': '12 كم/س',
      'healthTip': 'استخدم واقي الشمس وشرب الماء',
      'color': Colors.orange,
    },
    {
      'day': 'غداً',
      'icon': '⛅',
      'temp': '28°C',
      'condition': 'غائم جزئياً',
      'humidity': '55%',
      'wind': '18 كم/س',
      'healthTip': 'احمل مظلة تحسباً للأمطار',
      'color': Colors.blue,
    },
    {
      'day': 'بعد غد',
      'icon': '🌧️',
      'temp': '22°C',
      'condition': 'ممطر',
      'humidity': '78%',
      'wind': '25 كم/س',
      'healthTip': 'احرص على ارتداء ملابس دافئة ومطرية',
      'color': Colors.blueGrey,
    },
    {
      'day': 'اليوم الثالث',
      'icon': '☁️',
      'temp': '25°C',
      'condition': 'غائم',
      'humidity': '65%',
      'wind': '15 كم/س',
      'healthTip': 'أيام جيدة لممارسة الرياضة في الأماكن المفتوحة',
      'color': Colors.grey,
    },
  ];

  final List<Map<String, dynamic>> _healthTipsByWeather = [
    {
      'weather': '☀️ مشمس',
      'tips': ['اشرب الكثير من الماء', 'استخدم واقي الشمس', 'ارتدِ ملابس فاتحة'],
      'color': Colors.orange,
    },
    {
      'weather': '☁️ غائم',
      'tips': ['احمل مظلة', 'ارتدِ ملابس دافئة', 'تجنب الجلوس المطول بالخارج'],
      'color': Colors.blue,
    },
    {
      'weather': '🌧️ ممطر',
      'tips': ['ارتدِ ملابس مطرية', 'تجنب الخروج غير الضروري', 'احرص على التدفئة المنزلية'],
      'color': Colors.blueGrey,
    },
    {
      'weather': '🌤️ مشمس مع غيوم',
      'tips': ['استخدم واقي الشمس', 'اشرب سوائل', 'احذر من تغير درجة الحرارة'],
      'color': Colors.teal,
    },
  ];

  String _selectedLocation = 'صنعاء، اليمن';
  final List<String> _locations = ['صنعاء، اليمن', 'عدن، اليمن', 'تعز، اليمن', 'الحديدة، اليمن', 'المكلا، اليمن'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الطقس وصحتك 🌤️'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ اختيار الموقع
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  items: _locations.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(location),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLocation = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ توقعات الطقس
            Text(
              'توقعات الطقس',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // ✅ بطاقة الطقس الحالي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weatherData[0]['day'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _weatherData[0]['temp'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _weatherData[0]['condition'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.water_drop, color: Colors.white.withOpacity(0.8), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _weatherData[0]['humidity'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.air, color: Colors.white.withOpacity(0.8), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _weatherData[0]['wind'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Text(
                          _weatherData[0]['icon'],
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _weatherData[0]['healthTip'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ توقعات الأيام القادمة
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _weatherData.length,
                itemBuilder: (context, index) {
                  final weather = _weatherData[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weather['icon'],
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather['temp'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          weather['condition'],
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ✅ نصائح صحية حسب الطقس
            Text(
              'نصائح صحية حسب الطقس',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ..._healthTipsByWeather.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (item['color'] as Color).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item['weather'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item['color'] as Color,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'نصائح',
                            style: TextStyle(
                              fontSize: 10,
                              color: item['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...(item['tips'] as List<String>).map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: item['color'] as Color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tip,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),

            // ✅ تأثير الطقس على الصحة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'تأثير الطقس على صحتك',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._getWeatherEffects().map((effect) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(fontSize: 14, color: AppColors.primary)),
                          Expanded(
                            child: Text(
                              effect,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<String> _getWeatherEffects() {
    return [
      'ارتفاع درجة الحرارة قد يؤدي إلى الجفاف والإرهاق',
      'الطقس البارد يزيد من خطر الإصابة بنزلات البرد',
      'تغيرات الطقس قد تؤثر على مرضى الربو والحساسية',
      'الرطوبة العالية تزيد من الشعور بالتعب',
      'أيام الشمس مفيدة لنقص فيتامين د ولكن احذر من أشعة الشمس المباشرة',
    ];
  }
}
