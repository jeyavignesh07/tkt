import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ticket_app/screens/files_page.dart';

class TktAttachments extends StatefulWidget {
  const TktAttachments({
    super.key,
  });
  @override
  State<TktAttachments> createState() => _TktAttachmentsState();
}

class _TktAttachmentsState extends State<TktAttachments> {
  String dropdownValue = 'Raised';

  @override
  void initState() {
    startMove();
    super.initState();
  }

  Future startMove() async {}

  Future<File> saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appStorage.path}/${file.name}');

    return File(file.path!).copy(newFile.path);
  }

  void openFiles(List<PlatformFile> files) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FilesPage(
          files: files,
          onOpenedFile: openFile,
        ),
      ));

  void openFile(PlatformFile file) {
    OpenFilex.open(file.path!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.fromLTRB(10, 70, 10, 50),
          child: Stack(
            children: [
              ElevatedButton(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 90,
                          color: Colors.black,
                        ),
                        Text(
                          'Add Files',
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        )
                      ]),
                ),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);

                  if (result != null) {
                    List<File> files =
                        result.paths.map((path) => File(path!)).toList();

                    for (PlatformFile x in result.files) {
                      final newFile = await saveFilePermanently(x);
                    }
                    openFiles(result.files);
                  } else {
                    // User canceled the picker
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(const Color(0xdd74b9ff)),
                ),
              ),
            ],
          )),
    );
  }
}
