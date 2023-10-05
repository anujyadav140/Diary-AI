import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiarifyDay extends StatefulWidget {
  const DiarifyDay({Key? key}) : super(key: key);

  @override
  State<DiarifyDay> createState() => _DiarifyDayState();
}

class _DiarifyDayState extends State<DiarifyDay> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Text(
              'Diary Entries',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 100.0, // Adjust the height of the chip row as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: daysInMonth,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final date = DateTime(now.year, now.month, day);
                  final dayName = DateFormat('E').format(date);
                  final isCurrentDay = day == now.day;
                  final isFutureDay =
                      date.isAfter(now); // Check if it's a future date
                  final isSelected = date == selectedDate;

                  return GestureDetector(
                    onTap: () {
                      if (!isSelected) {
                        if (isFutureDay) {
                          // Show a Snackbar for future dates
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("That day hasn't come yet..."),
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
                                : (isFutureDay ? Colors.grey : Colors.white),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                width: isCurrentDay ? 2.0 : 1.0,
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
            ),
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
