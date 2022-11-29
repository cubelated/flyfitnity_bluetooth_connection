import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen2 extends StatefulWidget {
  const DeviceScreen2({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<DeviceScreen2> createState() => _DeviceScreen2State();
}

class _DeviceScreen2State extends State<DeviceScreen2> {
  final Guid _CYCLE_CHARACTERISTIC_GUID =
      Guid('00000001-6a70-11ed-a1eb-0242ac120002');
  late final BluetoothService _bleService;
  late StreamSubscription<List<int>> _streamBleWeatherCharacteristic;

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ExpansionTile(
            title: Text(s.toString()),
            children: s.characteristics
                .map(
                  (c) => ExpansionTile(
                    title: Text(c.toString()),
                    // onExpansionChanged: (value) async {
                    //   var a = await c.read();
                    //   print(a);
                    // },
                    // onReadPressed: () => c.read(),
                    // onWritePressed: () async {
                    //   await c.write(_getRandomBytes(), withoutResponse: true);
                    //   await c.read();
                    // },
                    // onNotificationPressed: () async {
                    //   await c.setNotifyValue(!c.isNotifying);
                    //   await c.read();
                    // },
                    children: c.descriptors
                        .map(
                          (d) => ListTile(
                            title: Text(d.toString()),
                            // onReadPressed: () => d.read(),
                            // onWritePressed: () => d.write(_getRandomBytes()),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  // void _mapListenToUpdates() async {

  //   print('Characteristic: $characteristic' );
  //   await characteristic.setNotifyValue(true);

  //   _streamBleWeatherCharacteristic = characteristic.value.listen((value) {
  //     print('W: value received : $value');
  //     if (value == null || value.isEmpty) {
  //       print('W: value is empty');
  //       return;
  //     }

  //     var data = utf8.decode(value);
  //     print('W: Data decoded : $data');

  //     var dataReceived = data.split(',');
  //     print('W: Data received: $dataReceived');

  //     // var dataTemp = dataReceived[0];
  //     // var temperature = dataTemp.substring(2);
  //     // var dataWeather = dataReceived[1];
  //     // var weatherId = dataWeather.substring(2);
  //     // var weather = Weather(temperature, int.parse(weatherId));

  //     // var dataCity = dataReceived[2];
  //     // var cityId = dataCity.substring(2);
  //     // var city = City(int.parse(cityId));

  //     // var citiesData = CitiesData();
  //     // citiesData.cities.forEach((element) {
  //     //   if (element.containsValue(city.id)) {
  //     //     city.name = element['name'];
  //     //     city.icon = element['icon'];
  //     //   }
  //     // });

  //     // add(WeatherReceived(weather, city));
  //   });
  // }

  // void restartUpdates() async {
  //   final characteristic = _bleService.characteristics
  //       .firstWhere((c) => c.uuid == _CYCLE_CHARACTERISTIC_GUID);
  //   await characteristic.write([]);
  // }

  void getServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      print('Service: $service');
    });
  }

  @override
  Widget build(BuildContext context) {
    getServices();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => widget.device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => widget.device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? const Icon(Icons.bluetooth_connected)
                    : const Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${widget.device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: widget.device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => widget.device.discoverServices(),
                      ),
                      const IconButton(
                        icon: SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
