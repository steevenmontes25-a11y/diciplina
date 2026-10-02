// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentActivityHash() => r'4c1161134417ca6baaf04371fbd501ad2db41836';

/// La actividad del horario de hoy que está sucediendo ahora mismo, o
/// `null` si no hay ninguna en curso.
///
/// Copied from [currentActivity].
@ProviderFor(currentActivity)
final currentActivityProvider = AutoDisposeProvider<Activity?>.internal(
  currentActivity,
  name: r'currentActivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentActivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentActivityRef = AutoDisposeProviderRef<Activity?>;
String _$nextActivityHash() => r'31259bb326a7ca2daa60662c0f6430567ed1de36';

/// La próxima actividad del horario de hoy que todavía no empieza, o
/// `null` si ya pasó la última del día.
///
/// Copied from [nextActivity].
@ProviderFor(nextActivity)
final nextActivityProvider = AutoDisposeProvider<Activity?>.internal(
  nextActivity,
  name: r'nextActivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextActivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextActivityRef = AutoDisposeProviderRef<Activity?>;
String _$currentActivityProgressHash() =>
    r'd6c55addb2eb1d920c5d2cf0130116decf1ee716';

/// Porcentaje transcurrido (0.0 a 1.0) de la actividad devuelta por
/// [currentActivityProvider]. Asume que la actividad no cruza la
/// medianoche (ninguna del horario maestro lo hace).
///
/// Copied from [currentActivityProgress].
@ProviderFor(currentActivityProgress)
final currentActivityProgressProvider = AutoDisposeProvider<double>.internal(
  currentActivityProgress,
  name: r'currentActivityProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentActivityProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentActivityProgressRef = AutoDisposeProviderRef<double>;
String _$userNameHash() => r'467310631f4fea9b10d02741a5181c64db788cf3';

/// Nombre configurado por el usuario en Ajustes del Mentor (mismo valor que
/// personaliza el system prompt del Mentor IA), o cadena vacía si aún no
/// se configuró.
///
/// Copied from [userName].
@ProviderFor(userName)
final userNameProvider = AutoDisposeFutureProvider<String>.internal(
  userName,
  name: r'userNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserNameRef = AutoDisposeFutureProviderRef<String>;
String _$todayMoodHash() => r'3b19eb8564907c0a6080c7b2996f5de27be78811';

/// Emoji de ánimo ya registrado hoy, o `null` si todavía no se registró.
///
/// Copied from [todayMood].
@ProviderFor(todayMood)
final todayMoodProvider = AutoDisposeFutureProvider<String?>.internal(
  todayMood,
  name: r'todayMoodProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayMoodHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayMoodRef = AutoDisposeFutureProviderRef<String?>;
String _$disciplineIndexHash() => r'd076e016e7d73a0236395790a08a2db0dcd958a0';

/// Índice de Disciplina (ID): el último valor cerrado por
/// `DbHelper.closeDayRecord` (ver `DisciplineService`), 0 si el usuario
/// todavía no cerró ningún día. Es de solo lectura a propósito: no cierra
/// el día ni desbloquea logros desde aquí, para no consumir en silencio un
/// desbloqueo sin mostrar su celebración (eso pasa en DailySummaryScreen).
///
/// Copied from [disciplineIndex].
@ProviderFor(disciplineIndex)
final disciplineIndexProvider = AutoDisposeFutureProvider<int>.internal(
  disciplineIndex,
  name: r'disciplineIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$disciplineIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DisciplineIndexRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
