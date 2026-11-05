import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/presentation/screens/diet_plan/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/health_tools/calorie_calculator_screen.dart';

class NutritionHealthScreen extends StatefulWidget {
  const NutritionHealthScreen({super.key});

  @override
  State<NutritionHealthScreen> createState() => _NutritionHealthScreenState();
}

class _NutritionHealthScreenState extends State<NutritionHealthScreen> {
  String _goal = 'توازن غذائي';
  double _water = 0;
  int _meals = 0;
  bool _loading = true;

  final goals = const ['توازن غذائي', 'إدارة الوزن', 'بناء اللياقة'];

  String _t(String value) => AppStrings.of(context).translate(value);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _goal = prefs.getString('nutrition_goal') ?? 'توازن غذائي';
      _water = prefs.getDouble('nutrition_water') ?? 0;
      _meals = prefs.getInt('nutrition_meals') ?? 0;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutrition_goal', _goal);
    await prefs.setDouble('nutrition_water', _water);
    await prefs.setInt('nutrition_meals', _meals);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF08131A) : const Color(0xFFF5FAF8),
      appBar: AppBar(
        title: Text(_t('التغذية')),
        backgroundColor: dark ? const Color(0xFF08131A) : Colors.white,
        foregroundColor: dark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.success, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/tracking/fruits.webp',
                          width: 38,
                          height: 38,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('تغذية أذكى كل يوم'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _t('سجّل عاداتك اليومية وادمجها مع أهدافك الصحية.'),
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _t('هدفك الحالي'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: goals
                      .map(
                        (goal) => ChoiceChip(
                          label: Text(_t(goal)),
                          selected: _goal == goal,
                          onSelected: (_) {
                            setState(() => _goal = goal);
                            _persist();
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  _t('متابعتك اليوم'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _metric(
                        'الماء',
                        '${_water.toStringAsFixed(1)} ${_t('كوب')}',
                        'assets/images/tracking/water_drinking.webp',
                        AppColors.primary,
                        dark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _metric(
                        'الوجبات',
                        '$_meals ${_t('مسجلة')}',
                        'assets/images/tracking/fruits.webp',
                        AppColors.success,
                        dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _t('أدوات التغذية'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _tool(
                  'الخطة الغذائية',
                  'أنشئ خطة منظمة حسب هدفك',
                  'assets/images/services/health_tips.webp',
                  const DietPlanScreen(),
                  dark,
                ),
                _tool(
                  'حاسبة السعرات',
                  'سجّل الأطعمة واحسب إجمالي السعرات',
                  'assets/images/tracking/calories.png',
                  const CalorieCalculatorScreen(),
                  dark,
                ),
                _tool(
                  'أساسيات المغذيات',
                  'بروتين وألياف ودهون وكربوهيدرات',
                  'assets/images/tracking/fruits.webp',
                  null,
                  dark,
                ),
                const SizedBox(height: 18),
                Text(
                  _t('شرب الماء'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF122027) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.water_drop_outlined, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _t('سجّل ما تشربه فعلياً خلال اليوم'),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            '${_water.toStringAsFixed(1)} ${_t('كوب')}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _water.clamp(0, 12).toDouble(),
                        min: 0,
                        max: 12,
                        divisions: 24,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() => _water = value);
                          _persist();
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _water = (_water + 1).clamp(0, 12).toDouble());
                                _persist();
                              },
                              child: Text(_t('+ كوب')),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _meals += 1);
                                _persist();
                              },
                              child: Text(_t('تسجيل وجبة')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.07),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    _t('الاحتياجات الغذائية تختلف باختلاف العمر والنشاط والحالة الصحية. عند وجود مرض مزمن أو حمل أو احتياج غذائي خاص، استعن بمختص.'),
                    style: const TextStyle(fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _metric(String title, String value, String icon, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF122027) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 38,
            height: 38,
            errorBuilder: (_, __, ___) => Icon(Icons.insights_outlined, color: color, size: 34),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t(title), style: TextStyle(color: dark ? Colors.white70 : Colors.black54, fontSize: 11)),
                Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tool(String title, String sub, String icon, Widget? screen, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF122027) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Image.asset(
          icon,
          width: 42,
          height: 42,
          errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_outlined, color: AppColors.primary),
        ),
        title: Text(_t(title), style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(_t(sub)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
        onTap: screen == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
