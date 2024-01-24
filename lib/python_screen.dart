import 'dart:io';

import 'package:chaquopy/chaquopy.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:test_fifth_ventrical/blutooth_provider.dart';

class PythonScreen extends StatefulWidget {
  const PythonScreen({super.key});

  @override
  _PythonScreenState createState() => _PythonScreenState();
}

class _PythonScreenState extends State<PythonScreen> {
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

  late TextEditingController _controller;
  late FocusNode _focusNode;

  String _outputOrError = "";
  int lala = 12;

  Map<String, dynamic> data = {};
  bool loadImageVisibility = true;
  File myfile = File("assets/Heartbeat18.wav");
  String? content;
  String filePath = "storage/emulated/0/Documents/Chesto/Bhavesh.wav";

  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
    copyAssetToFile("assets/linear_regression_model_for_HR.h5");
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<File> get _makeNewFile async {
    final path = await _localPath;
    print("Path is $path");
    String newFileName = 'linear_regression_model_for_HR.h5';
    return File('$path/$newFileName');
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

  Future<void> copyAssetToFile(String assetFilePath) async {
    ByteData data = await rootBundle.load(assetFilePath);
    List<int> bytes = data.buffer.asUint8List();

    // Write the file to the app's document directory
    File file = await _makeNewFile;
    print(_makeNewFile);
    print("i am callleddd");
    await file.writeAsBytes(bytes);

    print('Asset file copied to: $file');
  }

  void addIntendation() {
    TextEditingController updatedController = TextEditingController();

    int currentPosition = _controller.selection.start;

    String controllerText = _controller.text;
    String text =
        "${controllerText.substring(0, currentPosition)}    ${controllerText.substring(currentPosition, controllerText.length)}";

    updatedController.value = TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: _controller.text.length + 4,
        extentOffset: _controller.text.length + 4,
      ),
    );

    setState(() {
      _controller = updatedController;
    });
  }

  // void openFilePicker() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();

  //   if (result != null) {
  //     // Process the selected file
  //     filePath =
  //         "/stroage/emulated/0/Documents/Chesto/Heartbeat-2024-01-12_11_49_10.wav";
  //     // result.files.single.path!;

  //     // "content://com.android.externalstorage.documents/document/primary%3ADocuments%2FChesto%2FHeartbeat-2024-01-04_00_26_14.wav";
  //     print("Selected file: $filePath");

  //     // Now, you can call your Python code with the file path using Chaquopy
  //     // myPythonModule.callAttr("process", filePath);
  //   } else {
  //     // User canceled the file picker
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, _) {
      return SafeArea(
        top: true,
        minimum: const EdgeInsets.only(top: 4),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      requestFileAccessPermission();
                      // openFilePicker();
                    },
                    child: const Text("data")),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Text(
                      'This shows Output Or Error : $_outputOrError',
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          // height: 50,
                          // color: Colors.green,
                          child: bluetoothProvider.getHrLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'run Code',
                                ),
                          onPressed: () async {
//                           final result = await Chaquopy.executeCode("""
// import librosa, os
// import numpy as np
// from scipy.signal import find_peaks

// os.environ["HDF5_USE_FILE_LOCKING"] = "FALSE"
// print(os.getcwd())

// def calculate_prominence(data, global_sr):
//     two_seconds = 2 * global_sr
//     if len(data) < two_seconds:
//         return 1
//     skip_sample_rate = global_sr - 1000
//     data = data[skip_sample_rate:]
//     reverse_skip_sample = -1 * skip_sample_rate
//     data = data[:-reverse_skip_sample]
//     n_mean, n_std = np.mean(data), np.std(data)
//     arr = []
//     for i in data:
//         temp = i - n_mean
//         temp = temp / n_std
//         if (np.abs(temp) >= 3 and i > 0):
//             arr.append(i)
//     arr.sort()
//     prominence = np.median(arr)
//     return prominence

// def return_beats(data, prominence, sr=4000):
//     numerator = 36 * sr
//     distance = numerator / 100
//     peaks, _ = find_peaks(data, prominence=prominence, distance=distance)
//     return peaks

// def extract_features(audio_file):
//     y, sr = librosa.load(audio_file, sr=None)
//     prominence = calculate_prominence(y, sr)
//     peaks = return_beats(y, prominence, sr)

//     if len(peaks) < 2:
//         return None

//     differences = np.diff(peaks)
//     avg_duration = np.mean(differences) / sr
//     return avg_duration

// def predict_heart_rate(model, audio_file):
//     features = extract_features(audio_file)

//     if features is not None:
//         predicted_hr = model.predict(np.array(features).reshape(-1, 1))
//         return predicted_hr[0]

// import h5py
// from sklearn.linear_model import LinearRegression

// def load_model_from_h5(h5_file_path):
//     with h5py.File(h5_file_path, 'r') as h5_file:
//         coef = h5_file['coef'][()]
//         intercept = h5_file['intercept'][()]

//     model = LinearRegression()
//     model.coef_ = coef
//     model.intercept_ = intercept

//     return model

// heart_rate_prediction = load_model_from_h5('storage/emulated/0/Documents/Chesto/linear_regression_model_for_HR.h5')

// print("HR: ",int(predict_heart_rate(heart_rate_prediction, "$filePath")))

//  """);
                            // to run PythonCode, just use executeCode function, which will return map with following format
                            // {
                            // "textOutputOrError" : output of the code / error generated while running the code
                            // }
                            final result = await Chaquopy.executeCode(
                                """# Multiplication table (from 1 to 10) in Python
import librosa
import numpy as np
from os.path import dirname, join
from sklearn.linear_model import LinearRegression
import h5py
import os
#print(os.getcwd())
#print(os.listdir() )
os.environ["HDF5_USE_FILE_LOCKING"] = "FALSE"

num = $lala

# To take input from the user
# num = int(input("Display multiplication table of? "))
my_list = [1, 2, 3, 4]
#numpy_array = numpy.array(my_list)
# sum = numpy.sum(numpy_array)
# print(sum)
# Iterate 10 times from i = 1 to 10

def calculate_prominence(data, global_sr):
        two_seconds = 2 * global_sr
        if len(data) < two_seconds:
            return 1
        skip_sample_rate = global_sr - 1000
        data = data[skip_sample_rate:]
        reverse_skip_sample = -1 * skip_sample_rate
        data = data[:-reverse_skip_sample]
        n_mean, n_std = np.mean(data), np.std(data)
        arr = []
        for i in data:
            temp = i - n_mean
            temp = temp / n_std
            if (np.abs(temp) >= 3 and i > 0):
                arr.append(i)
        arr.sort()
        prominence = np.median(arr)
        return prominence

y, sr = librosa.load("storage/emulated/0/Documents/Chesto/${bluetoothProvider.newFileName}", sr = None)
bhavesh = calculate_prominence(y, sr)
print (bhavesh)
def load_model_from_h5(h5_file_path):
        with h5py.File(h5_file_path, 'r') as h5_file:
            coef = h5_file['coef'][()]
            intercept = h5_file['intercept'][()]

        model = LinearRegression()
        model.coef_ = coef
        model.intercept_ = intercept

        return model

heart_rate_prediction = load_model_from_h5('storage/emulated/0/Documents/Chesto//linear_regression_model_for_HR.h5')
print()

for i in range(1, 11):
   print(num, 'x', i, '=', num*i)""");
                            setState(() {
                              _outputOrError =
                                  result['textOutputOrError'] ?? '';
                              print(_outputOrError);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
