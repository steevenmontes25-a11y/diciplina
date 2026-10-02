import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/activity.dart';
import '../../core/models/day_progress.dart';
import '../../providers/notifications_provider.dart';

/// Muestra un modal inferior con el detalle de una [Activity].
///
/// Si se provee [date] (fecha "yyyy-MM-dd") y [onStatusChanged], el modal
/// permite marcar la actividad como hecha u omitida para ese día.
Future<void> showActivityModal(
  BuildContext context, {
  required Activity activity,
  String? date,
  ActivityProgress? progress,
  ValueChanged<ActivityStatus>? onStatusChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ActivityModalContent(
      activity: activity,
      date: date,
      progress: progress,
      onStatusChanged: onStatusChanged,
    ),
  );
}

/// Contenido del modal de detalle/edición de una actividad.
class ActivityModalContent extends ConsumerStatefulWidget {
  const ActivityModalContent({
    super.key,
    required this.activity,
    this.date,
    this.progress,
    this.onStatusChanged,
  });

  final Activity activity;
  final String? date;
  final ActivityProgress? progress;
  final ValueChanged<ActivityStatus>? onStatusChanged;

  @override
  ConsumerState<ActivityModalContent> createState() =>
      _ActivityModalContentState();
}

class _ActivityModalContentState extends ConsumerState<ActivityModalContent> {
  late bool _notificationsEnabled = widget.activity.isAlarmEnabled;
  bool _loadingPreference = true;
  ActivityStatus? _localStatus;

  String get _preferenceKey => 'notif_${widget.activity.id}';

  bool get _isToday =>
      widget.date == DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final stored = await DbHelper.instance.getPreference(_preferenceKey);
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = stored != null
          ? stored == 'true'
          : widget.activity.isAlarmEnabled;
      _loadingPreference = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await DbHelper.instance.setPreference(_preferenceKey, value.toString());

    final service = ref.read(notificationsServiceProvider);
    if (value) {
      await service.scheduleForActivity(widget.activity);
    } else {
      await service.cancelForActivity(widget.activity);
    }
  }

  void _mark(ActivityStatus status) {
    widget.onStatusChanged?.call(status);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final status =
        _localStatus ?? widget.progress?.status ?? ActivityStatus.pending;
    final canMark = widget.date != null && widget.onStatusChanged != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: activity.category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity.category.icon,
                  color: activity.category.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  activity.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${activity.timeStart} – ${activity.timeEnd}  ·  '
            '${activity.durationLabel}  ·  '
            '${activity.category.label.toUpperCase()}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            activity.description,
            style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _notificationsEnabled,
            onChanged: _loadingPreference ? null : _toggleNotifications,
            activeThumbColor: AppColors.primary,
            title: const Text(
              '🔔 Notificación activada',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
          if (canMark) ...[
            const SizedBox(height: 8),
            if (_isToday && status == ActivityStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      onPressed: () => _mark(ActivityStatus.done),
                      child: const Text('✅ Cumplí esta actividad'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                      ),
                      onPressed: () => _mark(ActivityStatus.skipped),
                      child: const Text('❌ Omitir'),
                    ),
                  ),
                ],
              )
            else if (status != ActivityStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            (status == ActivityStatus.done
                                    ? AppColors.success
                                    : AppColors.danger)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        status == ActivityStatus.done
                            ? '✅ Cumplida'
                            : '❌ Omitida',
                        style: TextStyle(
                          color: status == ActivityStatus.done
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () =>
                        setState(() => _localStatus = ActivityStatus.pending),
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
