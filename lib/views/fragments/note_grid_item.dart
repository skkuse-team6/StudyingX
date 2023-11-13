import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyingx/utils/navigate_transitions.dart';
import 'package:studyingx/views/molecules/touchable_card.dart';
import 'package:studyingx/views/routes.dart';

DateFormat formatter = DateFormat('yyyy년 M월 d일 a h:mm:ss', 'ko_KR');

class NoteGridItem extends StatelessWidget {
  const NoteGridItem(
      {super.key, required this.noteTitle, required this.noteEditedAt});

  final String noteTitle;
  final DateTime noteEditedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color.fromARGB(100, 0, 0, 0),
          spreadRadius: -5,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        )
      ]),
      child: TouchableCard(
        onTap: () {
          push(context, notePage);
        },
        child: Column(
          children: [
            Expanded(
                child: Image.asset("assets/images/initial_page_bg.jpg",
                    fit: BoxFit.cover)),
            Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              // alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(color: Colors.white),
              child: (Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    noteTitle,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    formatter.format(noteEditedAt),
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.left,
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
