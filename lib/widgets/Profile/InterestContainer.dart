import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/EditProfileModel.dart';
import 'package:unibond/widgets/Profile/InterestButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Interestcontainer extends StatefulWidget {
  final String title;
  final List<String> options;
  final bool isDisplayOnly;
  final Color? headerColor;

  const Interestcontainer(
      {super.key,
      required this.title,
      required this.options,
      required this.isDisplayOnly,
      this.headerColor});

  @override
  State<Interestcontainer> createState() => _InteresttcntainerState();
}

class _InteresttcntainerState extends State<Interestcontainer> {
  List<List<String>> _chunkInterests(
      List<String> interests, int maxChunkLength) {
    List<List<String>> chunks = [];
    List<String> currentChunk = [];
    int currentLength = 0;

    for (var interest in interests) {
      if (currentLength + interest.length > maxChunkLength) {
        chunks.add(currentChunk);
        currentChunk = [];
        currentLength = 0;
      }
      currentChunk.add(interest);
      currentLength += interest.length;
    }
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }
    return chunks;
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileModel>(builder: (context, value, child) {
      List<List<String>> chunks = _chunkInterests(widget.options, 74);

      return Container(
        height: 245,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.20), // Shadow color with opacity
              spreadRadius: 0, // Spread radius
              blurRadius: 3, // Blur radius
              offset: Offset(0, 5), // Offset in x and y directions
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: widget.headerColor ?? const Color(0xffFF6E00),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              child: Text(
                '${widget.title} Interests',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  viewportFraction: 1,
                  height: 180,
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  onPageChanged: (index, _) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: chunks.map((chunk) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 16),
                        child: Wrap(
                          runSpacing: 10,
                          spacing: 5,
                          children: [
                            for (final interest in chunk)
                              InterestButton(
                                isAdd: false,
                                btnName: interest,
                                onTap: widget.isDisplayOnly
                                    ? null
                                    : () {
                                        print('clicked $interest');
                                        final editProfileProvider =
                                            context.read<EditProfileModel>();

                                        setState(() {
                                          editProfileProvider
                                              .addInterest(interest);
                                        });
                                      },
                              ),
                            if (!widget.isDisplayOnly && chunk == chunks.last)
                              InterestButton(
                                btnName: 'Add New Interest',
                                onTap: () {
                                  _showAddInterestDialog(context);
                                },
                                isAdd: !widget.isDisplayOnly,
                              )
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            if (chunks.asMap().entries.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: chunks.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index ? Colors.blue : Colors.grey,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _showAddInterestDialog(BuildContext context) async {
    final TextEditingController _interestController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color:
                  const Color(0xffFAF2F2), // Change the background color here
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Interest',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  StyledTextFormField(
                      controller: _interestController,
                      hintText: 'Enter new interest',
                      obscureText: false),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final newInterest = _interestController.text.trim();
                          if (newInterest.isNotEmpty) {
                            final editProfileProvider =
                                context.read<EditProfileModel>();
                            setState(() {
                              editProfileProvider.addNewOptions(newInterest);
                              editProfileProvider.addInterest(newInterest);
                              editProfileProvider.setOptions.add(
                                  newInterest); // Add to the list of options
                            });
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
