import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    await widget.device.discoverServices();
    rssiStream();
    setState(() {
      isLoading = false;
    });
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
                    text: 'Exercising',
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
                    children: <Widget>[
                      StreamBuilder<BluetoothDeviceState>(
                        stream: widget.device.state,
                        initialData: BluetoothDeviceState.connecting,
                        builder: (c, snapshot) => Center(
                          child: CustomText(
                              text:
                                  'Device is ${snapshot.data.toString().split('.')[1]}.'),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<List<BluetoothService>>(
                          stream: widget.device.services,
                          initialData: const [],
                          builder: (c, snapshot) {
                            if (snapshot.hasData) {
                              BluetoothService service = snapshot.data!
                                  .where((element) => element.uuid == serviceId)
                                  .first;
                              BluetoothCharacteristic characteristic = service
                                  .characteristics
                                  .where((element) => element.uuid == charId)
                                  .first;

                              return Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    CustomText(
                                      text: cycle.toString(),
                                      size: 80,
                                      weight: FontWeight.bold,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        isStarting == true
                                            ? ElevatedButton(
                                                onPressed: () async {
                                                  isStarting = false;
                                                  await characteristic
                                                      .setNotifyValue(
                                                          !characteristic
                                                              .isNotifying);
                                                  var value =
                                                      await characteristic
                                                          .read();
                                                  setState(() {
                                                    cycle = int.parse(
                                                        utf8.decode(value));
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: yellow),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: CustomText(
                                                    text: 'Stop',
                                                    size: 20,
                                                    color: dark,
                                                    weight: FontWeight.bold,
                                                  ),
                                                ))
                                            : ElevatedButton(
                                                onPressed: () async {
                                                  isStarting = true;
                                                  await characteristic
                                                      .setNotifyValue(
                                                          !characteristic
                                                              .isNotifying);
                                                  characteristic.value
                                                      .listen((value) {
                                                    setState(() {
                                                      cycle = int.parse(
                                                          utf8.decode(value));
                                                    });
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: green),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: CustomText(
                                                    text: 'Start',
                                                    size: 20,
                                                    weight: FontWeight.bold,
                                                  ),
                                                )),
                                      ],
                                    )
                                  ],
                                ),
                              );
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
