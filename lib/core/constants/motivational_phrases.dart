/// Frases motivacionales del Dashboard. A diferencia de las de
/// [DreamBoardScreen] (aleatorias por sesión), estas cambian una vez por
/// día: la misma fecha siempre produce la misma frase.
const List<String> motivationalPhrases = [
  'La disciplina de hoy es la libertad de mañana.',
  'Ogni giorno un passo avanti.',
  'No cuentan los días perfectos, cuentan los días que no te rendiste.',
  'Il tuo sogno è più vicino di ieri.',
  'La constancia construye lo que el talento solo, no puede.',
  'Chi studia, arriva.',
  'El esfuerzo silencioso hace el ruido más fuerte.',
  'Piano piano si va lontano.',
  'Tu futuro te lo agradecerá.',
  'Disciplina è libertà.',
  'Un pequeño progreso cada día suma a grandes resultados.',
  'Coraggio! Ogni sforzo conta.',
];

/// Frase del día, determinística según [date] (por defecto hoy): la misma
/// fecha siempre elige la misma frase de [motivationalPhrases].
String motivationalPhraseForDate([DateTime? date]) {
  final day = date ?? DateTime.now();
  final dayOfYear = int.parse(
    '${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}',
  );
  return motivationalPhrases[dayOfYear % motivationalPhrases.length];
}
