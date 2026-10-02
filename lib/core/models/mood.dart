/// Una opción de estado de ánimo seleccionable desde el Dashboard.
class Mood {
  const Mood(this.emoji, this.label);

  final String emoji;
  final String label;
}

/// Las 6 opciones de ánimo mostradas en el Dashboard. El emoji es lo que
/// se persiste en `mood_entries.mood`.
const List<Mood> moodOptions = [
  Mood('😀', 'Feliz'),
  Mood('😌', 'Tranquilo'),
  Mood('😐', 'Neutral'),
  Mood('😔', 'Triste'),
  Mood('😴', 'Cansado'),
  Mood('😖', 'Estresado'),
];

/// Etiqueta legible para un [emoji] de ánimo ya guardado, o cadena vacía
/// si no coincide con ninguna opción conocida.
String moodLabelForEmoji(String emoji) {
  for (final mood in moodOptions) {
    if (mood.emoji == emoji) return mood.label;
  }
  return '';
}
