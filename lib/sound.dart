import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_fifth_ventrical/blutooth_provider.dart';

const int tSampleRate = 6000;

///
const int tBlockSize = 507;

///
typedef Fn = void Function();

/// Example app.
class LivePlaybackWithoutBackPressure extends StatefulWidget {
  const LivePlaybackWithoutBackPressure({super.key});

  @override
  _LivePlaybackWithoutBackPressureState createState() =>
      _LivePlaybackWithoutBackPressureState();
}

class _LivePlaybackWithoutBackPressureState
    extends State<LivePlaybackWithoutBackPressure> {
  @override
  void initState() {
    super.initState();

    Provider.of<BluetoothProvider>(context, listen: false).openMplayer();
  }

  asyncInt() async {}

  @override
  void dispose() {
    Provider.of<BluetoothProvider>(context, listen: false).stopPlayer();

    super.dispose();
  }

  Uint8List createSampleUint8List(int length) {
    // Generate a simple pattern for testing
    List<int> pattern = List.generate(length, (index) => index % 256);
    print(pattern);

    // Create a Uint8List from the pattern
    return Uint8List.fromList(pattern);
  }

  // ----------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Consumer<BluetoothProvider>(
          builder: (context, deviceBlueProvider, _) {
        print("recived atata is ${deviceBlueProvider.receivedData}");
        return Column(
          children: [
            // Text(deviceBlueProvider.receivedData.toString()),
            Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(3),
              height: 80,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0E6),
                border: Border.all(
                  color: Colors.indigo,
                  width: 3,
                ),
              ),
              child: Row(children: [
                ElevatedButton(
                  onPressed: deviceBlueProvider
                      .getPlaybackFn(deviceBlueProvider.receivedData),
                  //color: Colors.white,
                  //disabledColor: Colors.grey,
                  child: Text(
                      deviceBlueProvider.mPlayer.isPlaying ? 'Stop' : 'Play'),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(deviceBlueProvider.mPlayer.isPlaying
                    ? 'Playback in progress'
                    : 'Player is stopped'),
              ]),
            ),
          ],
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Live playback without back pressure'),
      ),
      body: makeBody(),
    );
  }
}
