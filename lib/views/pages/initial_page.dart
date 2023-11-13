import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:studyingx/views/routes.dart';
import 'package:studyingx/utils/navigate_transitions.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/initial_page_bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.only(top: 100, bottom: 100),
            color: Colors.black.withOpacity(0.6),
            child: Column(
              children: [
                const Text(
                  "StudyingX",
                  style: TextStyle(
                    fontSize: 80,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Experience effortless note-taking with next-gen technology.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(185, 255, 255, 255),
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 150),
                ElevatedButton(
                  onPressed: () {
                    push(context, homePage);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Get Started"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
