// Genera assets/icon/app_icon.png (ícono completo, fondo incluido) y
// assets/icon/app_icon_foreground.png (solo el rayo, fondo transparente,
// para el adaptive icon de Android) a partir de formas vectoriales simples.
//
// Uso: dart run tool/generate_icon.dart
import 'dart:io';

import 'package:image/image.dart' as img;

// Paleta de la app (ver lib/core/constants/colors.dart).
final _background = img.ColorRgba8(0x0F, 0x11, 0x17, 255);
final _bolt = img.ColorRgba8(0xEA, 0xB3, 0x08, 255);
final _boltTransparent = img.ColorRgba8(0xEA, 0xB3, 0x08, 0);

/// Puntos normalizados (0..1) de un rayo estilo "⚡", en el mismo espíritu
/// del ícono Material "bolt".
const List<List<double>> _boltShape = [
  [0.62, 0.04],
  [0.28, 0.56],
  [0.46, 0.56],
  [0.38, 0.96],
  [0.74, 0.42],
  [0.54, 0.42],
];

List<img.Point> _scaledBolt(int size, double scale) {
  final margin = size * (1 - scale) / 2;
  return _boltShape
      .map(
        (p) => img.Point(
          margin + p[0] * size * scale,
          margin + p[1] * size * scale,
        ),
      )
      .toList();
}

void main() {
  const size = 1024;

  // Ícono completo: fondo oscuro sólido + rayo, usado para iOS, Android
  // (dispositivos sin adaptive icons) y como imagen del splash screen.
  final full = img.Image(width: size, height: size, numChannels: 4);
  img.fill(full, color: _background);
  img.fillPolygon(full, vertices: _scaledBolt(size, 0.68), color: _bolt);

  // Foreground del adaptive icon: solo el rayo, fondo transparente, con más
  // margen para quedar dentro de la "zona segura" que Android no recorta.
  final foreground = img.Image(width: size, height: size, numChannels: 4);
  img.fill(foreground, color: _boltTransparent);
  img.fillPolygon(
    foreground,
    vertices: _scaledBolt(size, 0.5),
    color: _bolt,
  );

  final dir = Directory('assets/icon');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(full));
  File(
    'assets/icon/app_icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(foreground));

  stdout.writeln('Generado assets/icon/app_icon.png y app_icon_foreground.png');
}
