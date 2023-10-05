import 'package:diarify/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';

class DiarifyDay extends StatefulWidget {
  const DiarifyDay({super.key, required this.isSelectDatesClicked});
  final bool isSelectDatesClicked; // Add this

  @override
  State<DiarifyDay> createState() => _DiarifyDayState();
}

class _DiarifyDayState extends State<DiarifyDay> {
  DateTime? selectedDate;
  bool isSelected = false;
  bool scrollDone = false;
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  final ItemScrollController controller =
      ItemScrollController(); // Declare it as nullable

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> scrollToCurrentDay() async {
    if (widget.isSelectDatesClicked && !scrollDone) {
      final now = DateTime.now();
      final index = now.day - 3;
      Future.delayed(const Duration(milliseconds: 1)).then((value) => controller
          .scrollTo(index: index, duration: const Duration(milliseconds: 1))
          .then((value) => scrollDone = true));
    }
    if (!widget.isSelectDatesClicked) {
      scrollDone = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    scrollToCurrentDay();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Text(
              'Diary Entries',
              style: TextStyle(color: Colors.white),
            ),
            widget.isSelectDatesClicked
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.12,
                    child: ScrollablePositionedList.builder(
                      itemScrollController: controller,
                      scrollOffsetController: scrollOffsetController,
                      itemPositionsListener: itemPositionsListener,
                      scrollOffsetListener: scrollOffsetListener,
                      scrollDirection: Axis.horizontal,
                      itemCount: daysInMonth,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final date = DateTime(now.year, now.month, day);
                        final dayName = DateFormat('E').format(date);
                        final isCurrentDay = day == now.day;
                        final isFutureDay =
                            date.isAfter(now); // Check if it's a future date
                        isSelected = date == selectedDate;

                        return GestureDetector(
                          onTap: () {
                            if (!isSelected) {
                              if (isFutureDay) {
                                // Show a Snackbar for future dates
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("That day hasn't come yet..."),
                                    duration: Duration(milliseconds: 500),
                                  ),
                                );
                              } else {
                                setState(() {
                                  selectedDate = date;
                                });
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: MediaQuery.of(context).size.height * 0.1,
                              decoration: BoxDecoration(
                                  color: isCurrentDay || date == selectedDate
                                      ? Colors.black
                                      : (isFutureDay
                                          ? Colors.grey
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      width: isCurrentDay ? 3.5 : 1.0,
                                      color: Colors.white)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    day.toString(),
                                    style: TextStyle(
                                      color: isSelected || isCurrentDay
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      color: isSelected || isCurrentDay
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(),
            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate!),
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
