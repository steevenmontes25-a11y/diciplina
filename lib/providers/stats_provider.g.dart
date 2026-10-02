// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarDaysHash() => r'77e06b05a298d30acc6e28f12226df810f8a8a57';

/// Los últimos 365 días (incluyendo hoy), ascendente por fecha, para el
/// calendario visual tipo GitHub.
///
/// Copied from [calendarDays].
@ProviderFor(calendarDays)
final calendarDaysProvider =
    AutoDisposeFutureProvider<List<CalendarDay>>.internal(
      calendarDays,
      name: r'calendarDaysProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calendarDaysHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarDaysRef = AutoDisposeFutureProviderRef<List<CalendarDay>>;
String _$currentYearStatsHash() => r'ba5285d5721770366a7556e69b1fce74cffad81c';

/// See also [currentYearStats].
@ProviderFor(currentYearStats)
final currentYearStatsProvider = AutoDisposeFutureProvider<YearStats>.internal(
  currentYearStats,
  name: r'currentYearStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentYearStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentYearStatsRef = AutoDisposeFutureProviderRef<YearStats>;
String _$categoryTimeLast30DaysHash() =>
    r'b63a0fb93b2a82a8ff745a789e5c4ccf3db0e693';

/// Tiempo por categoría de los últimos 30 días.
///
/// Copied from [categoryTimeLast30Days].
@ProviderFor(categoryTimeLast30Days)
final categoryTimeLast30DaysProvider =
    AutoDisposeFutureProvider<Map<ActivityCategory, Duration>>.internal(
      categoryTimeLast30Days,
      name: r'categoryTimeLast30DaysProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryTimeLast30DaysHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryTimeLast30DaysRef =
    AutoDisposeFutureProviderRef<Map<ActivityCategory, Duration>>;
String _$categoryTimeThisYearHash() =>
    r'ce51f61e5b8bde747b6c33a57154014cdf8418ec';

/// Tiempo por categoría del año calendario actual (para el Wrapped).
///
/// Copied from [categoryTimeThisYear].
@ProviderFor(categoryTimeThisYear)
final categoryTimeThisYearProvider =
    AutoDisposeFutureProvider<Map<ActivityCategory, Duration>>.internal(
      categoryTimeThisYear,
      name: r'categoryTimeThisYearProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryTimeThisYearHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryTimeThisYearRef =
    AutoDisposeFutureProviderRef<Map<ActivityCategory, Duration>>;
String _$disciplineIndexLast90DaysHash() =>
    r'c216c707d45effc44db8d7a1a1e93176f52dfd20';

/// Evolución del ID en los últimos 90 días, con los logros desbloqueados en
/// ese rango marcados en su fecha correspondiente.
///
/// Copied from [disciplineIndexLast90Days].
@ProviderFor(disciplineIndexLast90Days)
final disciplineIndexLast90DaysProvider =
    AutoDisposeFutureProvider<List<IndexPoint>>.internal(
      disciplineIndexLast90Days,
      name: r'disciplineIndexLast90DaysProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$disciplineIndexLast90DaysHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DisciplineIndexLast90DaysRef =
    AutoDisposeFutureProviderRef<List<IndexPoint>>;
String _$weekdayAveragesHash() => r'654ae119982e3e3cff82c55efbeef85659a7b7cf';

/// Porcentaje promedio de disciplina por día de la semana, considerando
/// todo el historial de días cerrados.
///
/// Copied from [weekdayAverages].
@ProviderFor(weekdayAverages)
final weekdayAveragesProvider =
    AutoDisposeFutureProvider<Map<DayOfWeek, double>>.internal(
      weekdayAverages,
      name: r'weekdayAveragesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weekdayAveragesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeekdayAveragesRef =
    AutoDisposeFutureProviderRef<Map<DayOfWeek, double>>;
String _$topActivitiesHash() => r'6ea700bcd61eaf288b37346ca3f0269966376a4e';

/// See also [topActivities].
@ProviderFor(topActivities)
final topActivitiesProvider = AutoDisposeFutureProvider<TopActivities>.internal(
  topActivities,
  name: r'topActivitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topActivitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TopActivitiesRef = AutoDisposeFutureProviderRef<TopActivities>;
String _$allAchievementsHash() => r'23d9b71650d2c4a278c18539c96fa3644d008687';

/// See also [allAchievements].
@ProviderFor(allAchievements)
final allAchievementsProvider =
    AutoDisposeFutureProvider<List<Achievement>>.internal(
      allAchievements,
      name: r'allAchievementsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allAchievementsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllAchievementsRef = AutoDisposeFutureProviderRef<List<Achievement>>;
String _$nextAchievementProgressHash() =>
    r'31173aa4968b539f7341362892071ceae9e1e43e';

/// See also [nextAchievementProgress].
@ProviderFor(nextAchievementProgress)
final nextAchievementProgressProvider =
    AutoDisposeFutureProvider<NextAchievementProgress?>.internal(
      nextAchievementProgress,
      name: r'nextAchievementProgressProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nextAchievementProgressHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextAchievementProgressRef =
    AutoDisposeFutureProviderRef<NextAchievementProgress?>;
String _$bestStreakRangeThisYearHash() =>
    r'1807f2b77495602ed0f78d6b0df3bfca1dee7fd8';

/// See also [bestStreakRangeThisYear].
@ProviderFor(bestStreakRangeThisYear)
final bestStreakRangeThisYearProvider =
    AutoDisposeFutureProvider<BestStreakRange>.internal(
      bestStreakRangeThisYear,
      name: r'bestStreakRangeThisYearProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bestStreakRangeThisYearHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BestStreakRangeThisYearRef =
    AutoDisposeFutureProviderRef<BestStreakRange>;
String _$wrappedDataHash() => r'b339158fbc692637d610970eb5a0a34d18788e8a';

/// See also [wrappedData].
@ProviderFor(wrappedData)
final wrappedDataProvider = AutoDisposeFutureProvider<WrappedData?>.internal(
  wrappedData,
  name: r'wrappedDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wrappedDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WrappedDataRef = AutoDisposeFutureProviderRef<WrappedData?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
