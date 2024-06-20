import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/EventsData.dart';
import 'package:unibond/provider/CreateEventModel.dart';
import 'package:unibond/provider/EventsModel.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedDateTime;
  TimeOfDay? selectedTime;
  String? selectedGroup;

  final List<Color> colors = [
    Colors.grey.shade300,
    Colors.red.shade300,
    Colors.green.shade300,
    Colors.blue.shade200,
    Colors.yellow.shade300,
    Colors.orange.shade300,
    Colors.purple.shade300,
    Colors.pink.shade300,
    Colors.brown.shade300,
    Colors.white
  ];

  int currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<CreateEventModel>(context, listen: false).fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              if (nameController.text.isNotEmpty &&
                  locationController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  selectedDateTime != null &&
                  selectedTime != null &&
                  selectedGroup != null) {
                Provider.of<CreateEventModel>(context, listen: false)
                    .insertEvent(
                        nameController.text,
                        selectedDateTime!,
                        formatTimeOfDay(selectedTime!),
                        locationController.text,
                        selectedGroup!,
                        descriptionController.text,
                        colors[currentColorIndex].value)
                    .then((docId) {
                  Provider.of<CreateEventModel>(context, listen: false)
                      .newEventNotification(IndivEvents(
                          description: descriptionController.text,
                          eventDate: selectedDateTime!,
                          eventDocId: docId,
                          eventName: nameController.text,
                          eventTime: formatTimeOfDay(selectedTime!),
                          groupName: selectedGroup!,
                          location: locationController.text,
                          color: colors[currentColorIndex].value));
                  Fluttertoast.showToast(msg: 'Successfully created the event');

                  Navigator.pop(context);
                  Provider.of<EventsModel>(context, listen: false)
                      .fetchEvents(DateTime.now());
                });
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                "SAVE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Consumer<CreateEventModel>(
          builder: (context, createEventModel, child) {
        return SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                setState(() {
                  // Change to the next color in the list
                  currentColorIndex = (currentColorIndex + 1) % colors.length;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: colors[currentColorIndex],
                    borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    // EVENT NAME
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      width: MediaQuery.sizeOf(context).width * 1,
                      child: TextFormField(
                        textAlign: TextAlign.left,

                        // style: TextStyle(fontSize: 12),
                        controller: nameController,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Enter event name',

                          // hintStyle: TextStyle(fontSize: 12),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff00B0FF)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter event name';
                          }
                          return null;
                        },
                      ),
                    ),

                    // DATE
                    const Text(
                      'Date',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 28, top: 16, bottom: 16),
                      child: InkWell(
                          onTap: () async {
                            final DateTime? dateTime = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(3000),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary:
                                          Color(0xffFC852B), // <-- SEE HERE
                                      onPrimary:
                                          Color(0xff252525), // <-- SEE HERE
                                      onSurface:
                                          Color(0xff252525), // <-- SEE HERE
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                            0xff252525), // button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (dateTime != null) {
                              setState(() {
                                selectedDateTime = dateTime;
                              });
                            }
                          },
                          child: Text(
                            selectedDateTime != null
                                ? DateFormat('MMMM dd, yyyy').format(DateTime(
                                    selectedDateTime!.year,
                                    selectedDateTime!.month + 0,
                                    selectedDateTime!.day))
                                : 'Select date',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                          )),
                    ),

                    // TIME SELECT
                    const Text(
                      'Time',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 28, top: 16, bottom: 16),
                      child: InkWell(
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime;
                              });
                            }
                          },
                          child: Text(
                            selectedTime != null
                                ? formatTimeOfDay(selectedTime!)
                                : 'Select time',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                          )),
                    ),

                    // LOCATION
                    const Text(
                      "Location",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      width: MediaQuery.sizeOf(context).width * 1,
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        // style: TextStyle(fontSize: 12),
                        controller: locationController,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Enter location',
                          // hintStyle: TextStyle(fontSize: 12),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff00B0FF)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                    ),

                    // AUDIENCE/GROUP
                    const Text(
                      'Group',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: DropdownButton(
                        hint: Text('Select group'),
                        isExpanded: true,
                        value: selectedGroup,
                        items: createEventModel.groupOptions.isEmpty
                            ? const [
                                DropdownMenuItem(
                                    enabled: false,
                                    value: '',
                                    child: Text(
                                        'You have no groups or you are not an admin of a group'))
                              ]
                            : createEventModel.groupOptions,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGroup = newValue;
                          });
                        },
                        underline: const SizedBox(),
                      ),
                    ),

                    // DESCRIPTION
                    const Text(
                      'Description',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      width: MediaQuery.sizeOf(context).width * 1,
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        // style: TextStyle(fontSize: 12),
                        controller: descriptionController,
                        minLines: 1,
                        maxLines: 10,
                        maxLength: 300,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Add a brief description',
                          // hintStyle: TextStyle(fontSize: 12),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff00B0FF)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Change color',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      }),
    );
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    // Convert TimeOfDay to DateTime
    final now = DateTime.now();
    // final time = DateTime(
    //   now.year,
    //   now.month,
    //   now.day,
    //   timeOfDay.hour,
    //   timeOfDay.minute,
    // );

    // // Format the time using DateFormat
    // final formattedTime = TimeOfDay.fromDateTime(time).format(context);

    // Format the time to 12-hour format with AM/PM
    final format = DateFormat.jm(); // 12-hour format with AM/PM
    return format.format(DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute));
  }
}
