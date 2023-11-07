import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DiarifyImage extends StatefulWidget {
  const DiarifyImage({super.key, required this.link});
  final String link;
  @override
  State<DiarifyImage> createState() => _DiarifyImageState();
}

class _DiarifyImageState extends State<DiarifyImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width * 0.4,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.025,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.link.isEmpty
              ? const Text("Loading ...")
              : Image.network(
                  widget.link,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
        ],
      ),
    );
  }
}
