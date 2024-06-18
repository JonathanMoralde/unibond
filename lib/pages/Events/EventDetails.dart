import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unibond/model/EventsData.dart';

class EventDetails extends StatelessWidget {
  final IndivEvents eventData;
  const EventDetails({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Color(eventData.color),
                  borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Event',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  // EVENT NAME
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 28, top: 16, bottom: 16),
                    child: Text(eventData.eventName),
                  ),

                  // DATE
                  const Text(
                    'Date',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 28, top: 16, bottom: 16),
                    child: Text(DateFormat('MMMM dd, yyyy').format(DateTime(
                        eventData.eventDate.year,
                        eventData.eventDate.month + 0,
                        eventData.eventDate.day))),
                  ),

                  // TIME SELECT
                  const Text(
                    'Time',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 28, top: 16, bottom: 16),
                    child: Text(eventData.eventTime),
                  ),

                  // LOCATION
                  const Text(
                    "Location",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 28, top: 16, bottom: 16),
                    child: Text(eventData.location),
                  ),

                  // AUDIENCE/GROUP
                  const Text(
                    'Group',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 28, top: 16, bottom: 16),
                    child: Text(eventData.groupName),
                  ),

                  // DESCRIPTION
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 28, top: 16, bottom: 16),
                    child: Text(eventData.description),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
