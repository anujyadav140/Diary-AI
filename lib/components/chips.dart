import 'package:flutter/material.dart';

class TagChips extends StatelessWidget {
  const TagChips({super.key, required this.tags});
  final List<dynamic> tags;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tags.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              elevation: 0.8,
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              label: Text(
                tags[index],
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 30,
                    color: Colors.white),
              ),
              backgroundColor: Colors.black,
              shadowColor: Colors.black,
            ),
          );
        }),
      ),
    );
  }
}
