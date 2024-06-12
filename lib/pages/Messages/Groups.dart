import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/CreateGroupChat.dart';
import 'package:unibond/provider/GroupModel.dart';
import 'package:unibond/widgets/Group/GroupCard.dart';

class Groups extends StatefulWidget {
  const Groups({super.key});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  final scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Provider.of<GroupModel>(context, listen: false).fetchGroups();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // Fetch more data when the user scrolls to the bottom
        Provider.of<GroupModel>(context, listen: false)
            .fetchGroups(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GroupModel>(builder: (context, value, child) {
        return SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.73,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount:
                      value.groupList.length + 1 + (value.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // CREATE GROUP CARD
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const CreateGroupChat(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 32),
                          decoration: BoxDecoration(
                              color: Color(0xffD9D9D9),
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 50,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                'Create New',
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 27,
                              )
                            ],
                          ),
                        ),
                      );
                    } else if (index <= value.groupList.length) {
                      return GroupCard(
                        groupData: value.groupList[index - 1],
                      );
                    } else if (value.hasMoreData) {
                      // Show a loading indicator if there is more data to fetch
                      return Center(child: CircularProgressIndicator());
                    } else {
                      // No more data to fetch
                      return SizedBox.shrink();
                    }
                  },
                ),
              )
            ],
          ),
        ));
      }),
    );
  }
}
