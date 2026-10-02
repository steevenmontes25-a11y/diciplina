import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/claude_service.dart';
import '../../providers/mentor_provider.dart';

const String _lastProactiveDatePrefKey = 'mentor_last_proactive_date';

const List<String> _quickSuggestions = [
  '¿Cómo voy esta semana?',
  '¿Llegaré a tiempo?',
  'Refuerza mi motivación',
  'Plan para mañana',
  'Analiza mi TOLC-I',
  'Consejo de italiano',
];

/// Chat real con el Mentor IA (Claude), con análisis proactivo al abrir por
/// primera vez en el día y sugerencias rápidas.
class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ClaudeService _claude = ClaudeService();

  List<Map<String, dynamic>> _history = const [];
  bool _loadingHistory = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadHistory();
    await _maybeSendProactiveAnalysis();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await DbHelper.instance.getAiHistory(
        widget.goalId,
        limit: 100,
      );
      if (!mounted) return;
      setState(() {
        _history = history;
        _loadingHistory = false;
      });
    } catch (_) {
      // Si falla la lectura local, no dejamos la pantalla cargando para
      // siempre: se muestra el estado vacío y el chat sigue siendo usable.
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  /// Al abrir el chat por primera vez en el día (y solo si ya hay una API
  /// key configurada), pide un análisis proactivo y lo muestra como primer
  /// mensaje del mentor.
  Future<void> _maybeSendProactiveAnalysis() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastDate = await DbHelper.instance.getPreference(
        _lastProactiveDatePrefKey,
      );
      if (lastDate == today) return;

      final apiKey = await _claude.getApiKey();
      if (apiKey == null || apiKey.isEmpty) return;

      setState(() => _sending = true);
      final mentorCtx = await ref.read(
        mentorContextProvider(widget.goalId).future,
      );
      final analysis = await _claude.generateMentorAnalysis(mentorCtx);
      await DbHelper.instance.saveAiMessage(
        widget.goalId,
        analysis,
        'mentor',
        const {},
      );
      await DbHelper.instance.setPreference(_lastProactiveDatePrefKey, today);
      await _loadHistory();
    } catch (_) {
      // Si falla (sin red, error del servidor, etc.) el usuario igual puede
      // usar el chat normalmente; no se marca como ya enviado hoy.
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Convierte el historial local (más reciente primero) al formato
  /// cronológico que espera la API de Mensajes.
  List<Map<String, dynamic>> _apiHistory() {
    final chronological = _history.reversed.toList();
    return chronological
        .map(
          (e) => {
            'role': e['role'] == 'user' ? 'user' : 'assistant',
            'content': e['message'] as String,
          },
        )
        .toList();
  }

  Future<void> _send([String? quickText]) async {
    final text = quickText ?? _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();

    final historyForApi = _apiHistory();
    await DbHelper.instance.saveAiMessage(
      widget.goalId,
      text,
      'user',
      const {},
    );
    await _loadHistory();
    setState(() => _sending = true);

    try {
      final mentorCtx = await ref.read(
        mentorContextProvider(widget.goalId).future,
      );
      final reply = await _claude.sendMessage(
        userMessage: text,
        history: historyForApi,
        systemPrompt: _claude.mentorSystemPrompt(mentorCtx),
      );
      await DbHelper.instance.saveAiMessage(
        widget.goalId,
        reply,
        'mentor',
        const {},
      );
    } catch (e) {
      final isMissingKey = e.toString().contains('API key no configurada');
      final message = isMissingKey
          ? 'Configura tu API key de Claude en Ajustes (⚙️) para poder '
                'hablar con tu mentor.'
          : 'No pude conectar con tu mentor ahora mismo. Inténtalo de nuevo '
                'en un momento.';
      await DbHelper.instance.saveAiMessage(
        widget.goalId,
        message,
        'mentor',
        const {},
      );
    } finally {
      await _loadHistory();
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🧠 Mentor IA',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Claude Sonnet',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/mentor/settings'),
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessages()),
            _QuickSuggestionsBar(
              onTap: _sending ? null : (text) => _send(text),
            ),
            _InputBar(
              controller: _controller,
              enabled: !_sending,
              onSend: () => _send(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_history.isEmpty && !_sending) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Cuéntale a tu mentor cómo va tu camino a Bologna.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final itemCount = _history.length + (_sending ? 1 : 0);
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (_sending && index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                _MentorAvatar(),
                SizedBox(width: 8),
                _TypingIndicator(),
              ],
            ),
          );
        }
        final entry = _history[index - (_sending ? 1 : 0)];
        return _ChatBubble(
          text: entry['message'] as String,
          isUser: entry['role'] == 'user',
          timestamp: DateTime.parse(entry['created_at'] as String),
        );
      },
    );
  }
}

class _MentorAvatar extends StatelessWidget {
  const _MentorAvatar();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      child: const Text('🧠', style: TextStyle(fontSize: 14)),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.zero,
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 400.ms, delay: (i * 150).ms)
              .then()
              .fadeOut(duration: 400.ms);
        }),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 12 : 0),
          topRight: Radius.circular(isUser ? 0 : 12),
          bottomLeft: const Radius.circular(12),
          bottomRight: const Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(timestamp),
            style: TextStyle(
              color: isUser
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: isUser
          ? Align(alignment: Alignment.centerRight, child: bubble)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _MentorAvatar(),
                const SizedBox(width: 8),
                Flexible(child: bubble),
              ],
            ),
    );
  }
}

class _QuickSuggestionsBar extends StatelessWidget {
  const _QuickSuggestionsBar({required this.onTap});

  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = _quickSuggestions[index];
          return ActionChip(
            label: Text(suggestion),
            backgroundColor: AppColors.surface,
            labelStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
            onPressed: onTap == null ? null : () => onTap!(suggestion),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Pregunta a tu mentor...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: enabled ? onSend : null,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            icon: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
