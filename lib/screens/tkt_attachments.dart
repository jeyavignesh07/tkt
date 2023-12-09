import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as gets;
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ticket_app/models/tkt.dart';
import 'package:ticket_app/screens/pdf_viewer.dart';
import 'package:ticket_app/screens/video_player.dart';
import 'package:ticket_app/service/api_base.dart';
import 'package:ticket_app/widgets/error_warning_ms.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../db/tkt_db.dart';

class TktAttachments extends StatefulWidget {
  final String tktNo;
  const TktAttachments({
    super.key,
    required this.tktNo,
  });
  @override
  State<TktAttachments> createState() => _TktAttachmentsState();
}

class _TktAttachmentsState extends State<TktAttachments> {
  List<File> selectedfiles = [];
  List<String> docid = [];
  late Response response;
  String progress = "";
  String devId = "";
  String userId = "";
  Dio dio = Dio();

  late bool _upload;
  late double _progressValue;
  @override
  void initState() {
    startMove();
    super.initState();
    _upload = false;
    _progressValue = 0.0;
  }

  Future startMove() async {
    var sharedFiles = await TktDb.instance.getSharedFiles();
    if (sharedFiles.length > 0) {
      String x = sharedFiles[0].file.toString();

      final appStorage = await getApplicationDocumentsDirectory();
      final newFile =
          File('${appStorage.path}/${await getDocId()}${Path.extension(x)}');
      File sf = await File(x).copy(newFile.path);

      selectedfiles.add(sf);
      //selectedfiles.add(File(x));
      setState(() {});
    }
    await TktDb.instance.deleteSharedFiles();
  }

