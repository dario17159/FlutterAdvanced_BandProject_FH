import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  static final String routeName = "home";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
/*     Band(id: '1', name: 'Metalica', votes: 5),
    Band(id: '2', name: 'Wisin y Yandel', votes: 1),
    Band(id: '3', name: 'Romeo Santos', votes: 2),
    Band(id: '4', name: 'Maluma', votes: 8) */
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Band Names',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => _bandTile(bands[index]),
              itemCount: bands.length,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: _addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete Band',
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  _addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New Band Name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                    onPressed: () => _addBandToList(textController.text),
                    child: Text('Add'),
                    textColor: Colors.blue,
                    elevation: 5,
                  )
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('New band Name'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Add'),
                  isDefaultAction: true,
                  onPressed: () {
                    _addBandToList(textController.text);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Dismiss'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  _addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  _showGraph() {
    Map<String, double> dataMap = new Map();
    if (bands.length != 0) {
      bands.forEach((band) {
        dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
      });
      return Container(
          width: double.infinity,
          height: 200,
          child: PieChart(dataMap: dataMap));
    } else {
      return Container(
          width: double.infinity,
          height: 200,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }
}
