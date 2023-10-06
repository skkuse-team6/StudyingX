import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 42, 42, 42),
            height: 40,
            child: const Center(
              child:
                  Text("PencilKitBar", style: TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(50),
                color: Colors.white,
                child: Text("NoteArea")),
          ),
        ],
      ),
    );
  }
}
