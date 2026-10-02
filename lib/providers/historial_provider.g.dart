// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historial_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historialDataHash() => r'465b6b098c5f073de581355634d984c9c1f89925';

/// Datos globales de historial: una fila por cada semana desde la primera
/// vez que se marcó una actividad, más las actividades más cumplida/fallida.
///
/// Copied from [historialData].
@ProviderFor(historialData)
final historialDataProvider = AutoDisposeFutureProvider<HistorialData>.internal(
  historialData,
  name: r'historialDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historialDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistorialDataRef = AutoDisposeFutureProviderRef<HistorialData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
