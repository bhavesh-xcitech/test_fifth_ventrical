import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_fifth_ventrical/blutooth_provider.dart';

class LiveHrCalculate extends StatefulWidget {
  const LiveHrCalculate({super.key});

  @override
  State<LiveHrCalculate> createState() => _LiveHrCalculateState();
}

class _LiveHrCalculateState extends State<LiveHrCalculate> {
  @override
  void initState() {
    Provider.of<BluetoothProvider>(context, listen: false).calculateLiveHr();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
      return Scaffold(
        body: Center(
          child: Text(bluetoothProvider.outputOrError),
        ),
      );
    });
  }
}
