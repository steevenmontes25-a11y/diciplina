import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/schedule_data.dart';
import '../../../core/models/activity.dart';

/// Selector horizontal de día de la semana.
class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onChanged,
  });

  final DayOfWeek selectedDay;
  final ValueChanged<DayOfWeek> onChanged;

  static const List<String> _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DayOfWeek.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = DayOfWeek.values[index];
          final isSelected = day == selectedDay;
          final isToday = day == todayAsEnum;
          return GestureDetector(
            onTap: () => onChanged(day),
            child: Container(
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: !isSelected && isToday
                    ? Border.all(color: AppColors.primary, width: 1)
                    : null,
              ),
              child: Text(
                _labels[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
