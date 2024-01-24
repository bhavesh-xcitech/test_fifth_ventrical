import 'dart:async';
import 'dart:io';
import 'dart:isolate';
// import 'dart:html';
// import 'dart:io';
import 'dart:typed_data';

import 'package:chaquopy/chaquopy.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_fifth_ventrical/main.dart';
import 'package:test_fifth_ventrical/python_code.dart';
import 'package:test_fifth_ventrical/wavheader.dart';

class BluetoothProvider extends ChangeNotifier {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? myConnection;
  Int16List? audioSamples;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? device;
  Uint8List receivedData = Uint8List(0);
  final FlutterSoundPlayer mPlayer = FlutterSoundPlayer();
  bool mPlayerIsInited = false;
  int tSampleRate = 6000;
  List<int> finalList = [];
  BluetoothState? blState;
  bool isConnected = false;
  String? newFileName;
  String outputOrError = "";
  bool getHrLoading = false;
  int secCount = 0;
  List<int>? finalSubList;
  FlutterIsolate? isolate;

  List<List<int>> yourList = [];

  int count = 0;

  getBlstate() {
    _bluetooth.state.then((value) {
      blState = value;
    });
    _bluetooth.onStateChanged().listen((event) {
      blState = event;
      if (blState!.isEnabled) {
        getPairedDevices();
      }
      print("Bluetooth:$blState");
    });
  }

