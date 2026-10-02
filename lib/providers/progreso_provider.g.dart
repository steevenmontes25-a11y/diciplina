// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progreso_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryTimeInvestedHash() =>
    r'1cd9579966b34fe73c7a19e07276c516aa656181';

/// Tiempo total invertido por categoría de actividad, calculado a partir de
/// cuántas veces se marcó cada actividad como hecha (en todo el historial)
/// multiplicado por su duración.
///
/// Copied from [categoryTimeInvested].
@ProviderFor(categoryTimeInvested)
final categoryTimeInvestedProvider =
    AutoDisposeFutureProvider<Map<ActivityCategory, Duration>>.internal(
      categoryTimeInvested,
      name: r'categoryTimeInvestedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryTimeInvestedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryTimeInvestedRef =
    AutoDisposeFutureProviderRef<Map<ActivityCategory, Duration>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
