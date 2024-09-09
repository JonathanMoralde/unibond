import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:unibond/model/EventsData.dart';
import 'package:unibond/pages/Events/CreateEvent.dart';
import 'package:unibond/pages/Events/EventCard.dart';
import 'package:unibond/pages/Events/EventDetails.dart';
import 'package:unibond/pages/Events/utils.dart';
import 'package:unibond/provider/EventsModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledButton.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  DateTime selectedMonth = DateTime.now();

  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  late final ValueNotifier<List<IndivEvents>> _selectedEvents;

  @override
  void initState() {
    super.initState();

    Provider.of<EventsModel>(context, listen: false).fetchEvents(selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<EventsModel, ProfileModel>(
          builder: (context, eventsModel, profileModel, child) {
        return SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // DATE & BTNS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (BuildContext context) =>
                      //         TableEventsExample()));
                      eventsModel.toggleCalendar();
                    },
                    child: Icon(
                      eventsModel.isCalendar
                          ? Icons.event
                          : Icons.format_align_left,
                      color: eventsModel.isCalendar
                          ? Color(0xffFF6814)
                          : Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          // previous month
                          _updateMonth(DateTime(
                              selectedMonth.year, selectedMonth.month - 1));
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Icon(Icons.chevron_left),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                        DateFormat('MMM yyyy').format(selectedMonth),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      InkWell(
                        onTap: () {
                          // next month
                          _updateMonth(DateTime(
                              selectedMonth.year, selectedMonth.month + 1));
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => CreateEvent(),
                        ),
                      );
                    },
                    child: Icon(Icons.add),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              if (!eventsModel.isCalendar)
                // for (final event in eventsModel.eventsList)
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       // DATE
                //       SizedBox(
                //         width: MediaQuery.of(context).size.width * 0.10,
                //         child: Column(
                //           // crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               event.eventDate.day.toString(),
                //               style: TextStyle(
                //                   fontSize: 18, fontWeight: FontWeight.w900),
                //             ),
                //             Text(
                //               DateFormat('EEE').format(event.eventDate),
                //             ),
                //           ],
                //         ),
                //       ),

                //       const SizedBox(
                //         width: 16,
                //       ),

                //       // EVENT CARD
                //       Expanded(
                //         child: Stack(
                //           clipBehavior: Clip.none,
                //           children: [
                //             Container(
                //               decoration: BoxDecoration(
                //                 border: Border(
                //                   left: BorderSide(color: Colors.black),
                //                 ),
                //               ),
                //               // width: MediaQuery.of(context).size.width * 0.75,
                //               padding: EdgeInsets.only(left: 16),
                //               child: Column(
                //                 children: [
                //                   for (final indivEvent in event.events)
                //                     // INDIV EVENT
                //                     Column(
                //                       children: [
                //                         InkWell(
                //                           onTap: () {
                //                             Navigator.of(context).push(
                //                               MaterialPageRoute(
                //                                 builder:
                //                                     (BuildContext context) =>
                //                                         EventDetails(
                //                                             eventData:
                //                                                 indivEvent),
                //                               ),
                //                             );
                //                           },
                //                           borderRadius:
                //                               BorderRadius.circular(8),
                //                           child: Container(
                //                             padding: EdgeInsets.all(8),
                //                             decoration: BoxDecoration(
                //                                 border: Border.all(
                //                                     color: Colors.black),
                //                                 color: Color(indivEvent.color),
                //                                 borderRadius:
                //                                     BorderRadius.circular(8)),
                //                             child: Row(
                //                               mainAxisAlignment:
                //                                   MainAxisAlignment
                //                                       .spaceBetween,
                //                               children: [
                //                                 Text(
                //                                     '${indivEvent.eventName} (${indivEvent.eventTime})'),
                //                                 Icon(Icons.chevron_right)
                //                               ],
                //                             ),
                //                           ),
                //                         ),
                //                         if ((eventsModel.eventsList
                //                                     .indexOf(event) !=
                //                                 eventsModel.eventsList.length -
                //                                     1) ||
                //                             (event.events.indexOf(indivEvent) !=
                //                                 event.events.length - 1))
                //                           const SizedBox(height: 20)
                //                       ],
                //                     ),
                //                 ],
                //               ),
                //             ),

                //             // DOT
                //             Positioned(
                //               top: 10, // Adjusted position from top
                //               left: -2, // Adjusted position from left
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                   color: Colors.black,
                //                   borderRadius: BorderRadius.circular(50),
                //                 ),
                //                 height: 5,
                //                 width: 5,
                //               ),
                //             ),
                //           ],
                //         ),
                //       )
                //     ],
                //   ),
                Expanded(
                  child: ListView.builder(
                    itemCount: eventsModel.eventsList.length,
                    itemBuilder: (context, index) {
                      final event = eventsModel.eventsList[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DATE
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.10,
                            child: Column(
                              children: [
                                Text(
                                  event.eventDate.day.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  DateFormat('EEE').format(event.eventDate),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // EVENT CARD
                          EventCard(event: event)
                        ],
                      );
                    },
                  ),
                ),

              if (eventsModel.isCalendar)
                TableCalendar<IndivEvents>(
                  headerVisible: false,
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: selectedMonth,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  rangeSelectionMode: _rangeSelectionMode,
                  eventLoader: eventsModel.eventLoader,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  calendarStyle: const CalendarStyle(
                      // Use `CalendarStyle` to customize the UI
                      outsideDaysVisible: false,
                      selectedDecoration: BoxDecoration(
                          color: Color(0xffFF6814), shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(
                          color: Color(0xff00B0FF), shape: BoxShape.circle),
                      todayDecoration: const BoxDecoration(
                          color: Color.fromARGB(255, 244, 168, 127),
                          shape: BoxShape.circle)),
                  onDaySelected: _onDaySelected,
                  // onRangeSelected: _onRangeSelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    selectedMonth = focusedDay;
                  },
                  calendarBuilders:
                      CalendarBuilders(markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      // Limit the number of markers to 4 and add a "+x" marker for additional events
                      int markerCount = events.length;
                      List<Widget> markers = events.take(3).map((event) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(event.color),
                              boxShadow: [
                                BoxShadow(color: Colors.black38, blurRadius: 1)
                              ]),
                          width: 8.0,
                          height: 8.0,
                        );
                      }).toList();

                      if (markerCount > 3) {
                        markers.add(
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            child: Text(
                              "+${markerCount - 3}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: markers,
                      );
                    }
                    return Container();
                  }),
                ),
              if (eventsModel.isCalendar)
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: _selectedDay != null
                        ? eventsModel.eventLoader(_selectedDay!).length
                        : [].length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          try {
                            final result = await FirebaseFirestore.instance
                                .collection('groups')
                                .where('group_name',
                                    isEqualTo: eventsModel
                                        .eventLoader(_selectedDay!)[index]
                                        .groupName)
                                .get();

                            if (result.docs.isNotEmpty) {
                              final data = result.docs.first.data();

                              if ((data['admin'] as List<dynamic>).contains(
                                      profileModel.userDetails['uid']) ||
                                  profileModel.userDetails['role'] == 'admin') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        EventDetails(
                                      eventData: eventsModel
                                          .eventLoader(_selectedDay!)[index],
                                      isAdmin: true,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        EventDetails(
                                      eventData: eventsModel
                                          .eventLoader(_selectedDay!)[index],
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
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          // decoration: BoxDecoration(
                          //   border: Border.all(),
                          //   borderRadius: BorderRadius.circular(12.0),
                          // ),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Color(eventsModel
                                  .eventLoader(_selectedDay!)[index]
                                  .color),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${eventsModel.eventLoader(_selectedDay!)[index].eventName} (${eventsModel.eventLoader(_selectedDay!)[index].eventTime})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.chevron_right)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ));
      }),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        selectedMonth = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      // _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _updateMonth(DateTime newMonth) {
    setState(() {
      selectedMonth = newMonth;
    });
    Provider.of<EventsModel>(context, listen: false).fetchEvents(newMonth);
  }

  Color getMarkerColor(List<IndivEvents> events) {
    if (events.isNotEmpty) {
      return Color(events.first.color);
    }
    return Colors.transparent;
  }
}
