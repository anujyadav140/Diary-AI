import 'package:diarify/pages/home.dart';
import 'package:diarify/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const CustomChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: selected ? Colors.black : null,
      selectedColor: Colors.black,
      selectedShadowColor: Colors.white,
      checkmarkColor: Colors.white,
    );
  }
}

class DiarifySettings extends StatefulWidget {
  const DiarifySettings({Key? key}) : super(key: key);

  @override
  State<DiarifySettings> createState() => _DiarifySettingsState();
}

class _DiarifySettingsState extends State<DiarifySettings> {
  String selectedWordLimit = ''; // Initialize with '300'
  String selectedStyle = ''; // Initialize with 'Casual'
  String selectedTry = ''; // Initialize with 'Be factual'
  String selectedEmotionTags = ''; // Initialize with 'Yes'
  String selectedInspirationalQuotes = ''; // Initialize with 'No'
  String additionalDirections = '';
  String hintDirections = '';
  @override
  void initState() {
    selectedWordLimit = context.read<AuthService>().settings.selectedWordLimit;
    selectedStyle = context.read<AuthService>().settings.selectedStyle;
    selectedTry = context.read<AuthService>().settings.selectedTry;
    selectedEmotionTags =
        context.read<AuthService>().settings.selectedEmotionTags;
    selectedInspirationalQuotes =
        context.read<AuthService>().settings.selectedInspirationalQuotes;
    additionalDirections =
        context.read<AuthService>().settings.additionalDirections;
    hintDirections =
        'Previous: ${context.read<AuthService>().settings.additionalDirections}';
    super.initState();
  }

  void handleChoiceSelected(String choice, String groupName) {
    setState(() {
      switch (groupName) {
        case 'WordLimit':
          selectedWordLimit = choice;
          break;
        case 'Style':
          selectedStyle = choice;
          break;
        case 'Try':
          selectedTry = choice;
          break;
        case 'EmotionTags':
          selectedEmotionTags = choice;
          break;
        case 'InspirationalQuotes':
          selectedInspirationalQuotes = choice;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: w * 0.05),
                    child: Text(
                      "Diary entry settings",
                      style: TextStyle(fontSize: w / 20),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return const DiarifyHome();
                          },
                        ));
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 30,
                        color: Colors.black,
                      ))
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: w * 0.05, top: h * 0.01),
                child: Text(
                  "Get tailored diary writing generations based on your preference",
                  style: TextStyle(
                    fontSize: w / 30,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                height: h * 0.01,
              ),
              Text(
                "Word limit:",
                style: TextStyle(
                  fontSize: w / 25,
                  color: Colors.black,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  CustomChoiceChip(
                    label: '100',
                    selected: selectedWordLimit == '100',
                    onSelected: (selected) {
                      handleChoiceSelected('100', 'WordLimit');
                    },
                  ),
                  CustomChoiceChip(
                    label: '300',
                    selected: selectedWordLimit == '300',
                    onSelected: (selected) {
                      handleChoiceSelected('300', 'WordLimit');
                    },
                  ),
                  CustomChoiceChip(
                    label: '500',
                    selected: selectedWordLimit == '500',
                    onSelected: (selected) {
                      handleChoiceSelected('500', 'WordLimit');
                    },
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.01,
              ),
              Text(
                "Style:",
                style: TextStyle(
                  fontSize: w / 25,
                  color: Colors.black,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  CustomChoiceChip(
                    label: 'Casual',
                    selected: selectedStyle == 'Casual',
                    onSelected: (selected) {
                      handleChoiceSelected('Casual', 'Style');
                    },
                  ),
                  CustomChoiceChip(
                    label: 'Formal',
                    selected: selectedStyle == 'Formal',
                    onSelected: (selected) {
                      handleChoiceSelected('Formal', 'Style');
                    },
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.01,
              ),
              Text(
                "Try to ...",
                style: TextStyle(
                  fontSize: w / 25,
                  color: Colors.black,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  CustomChoiceChip(
                    label: 'Be factual',
                    selected: selectedTry == 'Be factual',
                    onSelected: (selected) {
                      handleChoiceSelected('Be factual', 'Try');
                    },
                  ),
                  CustomChoiceChip(
                    label: 'Expand on it',
                    selected: selectedTry == 'Expand on it',
                    onSelected: (selected) {
                      handleChoiceSelected('Expand on it', 'Try');
                    },
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.01,
              ),
              Text(
                "Emotion tags required?",
                style: TextStyle(
                  fontSize: w / 25,
                  color: Colors.black,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  CustomChoiceChip(
                    label: 'Yes',
                    selected: selectedEmotionTags == 'Yes',
                    onSelected: (selected) {
                      handleChoiceSelected('Yes', 'EmotionTags');
                    },
                  ),
                  CustomChoiceChip(
                    label: 'No',
                    selected: selectedEmotionTags == 'No',
                    onSelected: (selected) {
                      handleChoiceSelected('No', 'EmotionTags');
                    },
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.01,
              ),
              Text(
                "Add inspirational quotes?",
                style: TextStyle(
                  fontSize: w / 25,
                  color: Colors.black,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  CustomChoiceChip(
                    label: 'Yes',
                    selected: selectedInspirationalQuotes == 'Yes',
                    onSelected: (selected) {
                      handleChoiceSelected('Yes', 'InspirationalQuotes');
                    },
                  ),
                  CustomChoiceChip(
                    label: 'No',
                    selected: selectedInspirationalQuotes == 'No',
                    onSelected: (selected) {
                      handleChoiceSelected('No', 'InspirationalQuotes');
                    },
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.01,
              ),
              Padding(
                padding: EdgeInsets.only(left: w * 0.05, right: w * 0.05),
                child: TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    focusColor: Colors.black,
                    hoverColor: Colors.black,
                    fillColor: Colors.black,
                    iconColor: Colors.black,
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Additional Directions or Comments',
                    hintText: hintDirections,
                    labelStyle: const TextStyle(
                      decorationColor: Colors.black,
                      color: Colors.black,
                    ),
                    hintStyle: const TextStyle(
                        decorationColor: Colors.black, color: Colors.black),
                    border: const UnderlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      additionalDirections = value;
                    });
                  },
                ),
              ),
              SizedBox(
                height: h * 0.01,
              ),
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () {
                  // Update the settings in the provider context
                  DiarySettingsModel newSettings = DiarySettingsModel()
                    ..selectedWordLimit = selectedWordLimit
                    ..selectedStyle = selectedStyle
                    ..selectedTry = selectedTry
                    ..selectedEmotionTags = selectedEmotionTags
                    ..selectedInspirationalQuotes = selectedInspirationalQuotes
                    ..additionalDirections = additionalDirections;

                  context.read<AuthService>().settings = newSettings;
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.save,
                  size: 30,
                  color: Colors.white,
                ),
                label: Text(
                  "Save settings",
                  style: TextStyle(fontSize: w / 25, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
