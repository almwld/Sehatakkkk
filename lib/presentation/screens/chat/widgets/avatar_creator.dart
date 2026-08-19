import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AvatarCreator extends StatefulWidget {
  final Function(Map<String, dynamic>) onAvatarCreated;

  const AvatarCreator({
    super.key,
    required this.onAvatarCreated,
  });

  @override
  State<AvatarCreator> createState() => _AvatarCreatorState();
}

class _AvatarCreatorState extends State<AvatarCreator> {
  int _selectedSkin = 0;
  int _selectedHair = 0;
  int _selectedEyes = 0;
  int _selectedMouth = 0;
  int _selectedAccessory = 0;
  Color _selectedColor = Colors.blue;

  final List<Color> _skinColors = [
    Colors.brown[100]!,
    Colors.brown[200]!,
    Colors.brown[300]!,
    Colors.orange[100]!,
    Colors.orange[200]!,
  ];

  final List<String> _hairStyles = ['👨', '👩', '👴', '👵', '🧑'];
  final List<String> _eyeStyles = ['👀', '😀', '😍', '😜', '😎'];
  final List<String> _mouthStyles = ['😊', '😄', '😆', '😇', '😋'];
  final List<String> _accessories = ['🎩', '👒', '🕶️', '🧢', '👑'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ معاينة الشخصية
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _skinColors[_selectedSkin],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ✅ العيون
                Positioned(
                  top: 30,
                  child: Text(
                    _eyeStyles[_selectedEyes],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                // ✅ الفم
                Positioned(
                  bottom: 30,
                  child: Text(
                    _mouthStyles[_selectedMouth],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                // ✅ الشعر
                Positioned(
                  top: -10,
                  child: Text(
                    _hairStyles[_selectedHair],
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                // ✅ الإكسسوار
                Positioned(
                  top: 5,
                  right: 10,
                  child: Text(
                    _accessories[_selectedAccessory],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ✅ ألوان البشرة
          const Text('لون البشرة'),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _skinColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedSkin = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _skinColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedSkin == index
                            ? AppColors.primary
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ✅ خيارات أخرى
          Row(
            children: [
              Expanded(
                child: _buildOptionSelector(
                  label: 'شعر',
                  options: _hairStyles,
                  selected: _selectedHair,
                  onChanged: (value) => setState(() => _selectedHair = value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionSelector(
                  label: 'عيون',
                  options: _eyeStyles,
                  selected: _selectedEyes,
                  onChanged: (value) => setState(() => _selectedEyes = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildOptionSelector(
                  label: 'فم',
                  options: _mouthStyles,
                  selected: _selectedMouth,
                  onChanged: (value) => setState(() => _selectedMouth = value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionSelector(
                  label: 'إكسسوار',
                  options: _accessories,
                  selected: _selectedAccessory,
                  onChanged: (value) => setState(() => _selectedAccessory = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ✅ زر الحفظ
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onAvatarCreated({
                  'skinColor': _skinColors[_selectedSkin],
                  'hair': _hairStyles[_selectedHair],
                  'eyes': _eyeStyles[_selectedEyes],
                  'mouth': _mouthStyles[_selectedMouth],
                  'accessory': _accessories[_selectedAccessory],
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ الشخصية'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSelector({
    required String label,
    required List<String> options,
    required int selected,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: options.map((option) {
            final index = options.indexOf(option);
            return GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected == index
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selected == index
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    opacity: selected == index ? 1.0 : 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
