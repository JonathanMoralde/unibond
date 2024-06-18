import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventsData {
  final DateTime eventDate;
  final List<IndivEvents> events;

  EventsData({required this.eventDate, required this.events});
}

class IndivEvents {
  final String eventDocId;
  final String eventName;
  final DateTime eventDate;
  final String description;
  final String eventTime;
  final String groupName;
  final String location;
  final int color;

  IndivEvents(
      {required this.description,
      required this.eventDate,
      required this.eventDocId,
      required this.eventName,
      required this.eventTime,
      required this.groupName,
      required this.location,
      required this.color});
}