  void getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await _bluetooth.getBondedDevices();
    } catch (e) {
      print("Error getting paired devices: $e");
    }

    devicesList = devices;
    notifyListeners();
  }

  Future<bool> toggleBluetooth({bool? value}) async {
    bool r = false;
    _bluetooth.requestEnable().then((value) {
      print("Bluetooth enable");
      r = value ?? r;
    });
    notifyListeners();
    return r;
  }

  void startDiscovery() {
    _bluetooth.startDiscovery().listen(
      (event) {
        print("i am starte");
        print(event.rssi);
        print("event.device${event.device}");
        devicesList.add(event.device);
        notifyListeners();
      },
      onError: (error) {
        print("Discovery error: $error");
      },
    );

    Future.delayed(const Duration(seconds: 20), () {
      _bluetooth.cancelDiscovery();
    });
  }

  void connectToDevice(
    BluetoothDevice? myDevice,
  ) async {
    print(myDevice);
    if (myDevice != null) {
      device = myDevice;
      notifyListeners();

      BluetoothConnection connection;

      try {
        connection = await BluetoothConnection.toAddress(device!.address);
        print("on done callled -->>>$connection");
        if (connection.isConnected) {
          isConnected = true;
          notifyListeners();
        }
      } catch (e) {
        print("Error connecting to device: $e");
        return;
      }

      myConnection = connection;

      myConnection?.input?.listen(
        (Uint8List data) async {
          if (mPlayerIsInited && !mPlayer.isStopped) {
            feedHim(data);
            notifyListeners();
          }
          count += data.length;
          // print(finalList.length);
          finalList.addAll(Uint8List.fromList(data));

          yourList.add(data);

          receivedData = data;
          if (finalList.length >= 9000) {
            print("list cresooosss 9000");
            // isolate = await FlutterIsolate.spawn(someFunction, finalList);

            // List<int> subList = finalList.sublist(secCount, (secCount + 9000));
            // secCount += 9000;
            // finalSubList = subList;

            // print("secCount --->>$subList");
            // calculateIsolateLiveHr(subList);
            // Isolate.spawn<IsolateModel>(heavyTask, IsolateModel(355000, 500));

            // final result =
            //     await Chaquopy.executeCode(CodeDir().getContinueHr(subList));
            // outputOrError = result['textOutputOrError'] ?? '';
            getHrLoading = false;

            // final result =
            //     await Chaquopy.executeCode(CodeDir().getContinueHr(subList));
            // outputOrError = result['textOutputOrError'] ?? '';
            // getHrLoading = false;

            notifyListeners();
            // CodeDir().getContinueHr(subList);
          }

          String message = String.fromCharCodes(data);
        },
        onDone: () {
          print("on done callled");
        },
        onError: (error, s) {
          _disconnect();
        },
        cancelOnError: true,
      );

      notifyListeners();
    }
  }

  void sendMessage(String message) {
    if (message == "STOP") {
      isolate?.kill(priority: Isolate.immediate);
      myConnection?.close();
      print("----->>>>>>>$finalList<<<<------------");
      // print("----->>>>>>>${finalList.length}<<<<------------");
    }
    if (myConnection != null) {
      myConnection!.output.add(Uint8List.fromList(message.codeUnits));
      myConnection!.output.allSent.then((_) {
        // print("Sent message: $message");
      });
    }
  }

  void _disconnect() {
    myConnection?.dispose();
    myConnection = null;
    notifyListeners();
  }

  Future<void> disconnect() async {
    print(myConnection);
    if (myConnection != null) {
      isConnected = false;
      notifyListeners();
      await myConnection!.close();
      _disconnect();
    }
  }

  void Function()? getPlaybackFn(Uint8List receivedData) {
    if (!mPlayerIsInited) {
      return null;
    }
    return mPlayer.isStopped
        ? () => play()
        : () {
            stopPlayer().then((value) {
              notifyListeners();
            });
          };
  }

  void play() async {
    print(receivedData.length);

    assert(mPlayerIsInited && mPlayer.isStopped);
    await mPlayer.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: tSampleRate,
    );
    notifyListeners();
  }

  void feedHim(Uint8List data) async {
    mPlayer.foodSink!.add(FoodData(data));
    // final result = await compute(someFunction, finalList);
    print("amnasbdbmdasdna");
  }


  Future<void> stopPlayer() async {
    await mPlayer.stopPlayer();
  }

  void openMplayer() {
    mPlayer.openPlayer().then((value) {
      print(value);
      mPlayerIsInited = true;
      notifyListeners();
    });
  }

  Uint8List convertListToUint8List(List<double> inputList) {
    var uint8List = Uint8List(inputList.length);
    for (int i = 0; i < inputList.length; i++) {
      uint8List[i] = inputList[i].toInt();
    }
    return uint8List;
  }

  clearList() {
    secCount = 0;
    finalList.clear();
    yourList.clear();
    print(secCount);
    notifyListeners();
  }

  savefile() async {
    if (true) {
      print("------>>>>>final list $finalList");
      print("----->>>>>>final list length is ${finalList.length}");
      print("####################################################");
      print("------>>>>>your list list $yourList");

      print("-------->>>>>>>legth of your list${yourList.length}");
      print(yourList.length);
      if (yourList.isEmpty || count == 0) {
        print("return zero");
        return;
      }

      print("CompleteByte length : $count");
      Uint8List bytes = Uint8List(count);
      int offset = 0;
      for (final List<int> c in yourList) {
        bytes.setRange(offset, offset + c.length, c);
        offset += c.length;
      }
      final file = await _makeNewFile;
      print("i am file -->>> $file");

      var headerList =
          WAVEHEADER(SAMPLE_RATE: 6000, bits: 16).createWavHeader(count);

      file.create(recursive: true);

      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(headerList, mode: FileMode.write);
      file.writeAsBytes(bytes, mode: FileMode.append).then((value) {
        print(value.length().toString());
        print(value.path);
        print("Header Bytes: $headerList");
        print("Header Length: ${headerList.length}");
        count = 0;
        yourList.clear();
      });

      // showSavePopup(data: bytes);
    } else {
      // appLog("File not saved because of auto started");
    }
  }

  Future<File> get _makeNewFile async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd_HH_mm_ss");

    final path = await _localPath;
    print("Path is $path");
    newFileName = '${"Heartbeat"}-${dateFormat.format(DateTime.now())}';
    return File('$path/$newFileName.wav');
  }

  Future<String> get _localPath async {
    var status = await Permission.storage.status;
    print("Permission status");
    if (status.isDenied) {
      print("Permission denied");
      // We didn't ask for permission yet.
      if (await Permission.storage.request().isGranted ||
          await Permission.audio.request().isGranted) {
        print("Permission granted");
        var directory = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOCUMENTS);
        print("directory -->>$directory");
        return '$directory/Chesto/';
        // Either the permission was already granted before or the user just granted it.
      }
    } else if (status.isGranted) {
      print("Permission is granted");
      var dirs = await ExternalPath.getExternalStorageDirectories();
      print("diresss ->>$dirs");
      var directory = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOCUMENTS);
      return '$directory/Chesto/';
    }

    // You can can also directly ask the permission about its status.
    if (await Permission.storage.isRestricted) {
      // The OS restricts access, for example because of parental controls.
    }

    return '';
  }

  Future<int> deleteFile() async {
    try {
      final file = await _makeNewFile;

      await file.delete();
      print("something went wrong");
      return 1;
    } catch (e) {
      print("deleted successfully");
      return 0;
    }
  }

  calculateHr() async {
    print(finalList);
    getHrLoading = true;

    outputOrError = "";
    notifyListeners();

    if (newFileName != null && newFileName != "") {
      final result =
          await Chaquopy.executeCode(CodeDir().getPyCode(newFileName!));
      outputOrError = result['textOutputOrError'] ?? '';
      getHrLoading = false;
      notifyListeners();
    } else {
      getHrLoading = false;

      print("object");
      notifyListeners();

      // outputOrError = "file does not exist";
      // notifyListeners();
    }
  }

  calculateLiveHr() {
    if (finalList.length >= secCount + 9000) {
      List<int> subList = finalList.sublist(secCount, (secCount + 9000));
      secCount += 9000;
      subList = subList;

      // print("secCount --->>$subList");
      // calculateIsolateLiveHr(subList);
      // Isolate.spawn<IsolateModel>(heavyTask, IsolateModel(355000, 500));

      // final result =
      //     await Chaquopy.executeCode(CodeDir().getContinueHr(subList));
      // outputOrError = result['textOutputOrError'] ?? '';
      getHrLoading = false;

      // final result =
      //     await Chaquopy.executeCode(CodeDir().getContinueHr(subList));
      // outputOrError = result['textOutputOrError'] ?? '';
      // getHrLoading = false;

      notifyListeners();
      // CodeDir().getContinueHr(subList);
    }
    getHrLoading = true;
    // calculateLiveHr();
    notifyListeners();
  }

  useIsolate() async {
    final ReceivePort receivePort = ReceivePort();
    try {
      await Isolate.spawn(
          runHeavyTaskIWithIsolate, [receivePort.sendPort, 4000000000]);
    } catch (e, s) {
      debugPrint('Isolate Failed $e');
      debugPrint(' Failed cause $s');
      receivePort.close();
    }
    final response = await receivePort.first;

    print('Result: $response');
  }

  int runHeavyTaskIWithIsolate(List<dynamic> args) {
    SendPort resultPort = args[0];
    int value = 0;
    for (var i = 0; i < args[1]; i++) {
      value += i;
    }
    Isolate.exit(resultPort, value);
  }

  Future<void> calculateIsolateLiveHr(List<int> subList) async {
    print("i am calculateIsolateLiveHr");
    final ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(_calculateLiveHrIsolate, receivePort.sendPort);

    final Completer<void> completer = Completer<void>();
    receivePort.listen((dynamic data) {
      if (data is String) {
        // Handle the result received from the isolate
        print("Result from isolate: $data");
        completer.complete();
      }
    });

    // Send the data to the isolate
    receivePort.first;

    // Wait for the isolate to finish processing
    await completer.future;

    receivePort.close();
  }

  void _calculateLiveHrIsolate(SendPort sendPort) {
    print("i am _calculateLiveHrIsolate");

    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic data) async {
      if (data is List<int>) {
        // Perform the heavy processing logic
        String result = await _performHeavyProcessing(data);

        // Send the result back to the main isolate
        sendPort.send(result);
      }
    });
  }

  Future<String> _performHeavyProcessing(List<int> subList) async {
    final result = await Chaquopy.executeCode(CodeDir().getContinueHr(subList));
    return result['textOutputOrError'] ?? '';
  }

  void heavyTask(IsolateModel model) {
    int total = 0;

    /// Performs an iteration of the specified count
    for (int i = 1; i < model.iteration; i++) {
      /// Multiplies each index by the multiplier and computes the total
      total += (i * model.multiplier);
    }
    print("FINAL TOTAL: $total");
  }
}

class IsolateModel {
  IsolateModel(this.iteration, this.multiplier);
  final int iteration;
  final int multiplier;
}
