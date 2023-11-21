import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyingx/data/file_manager.dart';
import 'package:studyingx/views/pages/note_page.dart';
import 'package:studyingx/views/molecules/adaptive_alert_dialog.dart';
import 'package:studyingx/views/molecules/adaptive_text_field.dart';

class RenameBtn extends StatelessWidget {
  const RenameBtn({
    super.key,
    required this.existingPath,
  });

  final String existingPath;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      tooltip: 'Rename',
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _RenameDialog(
              existingPath: existingPath,
            );
          },
        );
      },
      icon: const Icon(Icons.edit_square),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({
    required this.existingPath,
  });

  final String existingPath;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  late final String parentFolder = widget.existingPath.substring(
    0,
    widget.existingPath.lastIndexOf('/') + 1,
  );
  late final String oldName = widget.existingPath.substring(
    widget.existingPath.lastIndexOf('/') + 1,
  );

  String? validateNoteName(String? noteName) {
    if (noteName == null || noteName.isEmpty) {
      return 'Note name can\'t be empty';
    }
    if (noteName.contains('/') || noteName.contains('\\')) {
      return 'Note name can\'t contain a slash';
    }
    if (noteName != oldName && doesFileExist(noteName)) {
      return 'Note name already exists';
    }
    return null;
  }

  bool doesFileExist(String noteName) {
    final file = File(parentFolder + noteName);
    return file.existsSync();
  }

  Future renameNote(String newName) async {
    await FileManager.moveFile(
      widget.existingPath + NotePage.extension,
      newName + NotePage.extension,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.text = oldName;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveAlertDialog(
      title: const Text(
        'Rename Note',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: AdaptiveTextField(
          controller: _controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          focusOrder: const NumericFocusOrder(1),
          validator: validateNoteName,
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child:
              const Text('Cancel', style: TextStyle(color: Colors.lightGreen)),
        ),
        CupertinoDialogAction(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            if (_controller.text != oldName) {
              await renameNote(_controller.text);
              if (!mounted) return;
            }
            Navigator.of(context).pop();
          },
          child:
              const Text('Rename', style: TextStyle(color: Colors.lightGreen)),
        ),
      ],
    );
  }
}
