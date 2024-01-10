import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class SreenShow extends StatefulWidget {
  const SreenShow({Key? key}) : super(key: key);

  @override
  State<SreenShow> createState() => _SreenShowState();
}

class _SreenShowState extends State<SreenShow> {
  late bool ledstatus; //boolean value to track LED status, if its ON or OFF
  late IOWebSocketChannel channel;
  late bool connected; //boolean value to track if WebSocket is connected
  String s = "assets/image/photo_2024-01-10_18-55-53.jpg";

  @override
  void initState() {
    ledstatus = false; //initially leadstatus is off so its FALSE
    connected = false; //initially connection status is "NO" so its FALSE

    Future.delayed(Duration.zero, () async {
      channelconnect(); //connect to WebSocket wth NodeMCU
    });

    super.initState();
  }

  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
      channel.stream.listen(
        (message) {
          print(message);
          setState(() {
            if (message == "connected") {
              connected = true; //message is "connected" from NodeMCU
            } else if (message == "poweron:success") {
              ledstatus = true;
            } else if (message == "poweroff:success") {
              ledstatus = false;
            }
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      if (ledstatus == false && cmd != "poweron" && cmd != "poweroff") {
        print("Send the valid command");
      } else {
        channel.sink.add(cmd); //sending Command to NodeMCU
      }
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Controll home",
          style: TextStyle(fontSize: 30),
        ),
        backgroundColor: Colors.blue,
      ),
      body: InkWell(
        onTap: () {
          setState(() {
            if (s == "assets/image/photo_2024-01-10_18-55-53.jpg") {
              sendcmd("poweron");
              s = "assets/image/photo_2024-01-10_18-55-25.jpg";
            } else {
              sendcmd("poweroff");
              s = "assets/image/photo_2024-01-10_18-55-53.jpg";
            }
          });
          setState(() {});
        },
        child: Center(
          child: Ink.image(
            image: AssetImage(s),
            height: 420,
            width: 420,
          ),
        ),
      ),
    );
  }
}
