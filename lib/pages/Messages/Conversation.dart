import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Conversation extends StatefulWidget {
  const Conversation({super.key});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final chatController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CHAT DISPLAY
          Expanded(
            child: ListView.builder(
              reverse: true,
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                bool isCurrentUser = true;
                // bool isCurrentUser = msg[index].senderId ==
                //     FirebaseAuth.instance.currentUser!.uid;

                // ===================== Time Display =====================
                DateTime timeReceived = Timestamp.now().toDate();
                // DateTime timeReceived = msg[index].timestamp.toDate();
                DateTime now = DateTime.now();

                DateTime dateToday = DateTime(now.year, now.month, now.day);
                DateTime dateReceived = DateTime(
                    timeReceived.year, timeReceived.month, timeReceived.day);

                bool isSameDate = dateToday.isAtSameMomentAs(dateReceived);

                String formattedDateTime = (isSameDate)
                    ? DateFormat('hh:mm a').format(timeReceived)
                    : (timeReceived.isAfter(
                        now.subtract(const Duration(days: 6)),
                      ))
                        ? DateFormat('EEE \'at\' hh:mm a').format(timeReceived)
                        : (timeReceived.isAfter(
                            DateTime(now.year - 1, now.month, now.day),
                          ))
                            ? DateFormat('MMM d \'at\' hh:mm a')
                                .format(timeReceived)
                            : DateFormat('MM/dd/yy \'at\' hh:mm a')
                                .format(timeReceived);
                // ========================================================

                return ListTile(
                  title: Container(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * 0.80,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Color(0xffFF8C36)
                                  : Color(0xff6ECDF7),
                              borderRadius: BorderRadius.only(
                                  topLeft: !isCurrentUser
                                      ? Radius.circular(0)
                                      : Radius.circular(32),
                                  topRight: isCurrentUser
                                      ? Radius.circular(0)
                                      : Radius.circular(32),
                                  bottomLeft: Radius.circular(32),
                                  bottomRight: Radius.circular(32)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Text(
                              // msg[index].messageText,
                              'test',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(formattedDateTime,
                            style: GoogleFonts.dmSans(fontSize: 11))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // INPUTS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: StyledTextFormField(
                    controller: chatController,
                    hintText: 'Type something',
                    obscureText: false,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}
