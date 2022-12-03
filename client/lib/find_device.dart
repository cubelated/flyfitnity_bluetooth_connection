import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:frt_bluetooth_client/ai/input_screen.dart';
import 'package:frt_bluetooth_client/constant/colors.dart';
import 'package:frt_bluetooth_client/constant/custom_text.dart';
import 'package:frt_bluetooth_client/device_screen.dart';

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  bool isConnecting = false;
  String isConnectingText = 'Connect';

  void disable() {
    setState(() {
      isConnecting = false;
      isConnectingText = 'Connect';
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: CustomText(
          text: 'Find Devices',
          weight: FontWeight.bold,
          size: 20,
        )),
        backgroundColor: dark,
        elevation: 0,
      ),
      body: Container(
        color: dark,
        child: StreamBuilder<List<ScanResult>>(
            stream: flutterBlue.scanResults,
            initialData: const [],
            builder: (c, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  var r = snapshot.data![index];
                  if (r.device.name != '') {
                    return ListTile(
                      title: CustomText(
                        text: r.device.name,
                        weight: FontWeight.bold,
                      ),
                      subtitle: CustomText(
                        text: r.device.id.toString(),
                        size: 14,
                      ),
                      leading: const Icon(
                        Icons.devices,
                        color: yellow,
                        size: 34,
                      ),
                      trailing: ElevatedButton.icon(
                          onPressed: isConnecting
                              ? null
                              : () async {
                                  setState(() {
                                    isConnecting = true;
                                    isConnectingText = 'Connecting';
                                  });

                                  await r.device.connect();

                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return DeviceScreen3(
                                        device: r.device,
                                        disableCallback: disable);
                                  }));
                                },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: yellow,
                              disabledBackgroundColor: Colors.grey),
                          icon: const Icon(
                            Icons.bluetooth_connected,
                            color: dark,
                            size: 20,
                          ),
                          label: CustomText(
                            text: isConnectingText,
                            color: dark,
                            size: 14,
                          )),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            }),
      ),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          heroTag: 'btn1',
          backgroundColor: green,
          onPressed: () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const InputScreen();
          })),
          child: const Icon(Icons.smart_button),
        ),
        const SizedBox(
          width: 10,
        ),
        StreamBuilder<bool>(
          stream: FlutterBluePlus.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton(
                heroTag: 'btn2',
                onPressed: () => FlutterBluePlus.instance.stopScan(),
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop),
              );
            } else {
              return FloatingActionButton(
                  heroTag: 'btn2',
                  backgroundColor: yellow,
                  child: const Icon(Icons.search),
                  onPressed: () => FlutterBluePlus.instance
                      .startScan(timeout: const Duration(seconds: 5)));
            }
          },
        ),
      ]),
    );
  }
}
