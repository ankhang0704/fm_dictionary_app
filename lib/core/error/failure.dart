abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A local storage error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class AudioProcessingFailure extends Failure {
  const AudioProcessingFailure([super.message = 'Failed to process audio or access microphone.']);
}
