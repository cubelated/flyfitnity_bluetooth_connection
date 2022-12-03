import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:collection/collection.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'constant/colors.dart';
import 'constant/custom_text.dart';

class DeviceScreen3 extends StatefulWidget {
  final Function disableCallback;
  const DeviceScreen3(
      {Key? key, required this.device, required this.disableCallback})
      : super(key: key);

  final BluetoothDevice device;

  @override
  State<DeviceScreen3> createState() => _DeviceScreen3State();
}

class _DeviceScreen3State extends State<DeviceScreen3> {
  int cycle = 0;
  Guid serviceId = Guid('00000000-6a70-11ed-a1eb-0242ac120002');
  Guid charId = Guid('00000001-6a70-11ed-a1eb-0242ac120002');

  Duration duration = const Duration();
  Timer? timer;
  int startingValue = 0;

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = widget.device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await widget.device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
  }

  bool isStarting = false;
  bool isRunning = false;
  bool isLoading = true;
  int exerciseTime = 0;
  int restTime = 0;
  double caloriesBurned = 0;
  int lastCycle = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  void addTime() {
    const addSecond = 1;
    setState(() {
      final seconds = duration.inSeconds + addSecond;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void resetTimer() {
    setState(() {
      duration = const Duration();
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isStarting = false;
      duration = const Duration();
    });
  }

  void load() async {
    await widget.device.discoverServices();
    rssiStream();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return CustomText(
      text: '$hours:$minutes:$seconds',
      size: 55,
    );
  }

  Future<bool?> showWarning(BuildContext context) async {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: dark,
            title: const CustomText(text: 'Device will be disconnected.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const CustomText(
                    text: 'No',
                    color: yellow,
                  )),
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context, true);
                    widget.disableCallback();
                    await widget.device.disconnect();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: yellow),
                  child: const CustomText(
                    text: 'Okay',
                    color: dark,
                  )),
            ],
          );
        });
  }

  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? const Center(
            child: CircularProgressIndicator(
              color: yellow,
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              final shouldPop = await showWarning(context);
              return shouldPop ?? false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(right: 50),
                  child: const CustomText(
                    text: '運動中',
                    weight: FontWeight.bold,
                    size: 20,
                  ),
                ),
                elevation: 0,
                backgroundColor: dark,
              ),
              body: Container(
                  color: dark,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CustomText(
                                text: '運動裝置:',
                                size: 20,
                                weight: FontWeight.bold,
                              ),
                              CustomText(text: widget.device.name),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: buildTime(),
                      ),
                      Expanded(
                        child: StreamBuilder<List<BluetoothService>>(
                          stream: widget.device.services,
                          initialData: const [],
                          builder: (c, snapshot) {
                            if (snapshot.hasData) {
                              BluetoothService? service = snapshot.data!
                                  .firstWhereOrNull(
                                      (element) => element.uuid == serviceId);

                              if (service != null) {
                                BluetoothCharacteristic? characteristic =
                                    service.characteristics.firstWhereOrNull(
                                        (element) => element.uuid == charId);

                                if (characteristic != null) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            isStarting == false
                                                ? SizedBox(
                                                    width: 90,
                                                    height: 90,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: green,
                                                        shape:
                                                            const CircleBorder(),
                                                      ),
                                                      onPressed: () async {
                                                        isStarting = true;
                                                        if (isRunning == true) {
                                                          restTime = restTime +
                                                              duration
                                                                  .inSeconds;
                                                          resetTimer();
                                                        } else {
                                                          startTimer();
                                                          isRunning = true;
                                                        }

                                                        await characteristic
                                                            .setNotifyValue(
                                                                !characteristic
                                                                    .isNotifying);
                                                        characteristic.value
                                                            .listen((value) {
                                                          setState(() {
                                                            cycle = lastCycle +
                                                                int.parse(
                                                                    utf8.decode(
                                                                        value));
                                                            caloriesBurned =
                                                                cycle * 0.067;
                                                          });
                                                        });
                                                      },
                                                      child: const CustomText(
                                                          text: '運動'),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width: 90,
                                                    height: 90,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          shape:
                                                              const CircleBorder(),
                                                        ),
                                                        onPressed: () async {
                                                          exerciseTime =
                                                              exerciseTime +
                                                                  duration
                                                                      .inSeconds;
                                                          await characteristic
                                                              .setNotifyValue(
                                                                  !characteristic
                                                                      .isNotifying);
                                                          resetTimer();
                                                          setState(() {
                                                            isStarting = false;

                                                            lastCycle = cycle;
                                                          });
                                                        },
                                                        child: const CustomText(
                                                            text: '休息')),
                                                  ),
                                            SizedBox(
                                              width: 90,
                                              height: 90,
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    shape: const CircleBorder(),
                                                  ),
                                                  onPressed: () async {
                                                    if (isStarting == true) {
                                                      exerciseTime =
                                                          exerciseTime +
                                                              duration
                                                                  .inSeconds;
                                                    } else {
                                                      restTime = restTime +
                                                          duration.inSeconds;
                                                    }

                                                    stopTimer();

                                                    if (isStarting == true) {
                                                      await characteristic
                                                          .setNotifyValue(
                                                              !characteristic
                                                                  .isNotifying);
                                                    }

                                                    var value =
                                                        await characteristic
                                                            .read();
                                                    setState(() {
                                                      isStarting = false;
                                                      isRunning = false;
                                                      cycle = int.parse(
                                                          utf8.decode(value));
                                                      caloriesBurned =
                                                          cycle * 0.067;
                                                    });
                                                  },
                                                  child: const CustomText(
                                                      text: '停止')),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 20, 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 140,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  color: darkLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 8, 8, 4),
                                                    child: Row(
                                                      children: const [
                                                        CustomText(
                                                            text: '運動時間'),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Icon(
                                                          Icons.timelapse,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 4, 8, 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        CustomText(
                                                          text:
                                                              '$exerciseTime 秒',
                                                          color: yellow,
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              width: 140,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  color: darkLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 8, 8, 4),
                                                    child: Row(
                                                      children: const [
                                                        CustomText(
                                                            text: '休息時間'),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Icon(
                                                          Icons.more_time,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 4, 8, 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        CustomText(
                                                          text: '$restTime 秒',
                                                          color: yellow,
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 20, 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 140,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  color: darkLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 8, 8, 4),
                                                    child: Row(
                                                      children: const [
                                                        CustomText(
                                                            text: '卡路里消耗'),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Icon(
                                                          Icons.fireplace,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 4, 8, 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        CustomText(
                                                          text:
                                                              '${caloriesBurned.toStringAsFixed(1)} 卡',
                                                          color: yellow,
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              width: 140,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  color: darkLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 8, 8, 4),
                                                    child: Row(
                                                      children: const [
                                                        CustomText(
                                                            text: '飛輪圈數'),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Icon(
                                                          Icons.circle_outlined,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 4, 8, 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        CustomText(
                                                          text: '$cycle 圈',
                                                          color: yellow,
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              width: 290,
                                              height: 50,
                                              child: ElevatedButton(
                                                  onPressed: isRunning == true
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            exerciseTime = 0;
                                                            restTime = 0;
                                                            caloriesBurned = 0;
                                                            cycle = 0;
                                                            lastCycle = 0;
                                                          });
                                                        },
                                                  style: ElevatedButton.styleFrom(
                                                      disabledBackgroundColor:
                                                          Colors.grey,
                                                      backgroundColor: yellow),
                                                  child: const CustomText(
                                                    text: '完成訓練',
                                                    color: dark,
                                                  )))
                                        ],
                                      )
                                    ],
                                  );
                                  // Padding(
                                  //   padding: const EdgeInsets.all(30.0),
                                  //   child: Column(
                                  //     mainAxisSize: MainAxisSize.min,
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       const SizedBox(
                                  //         height: 30,
                                  //       ),
                                  //       CustomText(
                                  //         text: cycle.toString(),
                                  //         size: 80,
                                  //         weight: FontWeight.bold,
                                  //       ),
                                  //       Row(
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.center,
                                  //         children: [
                                  //           isStarting == true
                                  //               ? ElevatedButton(
                                  //                   onPressed: () async {
                                  //                     isStarting = false;
                                  //                     await characteristic
                                  //                         .setNotifyValue(
                                  //                             !characteristic
                                  //                                 .isNotifying);
                                  //                     var value =
                                  //                         await characteristic
                                  //                             .read();
                                  //                     setState(() {
                                  //                       cycle = int.parse(
                                  //                           utf8.decode(value));
                                  //                     });
                                  //                   },
                                  //                   style: ElevatedButton
                                  //                       .styleFrom(
                                  //                           backgroundColor:
                                  //                               yellow),
                                  //                   child: const Padding(
                                  //                     padding:
                                  //                         EdgeInsets.all(8.0),
                                  //                     child: CustomText(
                                  //                       text: 'Stop',
                                  //                       size: 20,
                                  //                       color: dark,
                                  //                       weight: FontWeight.bold,
                                  //                     ),
                                  //                   ))
                                  //               : ElevatedButton(
                                  //                   onPressed: () async {
                                  //                     isStarting = true;
                                  //                     await characteristic
                                  //                         .setNotifyValue(
                                  //                             !characteristic
                                  //                                 .isNotifying);
                                  //                     characteristic.value
                                  //                         .listen((value) {
                                  //                       setState(() {
                                  //                         cycle = int.parse(utf8
                                  //                             .decode(value));
                                  //                       });
                                  //                     });
                                  //                   },
                                  //                   style: ElevatedButton
                                  //                       .styleFrom(
                                  //                           backgroundColor:
                                  //                               green),
                                  //                   child: const Padding(
                                  //                     padding:
                                  //                         EdgeInsets.all(8.0),
                                  //                     child: CustomText(
                                  //                       text: 'Start',
                                  //                       size: 20,
                                  //                       weight: FontWeight.bold,
                                  //                     ),
                                  //                   )),
                                  //         ],
                                  //       )
                                  //     ],
                                  //   ),
                                  // );
                                } else {
                                  return const Center(
                                    child: LinearProgressIndicator(
                                      color: yellow,
                                    ),
                                  );
                                }
                              } else {
                                return const Center(
                                    child: LinearProgressIndicator(
                                  color: yellow,
                                ));
                              }
                            } else {
                              return const CustomText(text: 'Error occured.');
                            }
                          },
                        ),
                      ),
                    ],
                  )),
            ));
  }
}
