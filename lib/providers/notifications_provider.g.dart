// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flutterLocalNotificationsHash() =>
    r'165fec726a30695d49886452a578b260f905f87d';

/// Instancia compartida del plugin de notificaciones locales.
///
/// Copied from [flutterLocalNotifications].
@ProviderFor(flutterLocalNotifications)
final flutterLocalNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>.internal(
      flutterLocalNotifications,
      name: r'flutterLocalNotificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$flutterLocalNotificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FlutterLocalNotificationsRef =
    ProviderRef<FlutterLocalNotificationsPlugin>;
String _$notificationsServiceHash() =>
    r'888eb378d959b6c0c096697dd2862f0c07ba09ff';

/// Servicio de alto nivel para notificaciones y alarmas.
///
/// Copied from [notificationsService].
@ProviderFor(notificationsService)
final notificationsServiceProvider = Provider<NotificationsService>.internal(
  notificationsService,
  name: r'notificationsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsServiceRef = ProviderRef<NotificationsService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
