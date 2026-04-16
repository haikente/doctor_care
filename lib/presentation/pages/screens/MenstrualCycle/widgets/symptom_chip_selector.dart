import 'package:flutter/material.dart';

class SymptomChipSelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const SymptomChipSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _symptoms = [
    ('cramps', 'Đau bụng'),
    ('headache', 'Đau đầu'),
    ('bloating', 'Đầy hơi'),
    ('fatigue', 'Mệt mỏi'),
    ('mood_swings', 'Thay đổi tâm trạng'),
    ('back_pain', 'Đau lưng'),
    ('breast_tenderness', 'Ngực nhạy cảm'),
    ('nausea', 'Buồn nôn'),
    ('acne', 'Mụn'),
    ('insomnia', 'Mất ngủ'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _symptoms.map((s) {
          final isSelected = selected.contains(s.$1);
          return FilterChip(
            label: Text(
              s.$2,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            selected: isSelected,
            onSelected: (val) {
              final updated = List<String>.from(selected);
              if (val) {
                updated.add(s.$1);
              } else {
                updated.remove(s.$1);
              }
              onChanged(updated);
            },
            selectedColor: Colors.blue.shade600,
            checkmarkColor: Colors.white,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: BorderSide.none,
            showCheckmark: false,
            avatar: isSelected ? null : null,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          );
        }).toList(),
      ),
    );
  }

  /// Trả về tên hiển thị của triệu chứng từ key
  static String labelOf(String key) {
    return _symptoms
        .firstWhere((s) => s.$1 == key, orElse: () => (key, key))
        .$2;
  }
}
