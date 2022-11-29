import 'package:flutter/material.dart';
import 'package:frt_bluetooth_client/ai/result_screen.dart';

import '../constant/colors.dart';
import '../constant/custom_text.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final GlobalKey _formKey = GlobalKey();

  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  String? gender;
  bool? regular;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(right: 50),
          child: const CustomText(
            text: 'Prediction',
            weight: FontWeight.bold,
            size: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: dark,
      ),
      body: Container(
        color: dark,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Theme(
              data: Theme.of(context)
                  .copyWith(unselectedWidgetColor: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(text: "Exercise Regularly"),
                  Row(
                    children: [
                      Radio(
                          value: true,
                          groupValue: regular,
                          activeColor: yellow,
                          onChanged: (value) {
                            setState(() {
                              regular = value;
                            });
                          }),
                      const CustomText(text: 'Yes'),
                      const SizedBox(
                        width: 10,
                      ),
                      Radio(
                          activeColor: yellow,
                          value: false,
                          groupValue: regular,
                          onChanged: (value) {
                            setState(() {
                              regular = value;
                            });
                          }),
                      const CustomText(text: 'No'),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const CustomText(text: "Gender"),
                  Row(
                    children: [
                      Radio(
                          value: "Male",
                          groupValue: gender,
                          activeColor: yellow,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          }),
                      const CustomText(text: 'Male'),
                      const SizedBox(
                        width: 5,
                      ),
                      Radio(
                          value: "Female",
                          groupValue: gender,
                          activeColor: yellow,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          }),
                      const CustomText(text: 'Female'),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: yellow)),
                        label: CustomText(
                          text: 'Age',
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: yellow)),
                        label: CustomText(
                          text: 'Weight',
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: yellow)),
                        label: CustomText(
                          text: 'Height',
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const CustomText(
                          text: 'Reset',
                          color: Colors.white,
                          weight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () => submit(),
                        style:
                            ElevatedButton.styleFrom(backgroundColor: yellow),
                        child: const CustomText(
                          text: 'Predict',
                          color: dark,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    if (gender == null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: dark,
                title: const CustomText(
                  text: 'Failed',
                ),
                content: const CustomText(
                  text: 'Please pick your gender.',
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const CustomText(
                        text: 'Okay',
                      ))
                ],
              ));
      return;
    }
    if (regular == null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: dark,
                title: const CustomText(
                  text: 'Failed',
                ),
                content: const CustomText(
                  text: 'Please pick your option on regular exercise.',
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const CustomText(
                        text: 'Okay',
                      ))
                ],
              ));
      return;
    }
    if (ageController.text == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: dark,
                title: const CustomText(
                  text: 'Error',
                ),
                content: const CustomText(
                  text: 'Please enter your age.',
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const CustomText(
                        text: 'Okay',
                      ))
                ],
              ));
      return;
    }
    if (weightController.text == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: dark,
                title: const CustomText(
                  text: 'Error',
                ),
                content: const CustomText(
                  text: 'Please enter your weight.',
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const CustomText(
                        text: 'Okay',
                      ))
                ],
              ));
      return;
    }
    if (heightController.text == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: dark,
                title: const CustomText(
                  text: 'Error',
                ),
                content: const CustomText(
                  text: 'Please enter your height.',
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const CustomText(
                        text: 'Okay',
                      ))
                ],
              ));
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ResultScreen(
        gender: gender.toString(),
        age: int.parse(ageController.text),
        regular: regular!,
        weight: double.parse(weightController.text),
        height: double.parse(heightController.text),
      );
    }));
  }
}
