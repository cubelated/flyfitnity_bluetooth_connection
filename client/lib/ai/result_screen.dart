import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_excel/excel.dart';
import '../constant/colors.dart';
import '../constant/custom_text.dart';

class ResultScreen extends StatefulWidget {
  final String gender;
  final bool regular;
  final int age;
  final double weight;
  final double height;
  const ResultScreen(
      {super.key,
      required this.gender,
      required this.regular,
      required this.age,
      required this.weight,
      required this.height});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class TreadmillClass {
  final String? power;
  final String? time;
  const TreadmillClass({required this.power, required this.time});
}

class FitClass {
  final String? power;
  final String? time;
  const FitClass({required this.power, required this.time});
}

class SwingClass {
  final String? power;
  final String? time;
  const SwingClass({required this.power, required this.time});
}

class BikeClass {
  final String? power;
  final String? time;
  const BikeClass({required this.power, required this.time});
}

class _ResultScreenState extends State<ResultScreen> {
  bool isLoading = true;
  List<String> xlsxData = [];
  List<TreadmillClass> treadmillData = [];
  List<SwingClass> swingData = [];
  List<FitClass> fitData = [];
  List<BikeClass> bikeData = [];
  double bmi = 0;
  String input = '';
  int? resultIndex;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  double bmiCalculate(double weight, double height) {
    double bmi = weight / (height * height / 10000);
    return bmi;
  }

  void loadData() async {
    swingData.clear();
    fitData.clear();
    treadmillData.clear();
    xlsxData.clear();
    bikeData.clear();
    ByteData data = await rootBundle.load("assets/dataset.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);
    int index = 0;
    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        if (index >= 402) break;
        index++;
        if (row.first == null || row.first!.rowIndex == 0) {
        } else {
          xlsxData.add(row.first!.value.toString());
        }

        if (row.elementAt(2) == null) {
          treadmillData.add(const TreadmillClass(power: null, time: null));
        } else if (row.elementAt(2)!.rowIndex == 0 ||
            row.elementAt(2)!.rowIndex == 1) {
        } else {
          treadmillData.add(TreadmillClass(
              power: row.elementAt(2)!.value.toString(),
              time: row.elementAt(3)!.value.toString()));
        }
        if (row.elementAt(4) == null) {
          swingData.add(const SwingClass(power: null, time: null));
        } else if (row.elementAt(4)!.rowIndex == 0 ||
            row.elementAt(4)!.rowIndex == 1) {
        } else {
          swingData.add(SwingClass(
              power: row.elementAt(4)!.value.toString(),
              time: row.elementAt(5)!.value.toString()));
        }

        if (row.elementAt(6) == null) {
          fitData.add(const FitClass(power: null, time: null));
        } else if (row.elementAt(6) == null ||
            row.elementAt(6)!.rowIndex == 0 ||
            row.elementAt(6)!.rowIndex == 1) {
        } else {
          fitData.add(FitClass(
              power: row.elementAt(6)!.value.toString(),
              time: row.elementAt(7)!.value.toString()));
        }

        if (row.elementAt(8) == null) {
          bikeData.add(const BikeClass(power: null, time: null));
        } else if (row.elementAt(8) == null ||
            row.elementAt(8)!.rowIndex == 0 ||
            row.elementAt(8)!.rowIndex == 1) {
        } else {
          bikeData.add(BikeClass(
              power: row.elementAt(8)!.value.toString(),
              time: row.elementAt(9)!.value.toString()));
        }
      }
    }

    if (widget.regular == false) {
      input = '0';
    } else {
      input = '1';
    }

    input = '${input}0';

    if (widget.gender == 'Female') {
      input = '${input}0';
    } else {
      input = '${input}1';
    }

    if (widget.age >= 80) {
      input = '${input}7';
    } else if (widget.age >= 70) {
      input = '${input}6';
    } else if (widget.age >= 60) {
      input = '${input}5';
    } else if (widget.age >= 50) {
      input = '${input}4';
    } else if (widget.age >= 40) {
      input = '${input}3';
    } else if (widget.age >= 30) {
      input = '${input}2';
    } else if (widget.age >= 20) {
      input = '${input}1';
    } else {
      input = '${input}0';
    }

    bmi = bmiCalculate(widget.weight, widget.height);
    if (bmi < 18.5) {
      input = '${input}0';
    } else if (bmi < 24) {
      input = '${input}1';
    } else if (bmi < 27) {
      input = '${input}2';
    } else if (bmi < 30) {
      input = '${input}3';
    } else if (bmi < 35) {
      input = '${input}4';
    }

    resultIndex = xlsxData.indexOf(input);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
            color: yellow,
          ))
        : Scaffold(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const CustomText(
                    text: 'BMI Value',
                    size: 20,
                  ),
                  CustomText(
                    text: bmi.toStringAsFixed(1),
                    size: 40,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const CustomText(
                    text: 'What you need to do:',
                    size: 18,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      treadmillData[resultIndex!].power != null
                          ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                                children: [
                                  const CustomText(
                                    text: '跑步機',
                                    size: 16,
                                    weight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    text: 'Power: ${treadmillData[resultIndex!].power}',
                                    size: 14,
                                  ),
                                  CustomText(
                                    text: 'Time: ${treadmillData[resultIndex!].time} (min)',
                                    size: 14,
                                  ),
                                ],
                              ),
                          )
                          : Container(),
                      swingData[resultIndex!].power != null
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                children: [
                                  const CustomText(
                                    text: '橢圓機',
                                    size: 16,
                                      weight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    text: 'Power: ${swingData[resultIndex!].power}',
                                    size: 14,
                                  ),
                                  CustomText(
                                    text: 'Time: ${swingData[resultIndex!].time} (min)',
                                    size: 14,
                                  ),
                                ],
                              ),
                          )
                          : Container(),
                      fitData[resultIndex!].power != null
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                children: [
                                  const CustomText(
                                    text: '健身車',
                                    size: 16,
                                      weight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    text: 'Power: ${fitData[resultIndex!].power}',
                                    size: 14,
                                  ),
                                  CustomText(
                                    text: 'Time: ${fitData[resultIndex!].time} (min)',
                                    size: 14,
                                  ),
                                ],
                              ),
                          )
                          : Container(),
                      bikeData[resultIndex!].power != null
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                children: [
                                  const CustomText(
                                    text: '飛輪車',
                                    size: 16,
                                      weight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    text: 'Power: ${bikeData[resultIndex!].power}',
                                    size: 14,
                                  ),
                                  CustomText(
                                    text: 'Time: ${bikeData[resultIndex!].time} (min)',
                                    size: 14,
                                  ),
                                ],
                              ),
                          )
                          : Container()
                    ],
                  )

                  //DISPLAY DATA
                  // ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: xlsxData.length,
                  //     itemBuilder: (context, index) {
                  //       return ListTile(
                  //         title: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           children: [
                  //             CustomText(text: xlsxData[index].toString()),
                  //             CustomText(
                  //                 text: treadmillData[index].power.toString()),
                  //             CustomText(text: swingData[index].power.toString()),
                  //             CustomText(text: fitData[index].power.toString()),
                  //             CustomText(text: bikeData[index].power.toString()),
                  //           ],
                  //         ),
                  //       );
                  //     })
                ],
              ),
            ),
          );
  }
}
