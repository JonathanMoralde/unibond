import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/EventsData.dart';
import 'package:unibond/pages/Events/EventDetails.dart';
import 'package:unibond/provider/EventsModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

class EventCard extends StatefulWidget {
  final EventsData event;
  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  void initState() {
    super.initState();
    eventViews();
  }

  Future<void> eventViews() async {
    try {
      final profileModel = Provider.of<ProfileModel>(context, listen: false);

      for (final indivEvent in widget.event.events) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(indivEvent.eventDocId)
            .update({
          'views': FieldValue.arrayUnion([profileModel.userDetails['uid']])
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventsModel, ProfileModel>(
        builder: (context, eventsModel, profileModel, child) {
      return Expanded(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.black),
                ),
              ),
              padding: EdgeInsets.only(left: 16),
              child: Column(
                children: List.generate(
                  widget.event.events.length,
                  (eventIndex) {
                    final indivEvent = widget.event.events[eventIndex];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            try {
                              final result = await FirebaseFirestore.instance
                                  .collection('groups')
                                  .where('group_name',
                                      isEqualTo: indivEvent.groupName)
                                  .get();

                              if (result.docs.isNotEmpty) {
                                final data = result.docs.first.data();

                                print('this executed');

                                if ((data['admin'] as List<dynamic>).contains(
                                        profileModel.userDetails['uid']) ||
                                    profileModel.userDetails['role'] ==
                                        'admin') {
                                  print('admin');
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          EventDetails(
                                        eventData: indivEvent,
                                        isAdmin: true,
                                      ),
                                    ),
                                  );
                                } else {
                                  print('not admin');
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          EventDetails(
                                        eventData: indivEvent,
                                        isAdmin: false,
                                      ),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Color(indivEvent.color),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${indivEvent.eventName} (${indivEvent.eventTime})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.chevron_right)
                              ],
                            ),
                          ),
                        ),
                        if ((eventsModel.eventsList.indexOf(widget.event) !=
                                eventsModel.eventsList.length - 1) ||
                            (widget.event.events.indexOf(indivEvent) !=
                                widget.event.events.length - 1))
                          const SizedBox(height: 20)
                      ],
                    );
                  },
                ),
              ),
            ),
            // DOT
            Positioned(
              top: 10, // Adjusted position from top
              left: -2, // Adjusted position from left
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                height: 5,
                width: 5,
              ),
            ),
          ],
        ),
      );
    });
  }
}
