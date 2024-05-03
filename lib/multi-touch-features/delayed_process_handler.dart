import 'dart:async';

/// This class handles a [delayedProcess] with a given [waitDuration]
class DelayedProcessHandler {
  Timer? _waitingTimer;
  // final Duration _defaultDuration = const Duration(seconds: 10);

  /// This holds the process which should be executed after the provided delay
  Function delayedProcess;

  /// This value is used as a waiting duration, after this duration the process
  /// will be executed.
  Duration waitDuration;

  ///Public Constructor
  DelayedProcessHandler(
      {required this.delayedProcess, required this.waitDuration});

  /// This method will start the waiting process
  void startWaiting() {
    // to cancel previous waiting task assigned to this handler
    stopWaiting();

    _waitingTimer = Timer(waitDuration, () {
      delayedProcess();
    });
  }

  /// This method will stop the waiting process
  void stopWaiting() {
    _waitingTimer!.cancel();
    _waitingTimer = null;
  }
}
