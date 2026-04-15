enum AppErrorCode {
  connectionTimeout('network.connectionTimeout'),
  receiveTimeout('network.receiveTimeout'),
  networkConnectivity('network.connectivity'),
  sslCertificate('network.sslCertificate'),
  invalidCredentials('auth.invalidCredentials'),
  userNotAuthorized('auth.userNotAuthorized'),
  authenticationFailed('auth.authenticationFailed'),
  serverError('server.error'),
  connectionFailed('connection.failed'),
  downloadCancelled('download.cancelled'),
  downloadFileMissingOrInvalid('download.fileMissingOrInvalid'),
  downloadFileMissing('download.fileMissing'),
  downloadFileEmpty('download.fileEmpty'),
  downloadFileSizeMismatch('download.fileSizeMismatch'),
  unknown('unknown');

  const AppErrorCode(this.storageValue);

  final String storageValue;

  static AppErrorCode? fromStorageValue(String? value) {
    if (value == null) return null;
    for (final code in values) {
      if (code.storageValue == value) {
        return code;
      }
    }
    return null;
  }
}

class AppError {
  const AppError(this.code, {this.message});

  final AppErrorCode code;
  final String? message;

  String get storageValue => code.storageValue;

  static AppError? fromStorageValue(String? value) {
    final code = AppErrorCode.fromStorageValue(value);
    return code == null ? null : AppError(code);
  }

  @override
  String toString() {
    final detail = message;
    if (detail == null || detail.isEmpty) {
      return code.storageValue;
    }
    return '${code.storageValue}: $detail';
  }
}
