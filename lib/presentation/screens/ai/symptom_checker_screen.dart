import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/ai/symptom_checker_service.dart';
import 'package:sehatak/data/models/ai/symptom_model.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final SymptomCheckerService _service = SymptomCheckerService();
  final TextEditingController _searchController = TextEditingController();
  
  List<SymptomModel> _allSymptoms = [];
  List<SymptomModel> _filteredSymptoms = [];
  List<SymptomModel> _selectedSymptoms = [];
  List<DiagnosisResult> _results = [];
  
  bool _isLoading = false;
  bool _isAnalyzing = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  void _loadSymptoms() {
    _allSymptoms = _service.getAvailableSymptoms();
    _filteredSymptoms = _allSymptoms;
  }

  void _searchSymptoms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSymptoms = _allSymptoms;
      } else {
        _filteredSymptoms = _allSymptoms
            .where((s) => s.name.contains(query) || s.category.contains(query))
            .toList();
      }
    });
  }

  void _toggleSymptom(SymptomModel symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _currentStep = 1;
    });

    try {
      final results = await _service.analyzeSymptoms(_selectedSymptoms);
      setState(() {
        _results = results;
        _currentStep = 2;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل التحليل: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _currentStep = 0);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _resetChecker() {
    setState(() {
      _selectedSymptoms.clear();
      _results.clear();
      _currentStep = 0;
      _searchController.clear();
      _filteredSymptoms = _allSymptoms;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('فحص الأعراض'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedSymptoms.isNotEmpty || _results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _resetChecker,
            ),
        ],
      ),
      body: _buildBody(isDark, primaryColor),
    );
  }

  Widget _buildBody(bool isDark, Color primaryColor) {
    if (_currentStep == 2 && _results.isNotEmpty) {
      return _buildResultsView(isDark, primaryColor);
    }

    return Column(
      children: [
        // ✅ شريط التقدم
        _buildProgressBar(isDark),
        const SizedBox(height: 16),

        // ✅ العنوان والوصف
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ما هي الأعراض التي تشعر بها؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'اختر الأعراض التي تعاني منها للحصول على تحليل مبدئي',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              // ✅ الأعراض المختارة
              if (_selectedSymptoms.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الأعراض المختارة (${_selectedSymptoms.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSymptoms.map((s) {
                          return Chip(
                            label: Text(s.name),
                            onDeleted: () => _toggleSymptom(s),
                            backgroundColor: primaryColor.withOpacity(0.1),
                            deleteIconColor: Colors.red,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ✅ شريط البحث
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: _searchSymptoms,
            textAlign: TextAlign.right,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'ابحث عن عرض...',
              hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0D5257)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _searchSymptoms('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0D5257), width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ✅ قائمة الأعراض
        Expanded(
          child: _filteredSymptoms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد أعراض تطابق بحثك',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredSymptoms.length,
                  itemBuilder: (context, index) {
                    final symptom = _filteredSymptoms[index];
                    final isSelected = _selectedSymptoms.contains(symptom);
                    return _buildSymptomTile(symptom, isSelected, isDark);
                  },
                ),
        ),

        // ✅ زر التحليل
        if (_selectedSymptoms.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeSymptoms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'تحليل الأعراض',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildStepIndicator(0, 'اختيار', isDark),
          _buildStepLine(isDark),
          _buildStepIndicator(1, 'تحليل', isDark),
          _buildStepLine(isDark),
          _buildStepIndicator(2, 'النتائج', isDark),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isDark) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0D5257) : (isDark ? Colors.grey[700] : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF0D5257) : (isDark ? Colors.grey[500] : Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDark ? Colors.grey[700] : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildSymptomTile(SymptomModel symptom, bool isSelected, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? const Color(0xFF1A2540) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0D5257) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: () => _toggleSymptom(symptom),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0D5257).withOpacity(0.1),
          child: Text(
            symptom.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          symptom.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          symptom.category,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF0D5257))
            : null,
      ),
    );
  }

  Widget _buildResultsView(bool isDark, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ عنوان النتائج
          Row(
            children: [
              Icon(Icons.medical_information_rounded, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'نتائج التحليل',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'بناءً على الأعراض التي اخترتها (${_selectedSymptoms.length})',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ التوصيات
          ..._results.map((result) {
            return _buildResultCard(result, isDark);
          }).toList(),

          const SizedBox(height: 16),

          // ✅ تحذير
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'هذا التحليل مبدئي ولا يغني عن استشارة الطبيب',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ أزرار الإجراء
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetChecker,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // ✅ الانتقال إلى الأطباء
                  },
                  icon: const Icon(Icons.medical_services_rounded),
                  label: const Text('استشارة طبيب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResultCard(DiagnosisResult result, bool isDark) {
    final severityColor = result.severity == 'عالية'
        ? Colors.red
        : result.severity == 'متوسطة'
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1A2540) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.severity,
                    style: TextStyle(
                      fontSize: 10,
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'ثقة ${(result.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.condition,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            // ✅ التوصيات
            if (result.recommendations.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التوصيات:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...result.recommendations.map((rec) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right_rounded, size: 16, color: Color(0xFF0D5257)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              rec,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