  uploadFile() async {
    int i = 1;
    int len = selectedfiles.length;
    for (File file in selectedfiles) {
      String uploadurl =
          "https://display.hawkins-futura.com/ftkt_upload_file_sec.php";

      FormData formdata = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path,
            filename: Path.basename(file.path)
            //show only filename from path
            ),
      });
      setState(() {
        progress = "Uploading $i of $len";
      });
      response = await dio.post(
        uploadurl,
        data: formdata,
        onSendProgress: (int sent, int total) {
          double percentage = (sent / total * 1);
          setState(() {
            _progressValue = percentage;
            //progress = "$sent Bytes of $total Bytes - $percentage % uploaded";
            //update the progress
          });
        },
      );

      if (response.statusCode == 200) {
        _upload = true;
        i++;
        //print response from server
      } else {
        _upload = false;
        progress = "Uploading Failed!";
      }
    }
    if (_upload) {
      for (File x in selectedfiles) {
        docid.add(Path.basename(x.path));
      }
      saveDoc();
    }
  }

  Future saveDoc() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse(ApiBase.baseUrl + ApiBase.addAttachmentEndPoint));
    request.body = json.encode({
      "tktNo": widget.tktNo,
      "docid": docid,
      "addedBy": userId,
      "addedOn": DateTime.now().toString().substring(0, 23),
    });
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response =
          await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var data1 = jsonDecode(data);
        var data2 = data1["tktAttachments"] as List;
        List<TktDtlAttachment> tktAttachments =
            data2.map((tagJson) => TktDtlAttachment.fromJson(tagJson)).toList();
        await TktDb.instance.createTktAttachments(tktAttachments);
        selectedfiles = [];
        Message.taskErrorOrWarning(
            "Files Uploaded", "Succesfully", "#99EFABE5");
        setState(() {});
        return;
      } else {
        Message.taskErrorOrWarning(
            "Server Error", "Please try again later.", "#103463");
      }
    } on Exception catch (ex) {
      Message.taskErrorOrWarning(
          "Server Error", "Please try again later.", "#103463");
    }
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile =
        File('${appStorage.path}/${await getDocId()}.${(file.extension)}');

    return File(file.path!).copy(newFile.path);
  }

  Future<String> getDocId() async {
    int i = 0;
    i = selectedfiles.length;
    var data = await TktDb.instance.getUserInfo();

    if (data.length > 0) {
      devId = data[0].devid.toString();
      userId = data[0].empId.toString();
    }
    var data1 = await TktDb.instance.getTktDocCount(widget.tktNo);
    i = (i + (data1.length + 1)) as int;
    String docid = "${widget.tktNo}_${devId}_${i.toString()}";
    return docid;
  }

  Widget show({
    required List<File> files,
  }) {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return buildFile(file);
      },
    );
  }

  Widget buildFile(File file) {
    final kb = file.lengthSync() / 1024;
    final mb = kb / 1024;
    final size = (mb >= 1)
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
    return Container(
      child: InkWell(
        onTap: () => OpenFilex.open(file.path),
        child: Container(
          margin:
              const EdgeInsets.only(top: 5, left: 10.0, right: 10.0, bottom: 5),
          height: 100,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[300],
          ),
          child: ListTile(
            leading: (Path.extension(file.path) == '.jpg' ||
                    Path.extension(file.path) == '.png')
                ? SizedBox(
                    width: 80,
                    child: Image.file(
                      File(
                        file.path.toString(),
                      ),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.red,
                    ),
                    child: Center(
                        child: Text(
                      Path.extension(file.path),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
            title: Text(Path.basename(file.path)),
            subtitle: Text(Path.extension(file.path)),
            trailing: Text(size),
          ),
        ),
      ),
    );
  }

  // Widget showAttachments() {

  //   return ListView.builder(
  //     itemCount: docData.length,
  //     itemBuilder: (context, index) {
  //       final file = docData[index];
  //       return buildAttachments(file);
  //     },
  //   );
  // }

  Widget buildAttachments(TktDtlAttachment file) {
    return Container(
      child: InkWell(
        onTap: () async {
          String ext = Path.extension(file.docid);
          if (ext == '.jpg' || ext == '.jpeg') {
            await showDialog(
                context: context,
                builder: (_) => imageDialog(file.docid, file.docid, context));
          } else if (ext == '.mp4' || ext == '.mp3') {
            gets.Get.to(VideoApp(
              docid: file.docid,
            ));
          } else if (ext == '.pdf') {
            gets.Get.to(PdfViewerPage(
              docid: file.docid,
            ));
          }
        },
        child: Container(
          margin:
              const EdgeInsets.only(top: 2, left: 10.0, right: 10.0, bottom: 2),
          height: 80,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[300],
          ),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 80,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.red,
              ),
              child: Center(
                  child: Text(
                Path.extension(file.docid),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )),
            ),
            title: Text(Path.basename(file.docid)),
            subtitle: Text(
                softWrap: true,
                maxLines: 2,
                ('${file.addedBy}\n${DateFormat('dd-MMM-yyyy – kk:mm').format(DateTime.parse(file.addedOn))}')),
            // trailing: Text(size),
          ),
        ),
      ),
    );
  }

  Widget imageDialog(text, path, context) {
    return Dialog(
      // backgroundColor: Colors.transparent,
      // elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$text',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close_rounded),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: GestureDetector(
              onLongPress: () async {
                await Clipboard.setData(ClipboardData(
                    text: "https://display.hawkins-futura.com/uploads/$path"));
                // copied successfully
                Fluttertoast.showToast(
                    msg: "Link copied to clip board",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
              child: PhotoView(
                backgroundDecoration: const BoxDecoration(color: Colors.white),
                enableRotation: true,
                imageProvider: CachedNetworkImageProvider(
                    "https://display.hawkins-futura.com/uploads/$path"),
                maxScale: 100.0,
              ),
            ),
//

            // child: Image.network(
            //   'https://display.hawkins-futura.com/uploads/$path',
            //   fit: BoxFit.contain,
            // ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.fromLTRB(10, 50, 10, 50),
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ListView(
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.custom,
                        allowedExtensions: [
                          'jpg',
                          'jpeg',
                          'png',
                          'pdf',
                          'mp4',
                          'mp3'
                        ],
                      );

                      if (result != null) {
                        for (PlatformFile x in result.files) {
                          final newFile = await saveFilePermanently(x);
                          selectedfiles.add(newFile);
                        }

                        setState(() {});
                        // selectedfiles =
                        //     result.paths.map((path) => File(path!)).toList();

                        // for (PlatformFile x in result.files) {
                        //   final newFile = await saveFilePermanently(x);
                        // }
                        // openFiles(result.files);
                      } else {
                        // User canceled the picker
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xdd74b9ff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: 50,
                              color: Colors.grey[850],
                            ),
                            Text(
                              'Add Files',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey[850],
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            )
                          ]),
                    ),
                  ),
                  selectedfiles.isEmpty
                      ? const SizedBox()
                      : SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: show(files: selectedfiles),
                        ),
                  selectedfiles.isEmpty
                      ? Container()
                      : SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              uploadFile();
                              // for (File x in selectedfiles) {
                              //   uploadFile(x);
                              // }
                            },
                            icon: Icon(
                              Icons.cloud_upload_rounded,
                              size: 34,
                              color: Colors.grey[850],
                            ),
                            label: Text(
                              'Upload Files',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey[850],
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xdd74b9ff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                            ),
                          )),
                  selectedfiles.isEmpty
                      ? Container()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(progress),
                            LinearProgressIndicator(
                              backgroundColor: Colors.yellow,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.red),
                              value: _progressValue,
                            ),
                            Text('${(_progressValue * 100).round()}%'),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Attached Files',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[850],
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  FutureBuilder(
                    future: TktDb.instance.getTktAttachmentDetail(widget.tktNo),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.all(10.0),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, i) {
                                return buildAttachments(snapshot.data[i]);
                              },
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            );
                    },
                  ),
                ],
              ))),
    );
  }
}
