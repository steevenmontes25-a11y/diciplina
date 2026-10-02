// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$masterActivitiesHash() => r'b309978e3b4a2a4d151ab5b377241c0eb07711c9';

/// Horario maestro completo (sin filtrar por día).
///
/// Copied from [masterActivities].
@ProviderFor(masterActivities)
final masterActivitiesProvider = AutoDisposeProvider<List<Activity>>.internal(
  masterActivities,
  name: r'masterActivitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$masterActivitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MasterActivitiesRef = AutoDisposeProviderRef<List<Activity>>;
String _$scheduleForDayHash() => r'a3e7ce60a48ebf10f14f29bc9451c3e47fed087c';

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

/// Actividades del horario para un día de la semana concreto.
///
/// Copied from [scheduleForDay].
@ProviderFor(scheduleForDay)
const scheduleForDayProvider = ScheduleForDayFamily();

/// Actividades del horario para un día de la semana concreto.
///
/// Copied from [scheduleForDay].
class ScheduleForDayFamily extends Family<List<Activity>> {
  /// Actividades del horario para un día de la semana concreto.
  ///
  /// Copied from [scheduleForDay].
  const ScheduleForDayFamily();

  /// Actividades del horario para un día de la semana concreto.
  ///
  /// Copied from [scheduleForDay].
  ScheduleForDayProvider call(DayOfWeek day) {
    return ScheduleForDayProvider(day);
  }

  @override
  ScheduleForDayProvider getProviderOverride(
    covariant ScheduleForDayProvider provider,
  ) {
    return call(provider.day);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'scheduleForDayProvider';
}

/// Actividades del horario para un día de la semana concreto.
///
/// Copied from [scheduleForDay].
class ScheduleForDayProvider extends AutoDisposeProvider<List<Activity>> {
  /// Actividades del horario para un día de la semana concreto.
  ///
  /// Copied from [scheduleForDay].
  ScheduleForDayProvider(DayOfWeek day)
    : this._internal(
        (ref) => scheduleForDay(ref as ScheduleForDayRef, day),
        from: scheduleForDayProvider,
        name: r'scheduleForDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$scheduleForDayHash,
        dependencies: ScheduleForDayFamily._dependencies,
        allTransitiveDependencies:
            ScheduleForDayFamily._allTransitiveDependencies,
        day: day,
      );

  ScheduleForDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.day,
  }) : super.internal();

  final DayOfWeek day;

  @override
  Override overrideWith(
    List<Activity> Function(ScheduleForDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ScheduleForDayProvider._internal(
        (ref) => create(ref as ScheduleForDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        day: day,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Activity>> createElement() {
    return _ScheduleForDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduleForDayProvider && other.day == day;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, day.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ScheduleForDayRef on AutoDisposeProviderRef<List<Activity>> {
  /// The parameter `day` of this provider.
  DayOfWeek get day;
}

class _ScheduleForDayProviderElement
    extends AutoDisposeProviderElement<List<Activity>>
    with ScheduleForDayRef {
  _ScheduleForDayProviderElement(super.provider);

  @override
  DayOfWeek get day => (origin as ScheduleForDayProvider).day;
}

String _$todayScheduleHash() => r'bdd25b3d28d808f26811da02915e19e292668b1b';

/// Actividades del horario para el día de hoy.
///
/// Copied from [todaySchedule].
@ProviderFor(todaySchedule)
final todayScheduleProvider = AutoDisposeProvider<List<Activity>>.internal(
  todaySchedule,
  name: r'todayScheduleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayScheduleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayScheduleRef = AutoDisposeProviderRef<List<Activity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
