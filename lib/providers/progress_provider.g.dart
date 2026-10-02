// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dayStatsHash() => r'62ff8ef9e75128253031bc4b31b98f5fbc8971d6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Estadísticas agregadas (hechas / omitidas / totales) para una fecha.
///
/// Copied from [dayStats].
@ProviderFor(dayStats)
const dayStatsProvider = DayStatsFamily();

/// Estadísticas agregadas (hechas / omitidas / totales) para una fecha.
///
/// Copied from [dayStats].
class DayStatsFamily extends Family<AsyncValue<DayStats>> {
  /// Estadísticas agregadas (hechas / omitidas / totales) para una fecha.
  ///
  /// Copied from [dayStats].
  const DayStatsFamily();

  /// Estadísticas agregadas (hechas / omitidas / totales) para una fecha.
  ///
  /// Copied from [dayStats].
  DayStatsProvider call(String date) {
    return DayStatsProvider(date);
  }

  @override
  DayStatsProvider getProviderOverride(covariant DayStatsProvider provider) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dayStatsProvider';
}

/// Estadísticas agregadas (hechas / omitidas / totales) para una fecha.
///
/// Copied from [dayStats].
class DayStatsProvider extends AutoDisposeFutureProvider<DayStats> {
  /// Estadísticas agregadas (hechas / omitidas / totales) para una fecha.
  ///
  /// Copied from [dayStats].
  DayStatsProvider(String date)
    : this._internal(
        (ref) => dayStats(ref as DayStatsRef, date),
        from: dayStatsProvider,
        name: r'dayStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dayStatsHash,
        dependencies: DayStatsFamily._dependencies,
        allTransitiveDependencies: DayStatsFamily._allTransitiveDependencies,
        date: date,
      );

  DayStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    FutureOr<DayStats> Function(DayStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DayStatsProvider._internal(
        (ref) => create(ref as DayStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DayStats> createElement() {
    return _DayStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DayStatsProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DayStatsRef on AutoDisposeFutureProviderRef<DayStats> {
  /// The parameter `date` of this provider.
  String get date;
}

class _DayStatsProviderElement
    extends AutoDisposeFutureProviderElement<DayStats>
    with DayStatsRef {
  _DayStatsProviderElement(super.provider);

  @override
  String get date => (origin as DayStatsProvider).date;
}

String _$weekStatsHash() => r'df6962d416223b740fc5205a7f2ef04cbec07425';

/// Estadísticas agregadas de una semana completa (lunes a domingo), a partir
/// de la fecha ("yyyy-MM-dd") de su lunes.
///
/// Copied from [weekStats].
@ProviderFor(weekStats)
const weekStatsProvider = WeekStatsFamily();

/// Estadísticas agregadas de una semana completa (lunes a domingo), a partir
/// de la fecha ("yyyy-MM-dd") de su lunes.
///
/// Copied from [weekStats].
class WeekStatsFamily extends Family<AsyncValue<DayStats>> {
  /// Estadísticas agregadas de una semana completa (lunes a domingo), a partir
  /// de la fecha ("yyyy-MM-dd") de su lunes.
  ///
  /// Copied from [weekStats].
  const WeekStatsFamily();

  /// Estadísticas agregadas de una semana completa (lunes a domingo), a partir
  /// de la fecha ("yyyy-MM-dd") de su lunes.
  ///
  /// Copied from [weekStats].
  WeekStatsProvider call(String mondayDate) {
    return WeekStatsProvider(mondayDate);
  }

  @override
  WeekStatsProvider getProviderOverride(covariant WeekStatsProvider provider) {
    return call(provider.mondayDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weekStatsProvider';
}

/// Estadísticas agregadas de una semana completa (lunes a domingo), a partir
/// de la fecha ("yyyy-MM-dd") de su lunes.
///
/// Copied from [weekStats].
class WeekStatsProvider extends AutoDisposeFutureProvider<DayStats> {
  /// Estadísticas agregadas de una semana completa (lunes a domingo), a partir
  /// de la fecha ("yyyy-MM-dd") de su lunes.
  ///
  /// Copied from [weekStats].
  WeekStatsProvider(String mondayDate)
    : this._internal(
        (ref) => weekStats(ref as WeekStatsRef, mondayDate),
        from: weekStatsProvider,
        name: r'weekStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekStatsHash,
        dependencies: WeekStatsFamily._dependencies,
        allTransitiveDependencies: WeekStatsFamily._allTransitiveDependencies,
        mondayDate: mondayDate,
      );

  WeekStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mondayDate,
  }) : super.internal();

  final String mondayDate;

  @override
  Override overrideWith(
    FutureOr<DayStats> Function(WeekStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeekStatsProvider._internal(
        (ref) => create(ref as WeekStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mondayDate: mondayDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DayStats> createElement() {
    return _WeekStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekStatsProvider && other.mondayDate == mondayDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mondayDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeekStatsRef on AutoDisposeFutureProviderRef<DayStats> {
  /// The parameter `mondayDate` of this provider.
  String get mondayDate;
}

class _WeekStatsProviderElement
    extends AutoDisposeFutureProviderElement<DayStats>
    with WeekStatsRef {
  _WeekStatsProviderElement(super.provider);

  @override
  String get mondayDate => (origin as WeekStatsProvider).mondayDate;
}

String _$last30DaysCompletionRateHash() =>
    r'a819652a2db1b039826c17366a3aab5c6a4e9da3';

/// Porcentaje promedio de actividades cumplidas en los últimos 30 días
/// (incluyendo hoy). Se usa para calcular el Índice de Disciplina global.
///
/// Copied from [last30DaysCompletionRate].
@ProviderFor(last30DaysCompletionRate)
final last30DaysCompletionRateProvider =
    AutoDisposeFutureProvider<double>.internal(
      last30DaysCompletionRate,
      name: r'last30DaysCompletionRateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$last30DaysCompletionRateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef Last30DaysCompletionRateRef = AutoDisposeFutureProviderRef<double>;
String _$currentStreakHash() => r'e0c31817b4ecec02e560f0cd3c06a084a112217f';

/// Cuenta los días consecutivos (terminando hoy, hacia atrás) que alcanzaron
/// [DisciplineLevel.green].
///
/// Copied from [currentStreak].
@ProviderFor(currentStreak)
final currentStreakProvider = AutoDisposeFutureProvider<int>.internal(
  currentStreak,
  name: r'currentStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentStreakRef = AutoDisposeFutureProviderRef<int>;
String _$longestStreakHash() => r'59f42ce17ce7c2d2344ae1224564e202bc2122e3';

/// Récord histórico de días consecutivos en [DisciplineLevel.green], desde
/// el primer registro de progreso guardado hasta hoy.
///
/// Copied from [longestStreak].
@ProviderFor(longestStreak)
final longestStreakProvider = AutoDisposeFutureProvider<int>.internal(
  longestStreak,
  name: r'longestStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$longestStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LongestStreakRef = AutoDisposeFutureProviderRef<int>;
String _$weekStreakHash() => r'6ddb0b877db660e332c56c95af5a15901ce967f0';

/// Cuenta las semanas consecutivas (terminando en la semana actual, hacia
/// atrás) cuyo promedio alcanzó [DisciplineLevel.green].
///
/// Copied from [weekStreak].
@ProviderFor(weekStreak)
final weekStreakProvider = AutoDisposeFutureProvider<int>.internal(
  weekStreak,
  name: r'weekStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weekStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeekStreakRef = AutoDisposeFutureProviderRef<int>;
String _$progressNotifierHash() => r'6cf1f4dd35445d1f178adfc17a1e33924fed4860';

abstract class _$ProgressNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, ActivityProgress>> {
  late final String date;

  FutureOr<Map<String, ActivityProgress>> build(String date);
}

/// Progreso (`activityId -> ActivityProgress`) para una fecha ("yyyy-MM-dd").
///
/// Copied from [ProgressNotifier].
@ProviderFor(ProgressNotifier)
const progressNotifierProvider = ProgressNotifierFamily();

/// Progreso (`activityId -> ActivityProgress`) para una fecha ("yyyy-MM-dd").
///
/// Copied from [ProgressNotifier].
class ProgressNotifierFamily
    extends Family<AsyncValue<Map<String, ActivityProgress>>> {
  /// Progreso (`activityId -> ActivityProgress`) para una fecha ("yyyy-MM-dd").
  ///
  /// Copied from [ProgressNotifier].
  const ProgressNotifierFamily();

  /// Progreso (`activityId -> ActivityProgress`) para una fecha ("yyyy-MM-dd").
  ///
  /// Copied from [ProgressNotifier].
  ProgressNotifierProvider call(String date) {
    return ProgressNotifierProvider(date);
  }

  @override
  ProgressNotifierProvider getProviderOverride(
    covariant ProgressNotifierProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'progressNotifierProvider';
}

/// Progreso (`activityId -> ActivityProgress`) para una fecha ("yyyy-MM-dd").
///
/// Copied from [ProgressNotifier].
class ProgressNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ProgressNotifier,
          Map<String, ActivityProgress>
        > {
  /// Progreso (`activityId -> ActivityProgress`) para una fecha ("yyyy-MM-dd").
  ///
  /// Copied from [ProgressNotifier].
  ProgressNotifierProvider(String date)
    : this._internal(
        () => ProgressNotifier()..date = date,
        from: progressNotifierProvider,
        name: r'progressNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$progressNotifierHash,
        dependencies: ProgressNotifierFamily._dependencies,
        allTransitiveDependencies:
            ProgressNotifierFamily._allTransitiveDependencies,
        date: date,
      );

  ProgressNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  FutureOr<Map<String, ActivityProgress>> runNotifierBuild(
    covariant ProgressNotifier notifier,
  ) {
    return notifier.build(date);
  }

  @override
  Override overrideWith(ProgressNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProgressNotifierProvider._internal(
        () => create()..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ProgressNotifier,
    Map<String, ActivityProgress>
  >
  createElement() {
    return _ProgressNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgressNotifierProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProgressNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, ActivityProgress>> {
  /// The parameter `date` of this provider.
  String get date;
}

class _ProgressNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ProgressNotifier,
          Map<String, ActivityProgress>
        >
    with ProgressNotifierRef {
  _ProgressNotifierProviderElement(super.provider);

  @override
  String get date => (origin as ProgressNotifierProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
