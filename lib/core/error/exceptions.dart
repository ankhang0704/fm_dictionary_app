class ServerException implements Exception {
  final String? message;
  const ServerException([this.message]);

  @override
  String toString() => 'ServerException: ${message ?? 'Unknown error'}';
}

class CacheException implements Exception {
  final String? message;
  const CacheException([this.message]);

  @override
  String toString() => 'CacheException: ${message ?? 'Unknown error'}';
}

class NetworkException implements Exception {
  final String? message;
  const NetworkException([this.message]);

  @override
  String toString() => 'NetworkException: ${message ?? 'Unknown error'}';
}

class AudioProcessingException implements Exception {
  final String? message;
  const AudioProcessingException([this.message]);

  @override
  String toString() => 'AudioProcessingException: ${message ?? 'Unknown error'}';
}