enum RepositoryRuntimeMode {
  localOnly,
  firebaseLegacy,
  vpsLocalFirst,
  migrationComparison;

  static const environmentKey = 'REPOSITORY_RUNTIME_MODE';

  static RepositoryRuntimeMode fromEnvironment({
    String value = const String.fromEnvironment(
      environmentKey,
      defaultValue: 'localOnly',
    ),
  }) {
    switch (value.trim()) {
      case 'localOnly':
      case 'local':
      case '':
        return RepositoryRuntimeMode.localOnly;
      case 'vpsLocalFirst':
      case 'vps':
        return RepositoryRuntimeMode.vpsLocalFirst;
      case 'migrationComparison':
      case 'comparison':
        return RepositoryRuntimeMode.migrationComparison;
      case 'firebase':
      case 'firebaseLegacy':
        return RepositoryRuntimeMode.firebaseLegacy;
      default:
        throw UnsupportedError('Unknown repository runtime mode: $value');
    }
  }

  bool get usesFirebasePrimary => this == RepositoryRuntimeMode.firebaseLegacy;
  bool get allowsUnauthenticatedCoreApp => this == RepositoryRuntimeMode.localOnly;
}
