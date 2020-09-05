import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  static final String routeName = 'status';

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          children: [Text('ServiceStatus: ${socketService.serverStatus}')],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          // Emitir {nombre: 'Flutter', menssage: 'Hola desde flutter'}
          socketService.socket.emit('emitir-mensaje',
              {'nombre': 'Flutter', 'message': 'Hola desde flutter'});
        },
      ),
    );
  }
}
