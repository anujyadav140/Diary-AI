import 'dart:math';

import 'package:flutter/material.dart';
import 'package:action_slider/action_slider.dart';

class SlideToAct extends StatefulWidget {
  const SlideToAct({super.key});

  @override
  State<SlideToAct> createState() => _SlideToActState();
}

class _SlideToActState extends State<SlideToAct> {
  @override
  Widget build(BuildContext context) {
    return ActionSlider.dual(
      backgroundBorderRadius: BorderRadius.circular(10.0),
      foregroundBorderRadius: BorderRadius.circular(10.0),
      width: 300.0,
      backgroundColor: Colors.black,
      toggleColor: Colors.white,
      startChild: const Text('Restart', style: TextStyle(color: Colors.white)),
      endChild: const Text('Continue', style: TextStyle(color: Colors.white)),
      successIcon: const Icon(Icons.check, color: Colors.black, size: 28.0),
      icon: Padding(
        padding: const EdgeInsets.only(right: 2.0),
        child: Transform.rotate(
            angle: 0.5 * pi,
            child: const Icon(Icons.unfold_more_rounded,
                color: Colors.black, size: 28.0)),
      ),
      startAction: (controller) async {
        controller.loading(); //starts loading animation
        await Future.delayed(const Duration(seconds: 3));
        controller.success(); //starts success animation
        await Future.delayed(const Duration(seconds: 1));
        controller.reset(); //resets the slider
      },
      endAction: (controller) async {
        controller.loading(); //starts loading animation
        await Future.delayed(const Duration(seconds: 3));
        controller.success(); //starts success animation
        await Future.delayed(const Duration(seconds: 1));
        controller.reset(); //resets the slider
      },
    );
  }
}
