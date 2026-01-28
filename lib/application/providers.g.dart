// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dataSeederHash() => r'a1da3fa97d3e50762311bee5a3a63a3c24c5b96b';

/// See also [dataSeeder].
@ProviderFor(dataSeeder)
final dataSeederProvider = AutoDisposeProvider<DataSeeder>.internal(
  dataSeeder,
  name: r'dataSeederProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dataSeederHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DataSeederRef = AutoDisposeProviderRef<DataSeeder>;
String _$examRepositoryHash() => r'7ee0a12c7d9a2ef241bafe49abc70ea0321315d0';

/// See also [examRepository].
@ProviderFor(examRepository)
final examRepositoryProvider = AutoDisposeProvider<IExamRepository>.internal(
  examRepository,
  name: r'examRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$examRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExamRepositoryRef = AutoDisposeProviderRef<IExamRepository>;
String _$notificationServiceHash() =>
    r'f097a76685a5945a5d3b4b64fdab7bc722b4a3fd';

/// See also [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<LocalNotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationServiceRef = ProviderRef<LocalNotificationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
