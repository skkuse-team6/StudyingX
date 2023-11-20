import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collapsible/collapsible.dart';
import 'package:studyingx/data/file_manager.dart';
import 'package:studyingx/views/fragments/view_files.dart';
import 'package:studyingx/views/molecules/rename_btn.dart';
import 'package:studyingx/views/pages/note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> filePaths = [];
  bool failed = false;
  final ValueNotifier<List<String>> selectedFiles = ValueNotifier([]);

  @override
  void initState() {
    findRecentlyAccessedNotes();
    fileWriteSubscription =
        FileManager.fileWriteStream.stream.listen(fileWriteListener);

    super.initState();
  }

  StreamSubscription? fileWriteSubscription;
  void fileWriteListener(FileOperation event) {
    findRecentlyAccessedNotes(fromFileListener: true);
  }

  Future findRecentlyAccessedNotes({bool fromFileListener = false}) async {
    if (!mounted) return;

    final children = await FileManager.getRecentlyAccessed();
    filePaths.clear();
    if (children.isEmpty) {
      failed = true;
    } else {
      failed = false;
      filePaths.addAll(children);
    }

    if (mounted) setState(() {});
  }

  Future<void> _deleteFile(String filePath) async {
    bool fileExists =
        await FileManager.doesFileExist(filePath + NotePage.extension);

    if (fileExists) {
      await FileManager.deleteFile(filePath + NotePage.extension);
    }
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = MediaQuery.of(context).size.width ~/ 300 + 1;
    return WillPopScope(
        onWillPop: () async {
          await findRecentlyAccessedNotes();
          return true;
        },
        child: Scaffold(
          body: RefreshIndicator(
            color: const Color(0xFF8CBE47),
            onRefresh: () => Future.wait([
              findRecentlyAccessedNotes(),
              Future.delayed(const Duration(milliseconds: 500)),
            ]),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  sliver: SliverAppBar(
                    collapsedHeight: kToolbarHeight,
                    expandedHeight: 170,
                    pinned: true,
                    scrolledUnderElevation: 1,
                    flexibleSpace: const FlexibleSpaceBar(
                      title: Text('All Notes',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                      titlePadding:
                          EdgeInsetsDirectional.only(start: 32, bottom: 16),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0.0),
                      child: Transform.translate(
                        offset: const Offset(0, 24.0),
                        child: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NotePage()),
                              ).then((_) {
                                setState(() {
                                  findRecentlyAccessedNotes();
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 163, 220, 83),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text("New"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverSafeArea(
                  sliver: ViewFiles(
                    crossAxisCount: crossAxisCount,
                    files: [
                      for (String filePath in filePaths) filePath,
                    ],
                    selectedFiles: selectedFiles,
                  ),
                ),
              ],
            ),
          ),
          persistentFooterButtons: [
            //rename
            ValueListenableBuilder(
              valueListenable: selectedFiles,
              builder: (context, selectedFiles, _) {
                return Collapsible(
                  axis: CollapsibleAxis.vertical,
                  collapsed: selectedFiles.length != 1,
                  child: RenameBtn(
                    existingPath:
                        selectedFiles.isEmpty ? '' : selectedFiles.first,
                  ),
                );
              },
            ),
            //delete
            ValueListenableBuilder(
              valueListenable: selectedFiles,
              builder: (context, selectedFiles, child) {
                return Collapsible(
                  axis: CollapsibleAxis.vertical,
                  collapsed: selectedFiles.isEmpty,
                  child: child!,
                );
              },
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Delete',
                onPressed: () async {
                  await Future.wait([
                    for (String filePath in selectedFiles.value)
                      _deleteFile(filePath),
                  ]);
                  selectedFiles.value = [];
                },
                icon: const Icon(Icons.delete_forever),
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    fileWriteSubscription?.cancel();
    super.dispose();
  }
}
