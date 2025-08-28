import 'dart:async';

enum CustomMessages { scrollHomeToTop }

class EventManager {
  static final EventManager _instance = EventManager._internal();

  factory EventManager() {
    return _instance;
  }

  EventManager._internal();

  final StreamController<CustommazadiEvent> _eventController =
      StreamController<CustommazadiEvent>.broadcast();

  Stream<CustommazadiEvent> get eventStream => _eventController.stream;

  void sendEvent(CustommazadiEvent event) {
    _eventController.sink.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

class CustommazadiEvent {
  final CustomMessages type;
  final dynamic message;

  CustommazadiEvent(
    this.type,
    this.message,
  );
}
