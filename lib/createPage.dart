import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:post_adder/post.dart';
import 'package:path/path.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class CreatePage extends StatefulWidget {
  Box boxReference;
  int? index;
  File? intentImage;
  VoidCallback updateParentState;
  CreatePage(
      {super.key,
      required this.boxReference,
      this.index,
      this.intentImage,
      required this.updateParentState});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController captionController = TextEditingController();
  String? fileNameGlobal;
  PostModel? post;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.index != null) {
      post = widget.boxReference.getAt(widget.index!);
      if (post != null) {
        captionController.text = post!.caption!;
        fileNameGlobal = post!.imagePath;
      }
    }
    ReceiveSharingIntent.getInitialMedia()
        .then((value) => value.forEach((element) {
              //File imageFile = File(element.path);
              print("Intent received");
            }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Create Post",
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Create post"),
          ),
          body: Column(children: [
            TextField(
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: "What's in my mind ?",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.blue),
                ),
              ),
              controller: captionController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: const Size(10, 40)),
                      child: const Icon(Icons.photo_camera),
                      onPressed: () async {
                        // _askCameraAccess();
                        XFile? imageXFile = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (imageXFile == null) return;
                        File imageFile = File(imageXFile.path);
                        _handleImage(imageFile);
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: const Size(10, 40)),
                        child: const Icon(Icons.image),
                        onPressed: () async {
                          // _askCameraAccess();
                          XFile? imageXFile = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (imageXFile == null) return;
                          File? imageFile = File(imageXFile.path);
                          _handleImage(imageFile);
                        }),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 5,
                      minimumSize: const Size(80, 45)),
                  onPressed: () async {
                    if (captionController.text != "" ||
                        fileNameGlobal != null) {
                      if (captionController.text == "delete") {
                        await widget.boxReference
                            .deleteAll(widget.boxReference.keys);
                        captionController.clear();
                      } else {
                        String caption = captionController.text;
                        String createdAt = post != null
                            ? post!.createdAt!
                            : DateTime.now().toString();
                        PostModel model = PostModel(
                            caption: caption,
                            imagePath: fileNameGlobal,
                            createdAt: createdAt);
                        if (post != null) {
                          widget.boxReference.putAt(widget.index!, model);
                        } else {
                          widget.boxReference.add(model);
                        }
                        widget.updateParentState();
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text(
                    "post",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
            fileNameGlobal != null
                ? Image.file(File(fileNameGlobal!))
                : const Text(''),
          ]),
        ));
  }

  void _handleImage(File? imageFile) async {
    if (imageFile == null) return;
    final String applicationFilePath = (await _getDirectory()).path;
    final String fileName = basename(imageFile.path);
    await FlutterImageCompress.compressAndGetFile(
        imageFile.path, '$applicationFilePath/$fileName',
        quality: 30);
    setState(() {
      fileNameGlobal = '$applicationFilePath/$fileName';
    });
  }

  Future<Directory> _getDirectory() async {
    const String pathExt = 'MyLife';
    String externalAppPath = '/storage/emulated/0/$pathExt';
    Directory externalAppDirectory = Directory(externalAppPath);
    if (await externalAppDirectory.exists() == false) {
      return externalAppDirectory.create(recursive: true);
    }
    return externalAppDirectory;
  }
}
