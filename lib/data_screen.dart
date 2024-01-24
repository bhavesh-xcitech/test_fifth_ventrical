// Your other screen

import 'dart:async';
import 'dart:isolate';

import 'package:chaquopy/chaquopy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:test_fifth_ventrical/blutooth_provider.dart';
import 'package:test_fifth_ventrical/python_code.dart';

// import 'package:tflite_flutter/tflite_flutter.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  static const int num = 2;

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  @override
  void initState() {
    Provider.of<BluetoothProvider>(context, listen: false).openMplayer();
    super.initState();
  }

  void requestFileAccessPermission() async {
    var status = await Permission.storage.status;

    if (status.isRestricted) {
      // You can also use `request` method if you don't want to show a dialog
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      // The user granted permission
      print("File access permission granted.");

      // Now you can perform file-related operations
      // For example, list directories, read/write files, etc.
    } else {
      status = await Permission.storage.request();
      // The user denied permission or it was denied with "Never Ask Again"
      print("File access permission denied.");
    }
  }

// // interpreter.getInputTensor(index)
//   void callInterpreter() async {
//     Timer.periodic(const Duration(milliseconds: 150), (timer) {
//       // classify here
//       _runInference();
//     });
//   }

//   Future<void> _runInference() async {
//     Float32List inputArray = await _getAudioFloatArray();
//     final result =
//         await _helper.inference(inputArray.sublist(0, _requiredInputBuffer));
//     setState(() {
//       // take top 3 classification
//       _classification = (result.entries.toList()
//             ..sort(
//               (a, b) => a.value.compareTo(b.value),
//             ))
//           .reversed
//           .take(3)
//           .toList();
//     });
//   }

  @override
  Widget build(BuildContext context) {
    // final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    // bluetoothProvider.receiveData(); // Start listening for data
    AudioPlayer audioPlayer = AudioPlayer();

    return Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Data Screen'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  requestFileAccessPermission();
                },
                child: const Text("check permission")),
            ElevatedButton(
                onPressed: () {
                  if (bluetoothProvider.myConnection == null ||
                      !bluetoothProvider.isConnected) {
                    bluetoothProvider.connectToDevice(
                      bluetoothProvider.device,
                    );
                  } else {
                    bluetoothProvider.disconnect();
                  }
                },
                child: Text((bluetoothProvider.myConnection == null ||
                        !bluetoothProvider.isConnected)
                    ? "connect "
                    : "disconnect"))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        bluetoothProvider.sendMessage("START");
                        // bluetoothProvider.calculateLiveHr();
                      },
                      child: const Text("Start")),
                  ElevatedButton(
                      onPressed: () {
                        bluetoothProvider.sendMessage("STOP");
                        Provider.of<BluetoothProvider>(context, listen: false)
                            .stopPlayer();
                      },
                      child: const Text("STOP")),
                  ElevatedButton(
                      onPressed: bluetoothProvider
                          .getPlaybackFn(bluetoothProvider.receivedData),
                      child: Text(bluetoothProvider.mPlayer.isPlaying
                          ? 'Stop'
                          : 'Play Sound'))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        bluetoothProvider.savefile();
                      },
                      child: const Text("save file ")),
                  ElevatedButton(
                      onPressed: () async {
                        bluetoothProvider.clearList();
                      },
                      child: const Text("clear list")),
                  ElevatedButton(
                    onPressed: () async {
                      bluetoothProvider.calculateHr();
                      // Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (context) => const PythonScreen(),
                      //       ));
                    },
                    child: const Text('get HR'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      useIsolate(bluetoothProvider.finalList);

                      print(bluetoothProvider.finalSubList);
                      if (bluetoothProvider.finalSubList != null &&
                          bluetoothProvider.finalSubList!.isNotEmpty) {
                        // Timer.periodic(const Duration(seconds: 2),
                        //     (Timer timer) {
                        // Call your function here

                        // });R
                      }
                    },
                    child: const Text('live HR'),
                  ),
                ],
              ),
              const Text('Received Data:'),
              Text(
                bluetoothProvider.receivedData.toString(),
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                bluetoothProvider.outputOrError.toString(),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    });
  }
}

useIsolate1(List<int> subList) async {
  print("useIsolate");
  final ReceivePort receivePort = ReceivePort();
  try {
    WidgetsFlutterBinding.ensureInitialized();
    BackgroundIsolateBinaryMessenger.ensureInitialized(
        ServicesBinding.rootIsolateToken!);
    await Isolate.spawn(
        runHeavyTaskIWithIsolate, [receivePort.sendPort, subList]);
  } catch (e, s) {
    debugPrint('Isolate Failed $e');
    debugPrint(' Failed cause $s');
    receivePort.close();
  }
  final response = await receivePort.first;

  print('Result: $response');
}

Future<String> runHeavyTaskIWithIsolate1(List<dynamic> args) async {
  print("runHeavyTaskIWithIsolate");
  SendPort resultPort = args[0];
  print(args[1]);

  try {
    final result = await Chaquopy.executeCode(CodeDir().getContinueHr(args[1]));
    print("i am calledd");

    print("result['textOutputOrError'] -->> $result");
    Isolate.exit(resultPort, result);
  } catch (e, s) {
    debugPrint('runHeavyTaskIWithIsolate Failed $e');
    debugPrint(' runHeavyTaskIWithIsolate cause $s');
    Isolate.exit(resultPort, "Error occurred");
  }
}

useIsolate(dataa) async {
  final ReceivePort receivePort = ReceivePort();
  try {
    await Isolate.spawn(
        runHeavyTaskIWithIsolate, [receivePort.sendPort, dataa.length]);
  } on Object {
    debugPrint('Isolate Failed');
    receivePort.close();
  }
  final response = await receivePort.first;
  print('Result: $response');
}

Future<int> runHeavyTaskIWithIsolate(List<dynamic> args) async{
  SendPort resultPort = args[0];
  final result = await Chaquopy.executeCode(CodeDir().getPyCode(
      "storage/emulated/0/Documents/Chesto/Heartbeat-2024-01-22_12_24_05.wav"));
  print(result["textOutputOrError"]);
  int value = DataScreen.num;
  for (var i = 0; i < args[1]; i++) {
    value += i;
  }
  Isolate.exit(resultPort, value);
}
