import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unibond/model/EventsData.dart';

class EventsModel extends ChangeNotifier {
  bool _isCalendar = false;
  bool get isCalendar => _isCalendar;

  List<EventsData> _eventsList = [];
  List<EventsData> get eventsList => _eventsList;

  void toggleCalendar() {
    _isCalendar = !_isCalendar;
    notifyListeners();
  }

  List<IndivEvents> eventLoader(DateTime day) {
    if (eventsList.isNotEmpty) {
      final result = eventsList.where((eventDay) {
        return DateTime.utc(
                eventDay.eventDate.year,
                eventDay.eventDate.month,
                eventDay.eventDate.day,
                eventDay.eventDate.hour,
                eventDay.eventDate.minute)
            .isAtSameMomentAs(day);
      });

      return result.isNotEmpty ? result.first.events : [];
    }

    return [];
  }

  Future<void> fetchEvents(DateTime selectedMonth) async {
    DateTime startOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime endOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 1)
            .subtract(Duration(days: 1));

    try {
      final result = await FirebaseFirestore.instance
          .collection('events')
          .where('event_date', isGreaterThanOrEqualTo: startOfMonth)
          .where('event_date', isLessThanOrEqualTo: endOfMonth)
          .get();

      // Create a map to group events by their event_date
      Map<DateTime, List<IndivEvents>> groupedEvents = {};

      for (var doc in result.docs) {
        var data = doc.data();
        DateTime eventDate = (data['event_date'] as Timestamp).toDate();
        IndivEvents event = IndivEvents(
          eventDocId: doc.id,
          eventName: data['event_name'],
          eventDate: eventDate,
          description: data['description'],
          eventTime: data['event_time'],
          groupName: data['group_name'],
          location: data['location'],
          color: data['color'],
        );

        // Group events by date
        if (groupedEvents.containsKey(eventDate)) {
          groupedEvents[eventDate]!.add(event);
        } else {
          groupedEvents[eventDate] = [event];
        }
      }

      // Convert the grouped events map to a list of EventsData
      _eventsList = groupedEvents.entries.map((entry) {
        return EventsData(eventDate: entry.key, events: entry.value);
      }).toList();

      // Notify listeners of the data change
      notifyListeners();
    } catch (e) {
      print("error fetching events $e");
    }
  }
}
