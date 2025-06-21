import 'package:flutter/foundation.dart';

enum EventType {
  changedCategoryId,
  changedGroupId,
  changedItemId,
  exitSettings,
  serverFirstFetchStarts,
  serverFirstFetchEnds,
  checkPlanStatus,
}

class AppEvent {
  final EventType type;
  final dynamic value;

  AppEvent({
    required this.type,
    this.value,
  });

  @override
  String toString() => 'AppEvent(type: $type,value: $value)';
}

/// A singleton class that provides an event stream using ValueNotifier
class EventStream {
  // Private constructor
  EventStream._();

  // Singleton instance
  static final EventStream _instance = EventStream._();

  // Factory constructor to return the singleton instance
  factory EventStream() => _instance;

  // ValueNotifier to hold and notify about event data
  final ValueNotifier<AppEvent?> _eventNotifier = ValueNotifier(null);

  // Method to publish a new event
  void publish(AppEvent event) {
    _eventNotifier.value = event;
  }

  // Getter for the notifier
  ValueNotifier<AppEvent?> get notifier => _eventNotifier;
}
