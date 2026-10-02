// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mentorContextHash() => r'e2d0cc86b3e41c4fc3ff027c99a0bf000fc55dbe';

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

/// Arma el [MentorContext] con datos reales de la meta activa para el
/// Mentor IA (usado tanto en el análisis proactivo como en el chat).
///
/// Copied from [mentorContext].
@ProviderFor(mentorContext)
const mentorContextProvider = MentorContextFamily();

/// Arma el [MentorContext] con datos reales de la meta activa para el
/// Mentor IA (usado tanto en el análisis proactivo como en el chat).
///
/// Copied from [mentorContext].
class MentorContextFamily extends Family<AsyncValue<MentorContext>> {
  /// Arma el [MentorContext] con datos reales de la meta activa para el
  /// Mentor IA (usado tanto en el análisis proactivo como en el chat).
  ///
  /// Copied from [mentorContext].
  const MentorContextFamily();

  /// Arma el [MentorContext] con datos reales de la meta activa para el
  /// Mentor IA (usado tanto en el análisis proactivo como en el chat).
  ///
  /// Copied from [mentorContext].
  MentorContextProvider call(String goalId) {
    return MentorContextProvider(goalId);
  }

  @override
  MentorContextProvider getProviderOverride(
    covariant MentorContextProvider provider,
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
  String? get name => r'mentorContextProvider';
}

/// Arma el [MentorContext] con datos reales de la meta activa para el
/// Mentor IA (usado tanto en el análisis proactivo como en el chat).
///
/// Copied from [mentorContext].
class MentorContextProvider extends AutoDisposeFutureProvider<MentorContext> {
  /// Arma el [MentorContext] con datos reales de la meta activa para el
  /// Mentor IA (usado tanto en el análisis proactivo como en el chat).
  ///
  /// Copied from [mentorContext].
  MentorContextProvider(String goalId)
    : this._internal(
        (ref) => mentorContext(ref as MentorContextRef, goalId),
        from: mentorContextProvider,
        name: r'mentorContextProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mentorContextHash,
        dependencies: MentorContextFamily._dependencies,
        allTransitiveDependencies:
            MentorContextFamily._allTransitiveDependencies,
        goalId: goalId,
      );

  MentorContextProvider._internal(
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
    FutureOr<MentorContext> Function(MentorContextRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MentorContextProvider._internal(
        (ref) => create(ref as MentorContextRef),
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
  AutoDisposeFutureProviderElement<MentorContext> createElement() {
    return _MentorContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MentorContextProvider && other.goalId == goalId;
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
mixin MentorContextRef on AutoDisposeFutureProviderRef<MentorContext> {
  /// The parameter `goalId` of this provider.
  String get goalId;
}

class _MentorContextProviderElement
    extends AutoDisposeFutureProviderElement<MentorContext>
    with MentorContextRef {
  _MentorContextProviderElement(super.provider);

  @override
  String get goalId => (origin as MentorContextProvider).goalId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
