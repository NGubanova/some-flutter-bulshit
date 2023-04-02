import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/transfer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final FirebaseFirestore fireStore = FirebaseFirestore.instance;
String userAutoId = "";

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.title});
  static const name = '/PostPage';
  final String title;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool isEditMode = false;
  var selectedTaskId = '';
  TextEditingController txtName = TextEditingController();
  TextEditingController txtContent = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double skWidth = MediaQuery.of(context).size.width;
    final double skHeight = MediaQuery.of(context).size.height;
    final args = ModalRoute.of(context)!.settings.arguments as Transfer;
    String uID = args.userID ?? args.credential!.user!.uid;

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (isEditMode) {
              setState(() {
                if (txtName.text != "" && txtContent.text != "") {
                  var firestore = FirebaseFirestore.instance;
                  var taskPath =
                      firestore.collection('user').doc(uID).collection('tasks');
                  var creationDate =
                      DateFormat('dd.MM.yyyy hh:mm').format(DateTime.now());

                  taskPath.doc(selectedTaskId).set({
                    'name': txtName.text,
                    'content': txtContent.text,
                    'date': creationDate.toString()
                  });
                  isEditMode = false;
                } else {
                  var bar = const SnackBar(
                    content: Text('Заполните все поля'),
                    duration: Duration(seconds: 2),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(bar);
                }
              });
            } else {
              setState(() {
                if (txtName.text != "" && txtContent.text != "") {
                  var firestore = FirebaseFirestore.instance;
                  var taskPath =
                      firestore.collection('user').doc(uID).collection('tasks');
                  var creationDate =
                      DateFormat('dd.MM.yyyy hh:mm').format(DateTime.now());

                  taskPath.add({
                    'name': txtName.text,
                    'content': txtContent.text,
                    'date': creationDate.toString()
                  });
                  txtContent.text = '';
                  txtName.text = '';
                } else {
                  var bar = const SnackBar(
                    content: Text('Заполните все поля'),
                    duration: Duration(seconds: 2),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(bar);
                }
              });
            }
          },
          child: isEditMode == false
              ? const Icon(Icons.add_circle_outline_rounded)
              : const Icon(Icons.edit_calendar_outlined),
        ),
        body: Scaffold(
          appBar: AppBar(
            title: Text('Посты'),
          ),
          body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 226, 175, 235),
                    Color.fromARGB(255, 238, 177, 197),
                    Color.fromARGB(255, 250, 161, 190),
                    Color.fromARGB(255, 206, 149, 168),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Название',
                        border: OutlineInputBorder(),
                      ),
                      controller: txtName,
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: TextFormField(
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          labelText: 'Содержание',
                          border: OutlineInputBorder(),
                        ),
                        controller: txtContent,
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('user')
                            .doc(uID)
                            .collection('tasks')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView(
                            children: snapshot.data!.docs
                                .map((task) => ListTile(
                                      onLongPress: () async {
                                        var firestore =
                                            FirebaseFirestore.instance;
                                        var taskPath = firestore
                                            .collection('user')
                                            .doc(uID)
                                            .collection('tasks');
                                        await taskPath.doc(task.id).delete();
                                      },
                                      title: Container(
                                        margin: const EdgeInsets.all(10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onDoubleTap: () {
                                              setState(() {
                                                txtName.text = task.get('name');
                                                txtContent.text =
                                                    task.get('content');
                                                isEditMode = true;
                                                selectedTaskId = task.id;
                                              });
                                            },
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      task.get('name'),
                                                      style: const TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Text(
                                                    task.get('content'),
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: Text(
                                                          task.get('date'))),
                                                ]),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )),
        ));
  }
}
