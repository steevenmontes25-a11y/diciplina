import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/schedule_data.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/activity.dart';
import '../../core/models/daily_record.dart';
import '../../core/models/day_progress.dart';
import '../../core/services/claude_service.dart';
import '../../providers/mentor_provider.dart' show mentorUserNamePrefKey;
import 'widgets/achievement_unlock_overlay.dart';

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _emojiForLevel(DisciplineLevel level) => switch (level) {
  DisciplineLevel.green => '🟢',
  DisciplineLevel.yellow => '🟡',
  DisciplineLevel.red => '🔴',
};

/// Presenta el [DailySummaryScreen] como modal bottom sheet (85% de la
/// pantalla), tal como se abre al tocar la notificación del resumen
/// nocturno o desde cualquier punto de la app.
Future<void> showDailySummarySheet(BuildContext context, {String? date}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.85,
      child: DailySummaryScreen(date: date),
    ),
  );
}

/// Resumen nocturno de un día: disciplina, puntos, Índice de Disciplina,
/// racha, actividades y un comentario del Mentor IA generado al vuelo.
class DailySummaryScreen extends ConsumerStatefulWidget {
  const DailySummaryScreen({super.key, this.date});

  /// Fecha ("yyyy-MM-dd") a resumir. `null` = hoy.
  final String? date;

  @override
  ConsumerState<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends ConsumerState<DailySummaryScreen> {
  late final String _date =
      widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  DayCloseResult? _result;
  List<ActivityProgress> _progresses = const [];
  String? _mentorComment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await DbHelper.instance.closeDayRecord(_date);
    final progresses = await DbHelper.instance.getProgressForDate(_date);
    if (!mounted) return;
    setState(() {
      _result = result;
      _progresses = progresses;
      _loading = false;
    });

    unawaited(_generateMentorComment(result));

    for (final achievement in result.newlyUnlockedAchievements) {
      if (!mounted) return;
      await showAchievementUnlockOverlay(context, achievement);
    }
  }

  Future<void> _generateMentorComment(DayCloseResult result) async {
    final activities = _activitiesForDate();
    final done = <String>[];
    final missed = <String>[];
    for (final activity in activities) {
      final status = _statusFor(activity.id);
      (status == ActivityStatus.done ? done : missed).add(activity.title);
    }

    final comment = await _tryClaudeComment(result, done, missed);
    if (!mounted) return;
    setState(() => _mentorComment = comment ?? _fallbackComment(result));
  }

  Future<String?> _tryClaudeComment(
    DayCloseResult result,
    List<String> done,
    List<String> missed,
  ) async {
    final claude = ClaudeService();
    final apiKey = await claude.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;

    try {
      final prefs = await _userName();
      final systemPrompt =
          'Eres el mentor personal de $prefs. Escribe un comentario breve '
          '(2-3 líneas, sin markdown) sobre el día que acaba de tener, '
          'usando estos datos reales: disciplina ${(result.percentage * 100).round()}% '
          '(${result.level.name}), ${result.earnedPoints}/${result.totalPoints} puntos, '
          'racha actual de ${result.currentStreak} días. '
          'Actividades cumplidas: ${done.isEmpty ? "ninguna" : done.join(", ")}. '
          'Actividades omitidas: ${missed.isEmpty ? "ninguna" : missed.join(", ")}. '
          'Sé cálido pero honesto: si algo se repite como punto débil, dilo. '
          'Cierra con una nota sobre mañana.';
      return await claude.sendMessage(
        userMessage: 'Comenta mi día de hoy.',
        history: const [],
        systemPrompt: systemPrompt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _userName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(mentorUserNamePrefKey);
    return (name == null || name.isEmpty) ? 'tú' : name;
  }

  String _fallbackComment(DayCloseResult result) {
    return switch (result.level) {
      DisciplineLevel.green =>
        'Día en verde: cumpliste ${result.earnedPoints}/${result.totalPoints} '
            'puntos. Mantén este ritmo, se nota.',
      DisciplineLevel.yellow =>
        'Día parcial: llegaste a ${(result.percentage * 100).round()}%. '
            'Todavía puedes cerrar mañana en verde.',
      DisciplineLevel.red =>
        'Día difícil, ${(result.percentage * 100).round()}% completado. '
            'Mañana es una nueva oportunidad de retomar el ritmo.',
    };
  }

  List<Activity> _activitiesForDate() {
    final weekday = DateTime.parse(_date).weekday;
    return getActivitiesForDay(DayOfWeek.values[weekday - 1]);
  }

  ActivityStatus _statusFor(String activityId) {
    for (final p in _progresses) {
      if (p.activityId == activityId) return p.status;
    }
    return ActivityStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _result == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final result = _result!;
    final date = DateTime.parse(_date);

    return SafeArea(
      top: false,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              children: [
                const Text(
                  'Resumen del día',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _capitalize(
                    DateFormat("EEEE, d 'de' MMMM", 'es').format(date),
                  ),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _emojiForLevel(result.level),
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
                const SizedBox(height: 20),
                _StatsGrid(result: result),
                const SizedBox(height: 24),
                const Text(
                  'ACTIVIDADES',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                for (final activity in _activitiesForDate())
                  _ActivityRow(
                    activity: activity,
                    status: _statusFor(activity.id),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🧠', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _mentorComment == null
                            ? const _MentorCommentLoading()
                            : Text(
                                _mentorComment!,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/diario');
                    },
                    child: const Text('📝 Escribir en el diario'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK, a dormir'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorCommentLoading extends StatelessWidget {
  const _MentorCommentLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 16,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.result});

  final DayCloseResult result;

  @override
  Widget build(BuildContext context) {
    final deltaSign = result.disciplineIndexDelta >= 0 ? '+' : '';
    final deltaArrow = result.disciplineIndexDelta >= 0 ? '↑' : '↓';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'Disciplina',
                value:
                    '${(result.percentage * 100).round()}%  '
                    '${_emojiForLevel(result.level)}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCell(
                label: 'Puntos',
                value: '${result.earnedPoints} / ${result.totalPoints}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'ID hoy',
                value:
                    '${result.disciplineIndex.round()} '
                    '($deltaSign${result.disciplineIndexDelta.round()}) $deltaArrow',
                valueColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCell(
                label: 'Racha',
                value: '🔥 ${result.currentStreak} días',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity, required this.status});

  final Activity activity;
  final ActivityStatus status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      ActivityStatus.done => '✅',
      ActivityStatus.skipped => '❌',
      ActivityStatus.pending => '➖',
    };
    final pointsLabel = status == ActivityStatus.done
        ? '${activity.points} pts'
        : '0/${activity.points} pts';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            pointsLabel,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
