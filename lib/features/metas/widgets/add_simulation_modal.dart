import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/database/db_helper.dart';
import '../../../core/models/goal.dart';

/// Abre el modal para registrar una nueva [ExamSimulation]. Guarda
/// directamente en la base de datos y llama a [onSaved] al terminar para que
/// quien la invoque refresque sus providers.
Future<void> showAddSimulationModal(
  BuildContext context, {
  required String goalId,
  required int nextSimNumber,
  required int targetScore,
  required List<String> topicPool,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _AddSimulationForm(
      goalId: goalId,
      nextSimNumber: nextSimNumber,
      targetScore: targetScore,
      topicPool: topicPool,
      onSaved: onSaved,
    ),
  );
}

class _AddSimulationForm extends StatefulWidget {
  const _AddSimulationForm({
    required this.goalId,
    required this.nextSimNumber,
    required this.targetScore,
    required this.topicPool,
    required this.onSaved,
  });

  final String goalId;
  final int nextSimNumber;
  final int targetScore;
  final List<String> topicPool;
  final VoidCallback onSaved;

  @override
  State<_AddSimulationForm> createState() => _AddSimulationFormState();
}

class _AddSimulationFormState extends State<_AddSimulationForm> {
  final TextEditingController _scoreController = TextEditingController();
  final Set<String> _weakTopics = {};
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final score = int.tryParse(_scoreController.text.trim());
    if (score == null || score < 0 || score > 50) {
      setState(() => _error = 'Ingresa un puntaje válido entre 0 y 50');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final sim = ExamSimulation(
      id: '${widget.goalId}_sim_${DateTime.now().millisecondsSinceEpoch}',
      goalId: widget.goalId,
      examName: 'TOLC-I',
      date: _date,
      score: score,
      maxScore: 50,
      targetScore: widget.targetScore,
      weakTopics: _weakTopics.toList(),
    );

    await DbHelper.instance.insertSimulation(sim);
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulación ${widget.nextSimNumber}/40',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Fecha'),
              child: Text(
                DateFormat("d 'de' MMMM 'de' y", 'es').format(_date),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _scoreController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Puntaje (0-50)',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Temas fallados',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.topicPool.map((topic) {
              final selected = _weakTopics.contains(topic);
              return FilterChip(
                label: Text(topic),
                selected: selected,
                onSelected: (value) => setState(() {
                  if (value) {
                    _weakTopics.add(topic);
                  } else {
                    _weakTopics.remove(topic);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
