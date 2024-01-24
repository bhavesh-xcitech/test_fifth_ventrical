import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:test_fifth_ventrical/blutooth_provider.dart';
import 'package:test_fifth_ventrical/data_screen.dart';
import 'package:test_fifth_ventrical/python_code.dart';
import 'package:chaquopy/chaquopy.dart';

@pragma('vm:entry-point')
void someFunction(List<int> finalList) async {
  print("in --->>>>>>>>>>someFunction");
  // Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
  final result = await Chaquopy.executeCode(CodeDir().getContinueHr(finalList));
  print("Running in an isolate with argument : ${result['textOutputOrError']}");

  // Call your function here
  // }

  // );
  print(
      "in --->>>>>>>>>>someFunction eeeeeenneneenneneneenennnnnnddddddddddddd");
}

void main() async {
  print(ServicesBinding.rootIsolateToken);
  BackgroundIsolateBinaryMessenger.ensureInitialized(
      ServicesBinding.rootIsolateToken!);
  runApp(
    ChangeNotifierProvider(
      create: (context) => BluetoothProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({super.key});

  @override
  State<BluetoothApp> createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  static const MethodChannel _channel = MethodChannel('your_channel_name');

  @override
  void initState() {
    Provider.of<BluetoothProvider>(context, listen: false).getBlstate();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text('Paired Devices:'),
              Expanded(
                child: ListView.builder(
                  itemCount: bluetoothProvider.devicesList.length,
                  itemBuilder: (context, index) {
                    // BluetoothDevice device = ;
                    return ListTile(
                      title: Text(
                          bluetoothProvider.devicesList[index].name.toString()),
                      subtitle:
                          Text(bluetoothProvider.devicesList[index].address),
                      onTap: () {
                        bluetoothProvider.connectToDevice(
                          bluetoothProvider.devicesList[index],
                        );
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const DataScreen(),
                        ));
                        // setState(() {
                        //   _device = device;
                        // });
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (bluetoothProvider.blState == BluetoothState.STATE_OFF) {
                    bluetoothProvider.toggleBluetooth();
                  }
                  bluetoothProvider.getPairedDevices();
                },
                child: const Text('Refresh Paired Devices'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
