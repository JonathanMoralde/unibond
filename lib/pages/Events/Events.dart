import 'package:flutter/material.dart';

class Events extends StatelessWidget {
  const Events({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DATE
                SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.20,
                  child: Column(
                    children: [
                      Text('01'),
                      Text('Mon'),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                // EVENT CARD
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.black),
                          ),
                        ),
                        // width: MediaQuery.of(context).size.width * 0.75,
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          children: [
                            // INDIV EVENT
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('IT Meet and Greet (9:00 AM)'),
                                  Icon(Icons.chevron_right)
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            // INDIV EVENT
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('IT Meet and Greet (9:00 AM)'),
                                  Icon(Icons.chevron_right)
                                ],
                              ),
                            ),
                          ],
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
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
