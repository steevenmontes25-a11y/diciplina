// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeGoalHash() => r'dde340733f68f8e51d7f6549c18677c68379023f';

/// La meta de vida activa (normalmente solo hay una), con sus etapas ya
/// incluidas.
///
/// Copied from [activeGoal].
@ProviderFor(activeGoal)
final activeGoalProvider = AutoDisposeFutureProvider<LifeGoal?>.internal(
  activeGoal,
  name: r'activeGoalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeGoalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveGoalRef = AutoDisposeFutureProviderRef<LifeGoal?>;
String _$allGoalsHash() => r'96773afd527dffdf09e9e3976c4a928c987b135e';

/// Todas las metas de vida registradas (activas, pausadas, completadas...),
/// con sus etapas ya incluidas. Usada por el tab "Metas" de Progreso.
///
/// Copied from [allGoals].
@ProviderFor(allGoals)
final allGoalsProvider = AutoDisposeFutureProvider<List<LifeGoal>>.internal(
  allGoals,
  name: r'allGoalsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allGoalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllGoalsRef = AutoDisposeFutureProviderRef<List<LifeGoal>>;
String _$goalStagesHash() => r'11f535592c68bbc8a8a11d6c86ecb8c5dddfbd09';

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

/// Etapas (con tareas y recursos) de una meta concreta.
///
/// Copied from [goalStages].
@ProviderFor(goalStages)
const goalStagesProvider = GoalStagesFamily();

/// Etapas (con tareas y recursos) de una meta concreta.
///
/// Copied from [goalStages].
class GoalStagesFamily extends Family<AsyncValue<List<GoalStage>>> {
  /// Etapas (con tareas y recursos) de una meta concreta.
  ///
  /// Copied from [goalStages].
  const GoalStagesFamily();

  /// Etapas (con tareas y recursos) de una meta concreta.
  ///
  /// Copied from [goalStages].
  GoalStagesProvider call(String goalId) {
    return GoalStagesProvider(goalId);
  }

  @override
  GoalStagesProvider getProviderOverride(
    covariant GoalStagesProvider provider,
  ) {
    return call(provider.goalId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'goalStagesProvider';
}

/// Etapas (con tareas y recursos) de una meta concreta.
///
/// Copied from [goalStages].
class GoalStagesProvider extends AutoDisposeFutureProvider<List<GoalStage>> {
  /// Etapas (con tareas y recursos) de una meta concreta.
  ///
  /// Copied from [goalStages].
  GoalStagesProvider(String goalId)
    : this._internal(
        (ref) => goalStages(ref as GoalStagesRef, goalId),
        from: goalStagesProvider,
        name: r'goalStagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$goalStagesHash,
        dependencies: GoalStagesFamily._dependencies,
        allTransitiveDependencies: GoalStagesFamily._allTransitiveDependencies,
        goalId: goalId,
      );

  GoalStagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.goalId,
  }) : super.internal();

  final String goalId;

  @override
  Override overrideWith(
    FutureOr<List<GoalStage>> Function(GoalStagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GoalStagesProvider._internal(
        (ref) => create(ref as GoalStagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        goalId: goalId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GoalStage>> createElement() {
    return _GoalStagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalStagesProvider && other.goalId == goalId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, goalId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GoalStagesRef on AutoDisposeFutureProviderRef<List<GoalStage>> {
  /// The parameter `goalId` of this provider.
  String get goalId;
}

class _GoalStagesProviderElement
    extends AutoDisposeFutureProviderElement<List<GoalStage>>
    with GoalStagesRef {
  _GoalStagesProviderElement(super.provider);

  @override
  String get goalId => (origin as GoalStagesProvider).goalId;
}

String _$currentWeekPlanHash() => r'5392adcefbec788ceb2b6bb5afe1068d7af968cb';

/// El plan semanal cuyo lunes es el de la semana actual, si ya existe.
///
/// Copied from [currentWeekPlan].
@ProviderFor(currentWeekPlan)
const currentWeekPlanProvider = CurrentWeekPlanFamily();

/// El plan semanal cuyo lunes es el de la semana actual, si ya existe.
///
/// Copied from [currentWeekPlan].
class CurrentWeekPlanFamily extends Family<AsyncValue<WeeklyPlan?>> {
  /// El plan semanal cuyo lunes es el de la semana actual, si ya existe.
  ///
  /// Copied from [currentWeekPlan].
  const CurrentWeekPlanFamily();

  /// El plan semanal cuyo lunes es el de la semana actual, si ya existe.
  ///
  /// Copied from [currentWeekPlan].
  CurrentWeekPlanProvider call(String goalId) {
    return CurrentWeekPlanProvider(goalId);
  }

  @override
  CurrentWeekPlanProvider getProviderOverride(
    covariant CurrentWeekPlanProvider provider,
  ) {
    return call(provider.goalId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currentWeekPlanProvider';
}

/// El plan semanal cuyo lunes es el de la semana actual, si ya existe.
///
/// Copied from [currentWeekPlan].
class CurrentWeekPlanProvider extends AutoDisposeFutureProvider<WeeklyPlan?> {
  /// El plan semanal cuyo lunes es el de la semana actual, si ya existe.
  ///
  /// Copied from [currentWeekPlan].
  CurrentWeekPlanProvider(String goalId)
    : this._internal(
        (ref) => currentWeekPlan(ref as CurrentWeekPlanRef, goalId),
        from: currentWeekPlanProvider,
        name: r'currentWeekPlanProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$currentWeekPlanHash,
        dependencies: CurrentWeekPlanFamily._dependencies,
        allTransitiveDependencies:
            CurrentWeekPlanFamily._allTransitiveDependencies,
        goalId: goalId,
      );

  CurrentWeekPlanProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.goalId,
  }) : super.internal();

  final String goalId;

  @override
  Override overrideWith(
    FutureOr<WeeklyPlan?> Function(CurrentWeekPlanRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentWeekPlanProvider._internal(
        (ref) => create(ref as CurrentWeekPlanRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        goalId: goalId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WeeklyPlan?> createElement() {
    return _CurrentWeekPlanProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentWeekPlanProvider && other.goalId == goalId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, goalId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CurrentWeekPlanRef on AutoDisposeFutureProviderRef<WeeklyPlan?> {
  /// The parameter `goalId` of this provider.
  String get goalId;
}

class _CurrentWeekPlanProviderElement
    extends AutoDisposeFutureProviderElement<WeeklyPlan?>
    with CurrentWeekPlanRef {
  _CurrentWeekPlanProviderElement(super.provider);

  @override
  String get goalId => (origin as CurrentWeekPlanProvider).goalId;
}

String _$examSimulationsHash() => r'313d686056b346f27117584ceb8b92c003b91076';

/// Todas las simulaciones de examen registradas para una meta.
///
/// Copied from [examSimulations].
@ProviderFor(examSimulations)
const examSimulationsProvider = ExamSimulationsFamily();

/// Todas las simulaciones de examen registradas para una meta.
///
/// Copied from [examSimulations].
class ExamSimulationsFamily extends Family<AsyncValue<List<ExamSimulation>>> {
  /// Todas las simulaciones de examen registradas para una meta.
  ///
  /// Copied from [examSimulations].
  const ExamSimulationsFamily();

  /// Todas las simulaciones de examen registradas para una meta.
  ///
  /// Copied from [examSimulations].
  ExamSimulationsProvider call(String goalId) {
    return ExamSimulationsProvider(goalId);
  }

  @override
  ExamSimulationsProvider getProviderOverride(
    covariant ExamSimulationsProvider provider,
  ) {
    return call(provider.goalId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'examSimulationsProvider';
}

/// Todas las simulaciones de examen registradas para una meta.
///
/// Copied from [examSimulations].
class ExamSimulationsProvider
    extends AutoDisposeFutureProvider<List<ExamSimulation>> {
  /// Todas las simulaciones de examen registradas para una meta.
  ///
  /// Copied from [examSimulations].
  ExamSimulationsProvider(String goalId)
    : this._internal(
        (ref) => examSimulations(ref as ExamSimulationsRef, goalId),
        from: examSimulationsProvider,
        name: r'examSimulationsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$examSimulationsHash,
        dependencies: ExamSimulationsFamily._dependencies,
        allTransitiveDependencies:
            ExamSimulationsFamily._allTransitiveDependencies,
        goalId: goalId,
      );

  ExamSimulationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.goalId,
  }) : super.internal();

  final String goalId;

  @override
  Override overrideWith(
    FutureOr<List<ExamSimulation>> Function(ExamSimulationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExamSimulationsProvider._internal(
        (ref) => create(ref as ExamSimulationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        goalId: goalId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ExamSimulation>> createElement() {
    return _ExamSimulationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExamSimulationsProvider && other.goalId == goalId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, goalId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExamSimulationsRef on AutoDisposeFutureProviderRef<List<ExamSimulation>> {
  /// The parameter `goalId` of this provider.
  String get goalId;
}

class _ExamSimulationsProviderElement
    extends AutoDisposeFutureProviderElement<List<ExamSimulation>>
    with ExamSimulationsRef {
  _ExamSimulationsProviderElement(super.provider);

  @override
  String get goalId => (origin as ExamSimulationsProvider).goalId;
}

String _$goalMilestonesHash() => r'df2b5572a86fd6c9ab60b5392a7eebbe23e54df8';

/// Hitos alcanzados de una meta. No está en la lista de providers pedida
/// explícitamente, pero la sección de "Hitos logrados" de la pantalla de
/// Metas no puede construirse sin él.
///
/// Copied from [goalMilestones].
@ProviderFor(goalMilestones)
const goalMilestonesProvider = GoalMilestonesFamily();

/// Hitos alcanzados de una meta. No está en la lista de providers pedida
/// explícitamente, pero la sección de "Hitos logrados" de la pantalla de
/// Metas no puede construirse sin él.
///
/// Copied from [goalMilestones].
class GoalMilestonesFamily extends Family<AsyncValue<List<Milestone>>> {
  /// Hitos alcanzados de una meta. No está en la lista de providers pedida
  /// explícitamente, pero la sección de "Hitos logrados" de la pantalla de
  /// Metas no puede construirse sin él.
  ///
  /// Copied from [goalMilestones].
  const GoalMilestonesFamily();

  /// Hitos alcanzados de una meta. No está en la lista de providers pedida
  /// explícitamente, pero la sección de "Hitos logrados" de la pantalla de
  /// Metas no puede construirse sin él.
  ///
  /// Copied from [goalMilestones].
  GoalMilestonesProvider call(String goalId) {
    return GoalMilestonesProvider(goalId);
  }

  @override
  GoalMilestonesProvider getProviderOverride(
    covariant GoalMilestonesProvider provider,
  ) {
    return call(provider.goalId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'goalMilestonesProvider';
}

/// Hitos alcanzados de una meta. No está en la lista de providers pedida
/// explícitamente, pero la sección de "Hitos logrados" de la pantalla de
/// Metas no puede construirse sin él.
///
/// Copied from [goalMilestones].
class GoalMilestonesProvider
    extends AutoDisposeFutureProvider<List<Milestone>> {
  /// Hitos alcanzados de una meta. No está en la lista de providers pedida
  /// explícitamente, pero la sección de "Hitos logrados" de la pantalla de
  /// Metas no puede construirse sin él.
  ///
  /// Copied from [goalMilestones].
  GoalMilestonesProvider(String goalId)
    : this._internal(
        (ref) => goalMilestones(ref as GoalMilestonesRef, goalId),
        from: goalMilestonesProvider,
        name: r'goalMilestonesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$goalMilestonesHash,
        dependencies: GoalMilestonesFamily._dependencies,
        allTransitiveDependencies:
            GoalMilestonesFamily._allTransitiveDependencies,
        goalId: goalId,
      );

  GoalMilestonesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.goalId,
  }) : super.internal();

  final String goalId;

  @override
  Override overrideWith(
    FutureOr<List<Milestone>> Function(GoalMilestonesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GoalMilestonesProvider._internal(
        (ref) => create(ref as GoalMilestonesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        goalId: goalId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Milestone>> createElement() {
    return _GoalMilestonesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalMilestonesProvider && other.goalId == goalId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, goalId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GoalMilestonesRef on AutoDisposeFutureProviderRef<List<Milestone>> {
  /// The parameter `goalId` of this provider.
  String get goalId;
}

class _GoalMilestonesProviderElement
    extends AutoDisposeFutureProviderElement<List<Milestone>>
    with GoalMilestonesRef {
  _GoalMilestonesProviderElement(super.provider);

  @override
  String get goalId => (origin as GoalMilestonesProvider).goalId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
