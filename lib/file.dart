import 'dart:io' as io;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/transfer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String userAutoId = "";

class FilePage extends StatefulWidget {
  const FilePage({super.key, required this.title});
  static const name = '/FilePage';
  final String title;

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  GlobalKey<FormState> _key = GlobalKey();
  var selectedTaskId = '';

  void _incrementCounter(String uID) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      dialogTitle: 'Выбор файла',
    );
    if (result != null) {
      final size = result.files.first.size;
      final file = io.File(result.files.single.path!);
      final fileExtensions = result.files.first.extension!;
      print("размер:$size file:${file.path} fileExtensions:${fileExtensions}");

      var fireStorage = FirebaseStorage.instance;
      var taskPath =
          fireStorage.ref().child(uID + '/' + getRandomString(5)).putFile(file);
    } else {}
  }

  String link = '';
  List<ModelTest> fullpath = [];

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> initImage(String uID) async {
    fullpath.clear();
    final storageReference = FirebaseStorage.instance.ref().child(uID).list();
    final list = await storageReference;
    list.items.forEach((element) async {
      final url = await element.getDownloadURL();
      fullpath.add(ModelTest(url, element.name));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Transfer;
    String uID = args.userID ?? args.credential!.user!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () async {
                await initImage(uID);
              },
              icon: Icon(Icons.refresh.fontPackage as IconData?))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: fullpath.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      onLongPress: () async {
                        link = '';
                        await FirebaseStorage.instance
                            .ref("/" + fullpath[index].name)
                            .delete();
                        await initImage(uID);
                        setState(() {});
                      },
                      onTap: () {
                        setState(() {
                          link = fullpath[index].url;
                        });
                      },
                      child: ListTile(
                        title: Text(fullpath[index].name),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Image.network(
                link,
                errorBuilder: (context, error, stackTrace) {
                  return Text('Ошибка');
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _incrementCounter(uID);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ModelTest {
  final String url;
  final String name;

  ModelTest(this.url, this.name);
}
