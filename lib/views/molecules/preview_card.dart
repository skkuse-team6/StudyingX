import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:studyingx/data/note_core_info.dart';
import 'package:studyingx/data/file_manager.dart';
import 'package:studyingx/views/pages/note_page.dart';
import 'package:studyingx/views/molecules/note_preview.dart';
import 'package:studyingx/views/routes.dart';

class PreviewCard extends StatefulWidget {
  PreviewCard({
    required this.filePath,
    required this.selected,
    required this.toggleSelection,
    required this.isAnythingSelected,
  }) : super(key: ValueKey('PreviewCard$filePath'));

  final String filePath;
  final bool selected;
  final void Function(String, bool) toggleSelection;
  final bool isAnythingSelected;

  @override
  State<PreviewCard> createState() => _PreviewCardState();

  static NoteCoreInfo getCachedCoreInfo(String filePath) =>
      _PreviewCardState.getCachedCoreInfo(filePath);
  static void moveFileInCache(String oldPath, String newPath) =>
      _PreviewCardState.moveFileInCache(oldPath, newPath);
}

class _PreviewCardState extends State<PreviewCard> {
  static final Map<String, NoteCoreInfo> _mapFilePathToNoteInfo = {};

  static NoteCoreInfo getCachedCoreInfo(String filePath) {
    return _mapFilePathToNoteInfo[filePath] ?? NoteCoreInfo(filePath: filePath);
  }

  static void moveFileInCache(String oldPath, String newPath) {
    if (oldPath.endsWith(NotePage.extension)) {
      oldPath =
          oldPath.substring(0, oldPath.length - NotePage.extension.length);
    } else {
      assert(false, 'oldPath must end with ${NotePage.extension}');
    }

    if (newPath.endsWith(NotePage.extension)) {
      newPath =
          newPath.substring(0, newPath.length - NotePage.extension.length);
    } else {
      assert(false, 'newPath must end with ${NotePage.extension}');
    }

    if (!_mapFilePathToNoteInfo.containsKey(oldPath)) return;
    _mapFilePathToNoteInfo[newPath] = _mapFilePathToNoteInfo[oldPath]!;
    _mapFilePathToNoteInfo.remove(oldPath);
  }

  ValueNotifier<bool> expanded = ValueNotifier(false);

  late NoteCoreInfo _coreInfo = getCachedCoreInfo(widget.filePath);
  NoteCoreInfo get coreInfo => _coreInfo;
  set coreInfo(NoteCoreInfo coreInfo) {
    _mapFilePathToNoteInfo[widget.filePath] = _coreInfo = coreInfo;
  }

  @override
  void initState() {
    if (_coreInfo.isEmpty) {
      findStrokes();
    }
    fileWriteSubscription =
        FileManager.fileWriteStream.stream.listen(fileWriteListener);

    expanded.value = widget.selected;
    super.initState();
  }

  StreamSubscription? fileWriteSubscription;
  void fileWriteListener(FileOperation event) {
    if (event.filePath != widget.filePath) return;
    if (event.type == FileOperationType.delete) {
      setState(() {
        coreInfo = NoteCoreInfo(filePath: widget.filePath);
      });
    } else if (event.type == FileOperationType.write) {
      findStrokes(fromFileListener: true);
    } else {
      throw Exception('Unknown file operation type: ${event.type}');
    }
  }

  void _toggleCardSelection() {
    expanded.value = !expanded.value;
    widget.toggleSelection(widget.filePath, expanded.value);
  }

  Future findStrokes({bool fromFileListener = false}) async {
    if (!mounted) return;

    coreInfo = await NoteCoreInfo.loadFromFilePath(
      widget.filePath,
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final transitionDuration =
        Duration(milliseconds: disableAnimations ? 0 : 300);
    const double width = 350;
    const double height = 225;

    Widget card = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isAnythingSelected ? _toggleCardSelection : null,
        onLongPress: _toggleCardSelection,
        child: ColoredBox(
          color: Colors.white.withOpacity(0.05),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      FittedBox(
                        child: AnimatedContainer(
                          duration: transitionDuration,
                          width: width,
                          height: height,
                          child: ClipRect(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: NotePreview(
                                key: ValueKey(coreInfo),
                                width: width,
                                height: height,
                                coreInfo: coreInfo,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        left: -1,
                        top: -1,
                        right: -1,
                        bottom: -1,
                        child: ValueListenableBuilder(
                          valueListenable: expanded,
                          builder: (context, expanded, child) =>
                              AnimatedOpacity(
                            opacity: expanded ? 1 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: IgnorePointer(
                              ignoring: !expanded,
                              child: child!,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: _toggleCardSelection,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.8),
                                    Colors.white.withOpacity(1),
                                  ],
                                ),
                              ),
                              child: ColoredBox(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(widget.filePath
                        .substring(widget.filePath.lastIndexOf('/') + 1)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return ValueListenableBuilder(
        valueListenable: expanded,
        builder: (context, expanded, _) {
          return OpenContainer(
            closedColor: Colors.white,
            closedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            closedElevation: expanded ? 4 : 1,
            closedBuilder: (context, action) => card,
            openColor: Colors.white,
            openBuilder: (context, action) => NotePage(path: widget.filePath),
            transitionDuration: transitionDuration,
            routeSettings: RouteSettings(
              name:
                  RoutePaths.editFilePath(widget.filePath + NotePage.extension),
            ),
            onClosed: (_) async {
              findStrokes();

              await Future.delayed(transitionDuration);
              if (!mounted) return;
            },
          );
        });
  }

  @override
  void dispose() {
    fileWriteSubscription?.cancel();
    super.dispose();
  }
}
