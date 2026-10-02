import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/colors.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/goal.dart';
import '../../providers/goals_provider.dart';
import 'widgets/animated_progress_arc.dart';
import 'widgets/flip_countdown.dart';

const List<String> _motivationalPhrases = [
  'La disciplina de hoy es la libertad de mañana.',
  'Ogni giorno un passo avanti.',
  'Bologna ti aspetta.',
  'Il tuo sogno è a 248 giorni.',
  'La constancia construye imperios.',
  'Chi studia, arriva.',
  'El esfuerzo silencioso hace el ruido más fuerte.',
  'Ogni ora conta.',
  'Tu futuro te lo agradecerá.',
  'Disciplina è libertà.',
];

/// Pantalla inmersiva e inspiradora de una meta: foto del sueño, countdown
/// animado, y progreso general.
class DreamBoardScreen extends ConsumerStatefulWidget {
  const DreamBoardScreen({super.key, required this.goal});

  final LifeGoal goal;

  @override
  ConsumerState<DreamBoardScreen> createState() => _DreamBoardScreenState();
}

class _DreamBoardScreenState extends ConsumerState<DreamBoardScreen> {
  late final String _phrase =
      _motivationalPhrases[Random().nextInt(_motivationalPhrases.length)];
  bool _pickingImage = false;

  Future<void> _pickImage(String goalId) async {
    setState(() => _pickingImage = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        await DbHelper.instance.updateGoalDreamImagePath(goalId, picked.path);
        ref.invalidate(activeGoalProvider);
      }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(activeGoalProvider);
    final goal = goalAsync.valueOrNull ?? widget.goal;
    final stagesAsync = ref.watch(goalStagesProvider(goal.id));
    final stages = stagesAsync.valueOrNull ?? goal.stages;
    final overallProgress = stages.isEmpty
        ? 0.0
        : stages.map((s) => s.progress).reduce((a, b) => a + b) / stages.length;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _CampusPhoto(goal: goal),
              const SizedBox(height: 24),
              const Text('🎯', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                goal.university,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                goal.career,
                style: const TextStyle(color: AppColors.primary, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(goal.country, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 32),
              RepaintBoundary(
                child: FlipCountdown(targetDate: goal.targetDate),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.warning),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🏆 Objetivo',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Beca DSU · Università di Bologna',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Progreso hacia tu sueño',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              RepaintBoundary(
                child: AnimatedProgressArc(percentage: overallProgress),
              ),
              const SizedBox(height: 12),
              Text(
                '${(overallProgress.clamp(0, 1) * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '"$_phrase"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickingImage ? null : () => _pickImage(goal.id),
                icon: _pickingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Cambiar foto del campus'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampusPhoto extends StatelessWidget {
  const _CampusPhoto({required this.goal});

  final LifeGoal goal;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.4;
    final imagePath = goal.dreamImagePath;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: imagePath != null
            ? Image.file(File(imagePath), fit: BoxFit.cover)
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A0A3E), AppColors.primary],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.account_balance_outlined,
                  size: 64,
                  color: Colors.white70,
                ),
              ),
      ),
    );
  }
}
