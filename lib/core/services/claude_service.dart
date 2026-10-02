import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Snapshot de datos reales del usuario usado para armar el prompt del
/// Mentor IA (tanto el análisis proactivo como el system prompt del chat).
class MentorContext {
  const MentorContext({
    required this.userName,
    required this.career,
    required this.university,
    required this.country,
    required this.targetDate,
    required this.daysRemaining,
    required this.stagesJson,
    required this.weekDisciplinePercent,
    required this.currentStreak,
    required this.mostSkippedActivities,
    required this.tolcSimulationsDone,
    required this.tolcAverage,
    required this.weakTopics,
    required this.italianLevel,
  });

  final String userName;
  final String career;
  final String university;
  final String country;
  final DateTime targetDate;
  final int daysRemaining;

  /// JSON con un resumen (título, estado, progreso) de cada etapa del roadmap.
  final String stagesJson;
  final int weekDisciplinePercent;
  final int currentStreak;
  final List<String> mostSkippedActivities;
  final int tolcSimulationsDone;
  final double tolcAverage;
  final List<String> weakTopics;
  final String italianLevel;
}

/// Cliente para la API de Mensajes de Anthropic (Claude), usado por el
/// Mentor IA de la app.
class ClaudeService {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';
  static const _apiKeyPrefKey = 'claude_api_key';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPrefKey);
  }

  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, apiKey);
  }

  /// Envía un mensaje a Claude junto con el historial de la conversación y
  /// un system prompt, y devuelve el texto de la respuesta.
  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, dynamic>> history,
    required String systemPrompt,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key no configurada');
    }

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': [
          ...history,
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error API: ${response.statusCode}');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content = data['content'] as List;
    return content.first['text'] as String;
  }

  /// Genera el análisis proactivo del progreso del usuario según su
  /// [MentorContext] actual.
  Future<String> generateMentorAnalysis(MentorContext context) {
    return sendMessage(
      userMessage: _buildAnalysisPrompt(context),
      history: const [],
      systemPrompt: mentorSystemPrompt(context),
    );
  }

  String _buildAnalysisPrompt(MentorContext context) {
    return 'Analiza mi progreso actual y dame recomendaciones específicas '
        'para esta semana. ¿Voy en camino de cumplir mi meta a tiempo?';
  }

  /// System prompt del Mentor IA para el [context] actual. Público para que
  /// también lo use el chat libre (mensajes escritos por el usuario), no
  /// solo el análisis proactivo.
  String mentorSystemPrompt(MentorContext ctx) {
    final skipped = ctx.mostSkippedActivities.isEmpty
        ? 'ninguna en particular'
        : ctx.mostSkippedActivities.join(', ');
    final weak = ctx.weakTopics.isEmpty
        ? 'ninguna registrada aún'
        : ctx.weakTopics.join(', ');

    return '''
Eres el mentor personal de ${ctx.userName}, quien tiene como meta estudiar ${ctx.career} en ${ctx.university}, ${ctx.country}.

DATOS ACTUALES DE ${ctx.userName}:
- Fecha objetivo: ${ctx.targetDate.toIso8601String().split('T').first} (${ctx.daysRemaining} días restantes)
- Etapas de su roadmap (JSON): ${ctx.stagesJson}
- Disciplina de esta semana: ${ctx.weekDisciplinePercent}%
- Racha actual: ${ctx.currentStreak} días
- Actividades más incumplidas: $skipped
- Simulaciones TOLC-I realizadas: ${ctx.tolcSimulationsDone} (promedio: ${ctx.tolcAverage.toStringAsFixed(1)}/50)
- Temas débiles en el TOLC-I: $weak
- Nivel de italiano actual: ${ctx.italianLevel}

REGLAS DE COMPORTAMIENTO:
1. Responde siempre en español, con un tono cálido pero directo.
2. Usa los datos reales de arriba, nunca frases genéricas.
3. Sé específico: menciona etapas, porcentajes y racha concretos cuando aplique.
4. Limita tu respuesta a un máximo de 3 párrafos, salvo que se te pida explícitamente un análisis completo.
5. Usa ocasionalmente una frase corta en italiano como gesto motivacional (p. ej. "Coraggio!", "Piano piano si va lontano.").
6. Si el desempeño es bajo, sé honesto pero constructivo: no lo minimices ni lo dramatices.
7. Cuando corresponda, sugiere ajustes concretos al plan (qué reforzar, qué simplificar, qué repetir esta semana).
''';
  }
}
