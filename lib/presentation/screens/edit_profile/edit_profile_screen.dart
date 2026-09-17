import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_assets.dart';
import 'package:sehatak/presentation/widgets/common/local_asset_icon.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  static const List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final savedBloodType = (data['bloodType'] ?? '').toString().trim();
        setState(() {
          _nameController.text = data['name'] ?? user.displayName ?? '';
          _phoneController.text = data['phone'] ?? user.phoneNumber ?? '';
          _addressController.text = data['address'] ?? '';
          _bloodTypeController.text = _bloodTypes.contains(savedBloodType) ? savedBloodType : '';
          _allergiesController.text = data['allergies'] ?? '';
          _heightController.text = data['height']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _ageController.text = data['age']?.toString() ?? '';
        });
      } else {
        setState(() {
          _nameController.text = user.displayName ?? '';
          _phoneController.text = user.phoneNumber ?? '';
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final height = double.tryParse(_heightController.text.trim());
      final weight = double.tryParse(_weightController.text.trim());
      final age = int.tryParse(_ageController.text.trim());

      if (_heightController.text.trim().isNotEmpty && height == null ||
          _weightController.text.trim().isNotEmpty && weight == null ||
          _ageController.text.trim().isNotEmpty && age == null) {
        ToastService.showError('يرجى إدخال الطول والوزن والعمر بقيم صحيحة');
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      if ((height != null && (height <= 0 || height > 300)) ||
          (weight != null && (weight <= 0 || weight > 500)) ||
          (age != null && (age < 0 || age > 150))) {
        ToastService.showError('تحقق من قيم الطول والوزن والعمر');
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      final bloodType = _bloodTypes.contains(_bloodTypeController.text)
          ? _bloodTypeController.text
          : null;

      await user.updateDisplayName(_nameController.text.trim());

      final updates = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'allergies': _allergiesController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (bloodType != null) updates['bloodType'] = bloodType;
      if (height != null) updates['height'] = height;
      if (weight != null) updates['weight'] = weight;
      if (age != null) updates['age'] = age;

      await _firestore.collection('users').doc(user.uid).set(
        updates,
        SetOptions(merge: true),
      );

      await user.reload();

      if (!mounted) return;
      ToastService.showSuccess('✅ تم تحديث الملف الشخصي والبيانات الصحية');
      Navigator.pop(context, true);
    } catch (e) {
      ToastService.showError('❌ فشل التحديث: $e');
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'تعديل الملف الشخصي',
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: 'تعديل الملف الشخصي',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text(
              'حفظ',
              style: TextStyle(
                color: _isSaving ? AppColors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ صورة الملف الشخصي
            _buildProfileImage(),
            const SizedBox(height: 24),
            // ✅ الحقول
            _buildTextField(
              controller: _nameController,
              label: 'الاسم الكامل',
              icon: AppAssets.userIcon,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              icon: AppAssets.phoneIcon,
              keyboardType: TextInputType.phone,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'العنوان',
              icon: AppAssets.locationIcon,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _heightController,
              label: 'الطول (سم)',
              icon: AppAssets.heightIcon,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _weightController,
              label: 'الوزن (كجم)',
              icon: AppAssets.weightIcon,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ageController,
              label: 'العمر (سنة)',
              icon: AppAssets.calendarIcon,
              keyboardType: TextInputType.number,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            _buildBloodTypeField(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _allergiesController,
              label: 'الحساسية (إن وجدت)',
              icon: AppAssets.warningIcon,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 30),
            // ✅ زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'حفظ التغييرات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _bloodTypes.contains(_bloodTypeController.text)
        ? _bloodTypeController.text
        : null;

    return DropdownButtonFormField<String>(
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'فصيلة الدم',
        prefixIcon: LocalAssetIcon(AppAssets.bloodPressureIcon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _bloodTypes
          .map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type, textAlign: TextAlign.right),
              ))
          .toList(),
      onChanged: _isSaving
          ? null
          : (value) {
              if (value != null) {
                setState(() => _bloodTypeController.text = value);
              }
            },
    );
  }

  Widget _buildProfileImage() {
    final user = _auth.currentUser;
    final photoUrl = user?.photoURL;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0]
                        : 'م',
                    style: const TextStyle(
                      fontSize: 32,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: LocalAssetIcon(
                AppAssets.cameraIcon,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      enabled: enabled,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: LocalAssetIcon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
