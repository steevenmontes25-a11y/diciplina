import '../models/activity.dart';

const List<DayOfWeek> _lunesAJueves = [
  DayOfWeek.lunes,
  DayOfWeek.martes,
  DayOfWeek.miercoles,
  DayOfWeek.jueves,
];

/// Horario maestro completo de la disciplina diaria.
const List<Activity> masterSchedule = [
  // ---------------------------------------------------------------------
  // Lunes a jueves (147 pts máximo)
  // ---------------------------------------------------------------------
  Activity(
    id: 'lj_despertar_higiene',
    timeStart: '06:00',
    timeEnd: '06:30',
    title: 'Despertar e Higiene Inicial',
    description:
        'Cepillado de dientes, vaso de agua y alistarte con ropa deportiva.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_ejercicio',
    timeStart: '06:30',
    timeEnd: '07:30',
    title: 'Ejercicio / Entrenamiento',
    description: 'Tu hora diaria de actividad física.',
    category: ActivityCategory.ejercicio,
    points: 20,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_bano_skincare_manana',
    timeStart: '07:30',
    timeEnd: '08:15',
    title: 'Baño + Rutina de Skin Care de Mañana',
    description:
        'Te bañas inmediatamente después de entrenar y aplicas tus productos de la mañana.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_desayuno_lectura',
    timeStart: '08:15',
    timeEnd: '09:00',
    title: 'Desayuno + Preparación del Almuerzo + Lectura (Negocios)',
    description:
        'Comes bien, deseas avanzado el almuerzo y lees un poco de negocios.',
    category: ActivityCategory.salud,
    points: 8,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_bloque_app',
    timeStart: '09:00',
    timeEnd: '12:00',
    title: 'Bloque App (3 horas)',
    description: 'Enfoque total en el desarrollo de tu aplicación.',
    category: ActivityCategory.trabajo,
    points: 25,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_bloque_album',
    timeStart: '12:00',
    timeEnd: '13:30',
    title: 'Bloque Álbum / Música (1.5 horas)',
    description: 'Canto, guitarra y composición para el álbum.',
    category: ActivityCategory.musica,
    points: 15,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_almuerzo_orden',
    timeStart: '13:30',
    timeEnd: '14:30',
    title: 'Almuerzo y Orden Rápido',
    description:
        'Comes lo preparado y dedicas 20 minutos a recoger la casa para mantener el orden diario.',
    category: ActivityCategory.hogar,
    points: 5,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_contenido_karate',
    timeStart: '14:30',
    timeEnd: '16:00',
    title: 'Contenido y Karate Diario (1.5 horas)',
    description: 'Edición rápida de tu video diario de karate.',
    category: ActivityCategory.ejercicio,
    points: 15,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_desconexion_creativa',
    timeStart: '16:00',
    timeEnd: '17:30',
    title: 'Desconexión Creativa (1.5 horas)',
    description: 'Tiempo para dibujar y escribir tus libros.',
    category: ActivityCategory.descanso,
    points: 8,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_cena_cuidado_nocturno',
    timeStart: '17:30',
    timeEnd: '18:45',
    title: 'Cena, Cocina y Cuidado Personal Nocturno',
    description:
        'Preparas la cena, cenas ligero, te cepillas los dientes y aplicas tu rutina de skin care de noche.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_italiano_virtual',
    timeStart: '19:00',
    timeEnd: '20:00',
    title: 'Clase de Italiano (Virtual)',
    description: 'Tu clase semanal de italiano en línea.',
    category: ActivityCategory.estudio,
    points: 18,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_bloque_reuniones',
    timeStart: '20:00',
    timeEnd: '21:30',
    title: 'Bloque de Reuniones / Flexibilidad',
    description:
        'Espacio protegido para las reuniones que te programen a las 8:00 PM. Si no hay reunión, es tu tiempo libre.',
    category: ActivityCategory.reunion,
    points: 8,
    days: _lunesAJueves,
  ),
  Activity(
    id: 'lj_a_dormir',
    timeStart: '22:00',
    timeEnd: '22:00',
    title: 'A dormir',
    description: 'A dormir para asegurar tus 8 horas de descanso.',
    category: ActivityCategory.descanso,
    points: 10,
    isAlarmEnabled: true,
    days: _lunesAJueves,
  ),

  // ---------------------------------------------------------------------
  // Viernes (95 pts máximo)
  // ---------------------------------------------------------------------
  Activity(
    id: 'vi_despertar_higiene',
    timeStart: '06:00',
    timeEnd: '06:30',
    title: 'Despertar e Higiene',
    description:
        'Cepillado de dientes, vaso de agua y alistarte con ropa deportiva.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: [DayOfWeek.viernes],
  ),
  Activity(
    id: 'vi_ejercicio',
    timeStart: '06:30',
    timeEnd: '07:30',
    title: 'Ejercicio / Entrenamiento',
    description: 'Tu hora diaria de actividad física.',
    category: ActivityCategory.ejercicio,
    points: 20,
    isAlarmEnabled: true,
    days: [DayOfWeek.viernes],
  ),
  Activity(
    id: 'vi_bano_skincare',
    timeStart: '07:30',
    timeEnd: '08:15',
    title: 'Baño + Skin Care',
    description:
        'Te bañas inmediatamente después de entrenar y aplicas tus productos de la mañana.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: [DayOfWeek.viernes],
  ),
  Activity(
    id: 'vi_bloque_app',
    timeStart: '08:15',
    timeEnd: '11:00',
    title: 'Bloque App',
    description: 'Enfoque total en el desarrollo de tu aplicación.',
    category: ActivityCategory.trabajo,
    points: 25,
    isAlarmEnabled: true,
    days: [DayOfWeek.viernes],
  ),
  Activity(
    id: 'vi_edicion_express',
    timeStart: '11:00',
    timeEnd: '12:00',
    title: 'Edición Express y Orden',
    description: 'Dejas listo el video de karate del día.',
    category: ActivityCategory.trabajo,
    points: 10,
    isAlarmEnabled: true,
    days: [DayOfWeek.viernes],
  ),
  Activity(
    id: 'vi_almuerzo_rapido',
    timeStart: '12:00',
    timeEnd: '12:30',
    title: 'Almuerzo rápido y alistarse para salir',
    description:
        'Comes algo ligero y te preparas para salir a tu clase de italiano presencial.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: [DayOfWeek.viernes],
  ),
  Activity(
    id: 'vi_traslado_italiano',
    timeStart: '12:30',
    timeEnd: '21:00',
    title: 'Traslado, Clase de Italiano Presencial y Regreso a casa',
    description:
        'Traslado a tu clase de italiano presencial, la clase en sí y el regreso a casa.',
    category: ActivityCategory.traslado,
    points: 20,
    isAlarmEnabled: true,
    days: [DayOfWeek.viernes],
  ),
  Activity(
    id: 'vi_higiene_nocturna',
    timeStart: '21:00',
    timeEnd: '23:59',
    title: 'Higiene Nocturna y Descanso',
    description: 'Lavado de cara, skin care nocturno, cepillado y a la cama.',
    category: ActivityCategory.salud,
    points: 5,
    days: [DayOfWeek.viernes],
  ),

  // ---------------------------------------------------------------------
  // Sábado (75 pts máximo)
  // ---------------------------------------------------------------------
  Activity(
    id: 'sa_despertar_aseo_desayuno',
    timeStart: '06:00',
    timeEnd: '06:30',
    title: 'Despertar, aseo rápido y desayuno ligero',
    description:
        'Despiertas, te aseas rápido y desayunas algo ligero antes de entrenar.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: [DayOfWeek.sabado],
  ),
  Activity(
    id: 'sa_karate_extensivo',
    timeStart: '07:00',
    timeEnd: '15:00',
    title: 'Karate Extensivo',
    description: 'Tu entrenamiento fuerte de la semana.',
    category: ActivityCategory.ejercicio,
    points: 30,
    isAlarmEnabled: true,
    days: [DayOfWeek.sabado],
  ),
  Activity(
    id: 'sa_bano_skincare_postkarate',
    timeStart: '15:30',
    timeEnd: '16:15',
    title: 'Baño Completo + Skin Care (Post-Karate)',
    description:
        'Baño completo después del entrenamiento y aplicación de tu rutina de skin care.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: [DayOfWeek.sabado],
  ),
  Activity(
    id: 'sa_limpieza_casa',
    timeStart: '16:15',
    timeEnd: '17:15',
    title: 'Limpieza General de la Casa',
    description:
        'Limpieza general de la casa para mantener el orden del hogar.',
    category: ActivityCategory.hogar,
    points: 10,
    days: [DayOfWeek.sabado],
  ),
  Activity(
    id: 'sa_grabacion_youtube',
    timeStart: '17:15',
    timeEnd: '19:00',
    title: 'Grabación de YouTubes (Batching)',
    description: 'Grabas en bloque el contenido semanal.',
    category: ActivityCategory.trabajo,
    points: 20,
    isAlarmEnabled: true,
    days: [DayOfWeek.sabado],
  ),
  Activity(
    id: 'sa_noche_libre',
    timeStart: '19:00',
    timeEnd: '23:59',
    title: 'Noche libre para ti',
    description: 'Tiempo libre para ti, sin compromisos ni pendientes.',
    category: ActivityCategory.descanso,
    points: 5,
    days: [DayOfWeek.sabado],
  ),

  // ---------------------------------------------------------------------
  // Domingo (20 pts máximo)
  // ---------------------------------------------------------------------
  Activity(
    id: 'do_despertar_tardio',
    timeStart: '07:00',
    timeEnd: '08:00',
    title: 'Despertar tardío, baño y skin care matutino con calma',
    description:
        'Despiertas más tarde, te bañas y aplicas tu skin care matutino con calma.',
    category: ActivityCategory.salud,
    points: 5,
    isAlarmEnabled: true,
    days: [DayOfWeek.domingo],
  ),
  Activity(
    id: 'do_hobbies_mealprep',
    timeStart: '15:00',
    timeEnd: '18:00',
    title: 'Hobbies y Meal Prep',
    description: 'Dibujo, lectura, guitarra y cocinar en lote para la semana.',
    category: ActivityCategory.descanso,
    points: 15,
    days: [DayOfWeek.domingo],
  ),
];

/// Devuelve las actividades del horario maestro para un día concreto,
/// ordenadas por hora de inicio.
List<Activity> getActivitiesForDay(DayOfWeek day) {
  final activities = masterSchedule.where((a) => a.days.contains(day)).toList()
    ..sort((a, b) => a.timeStart.compareTo(b.timeStart));
  return activities;
}

/// Día de la semana de hoy, según [DateTime.now].
DayOfWeek get todayAsEnum => DayOfWeek.values[DateTime.now().weekday - 1];
