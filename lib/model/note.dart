import 'package:big/model/user.dart';
import 'package:conduit/conduit.dart';

class Note extends ManagedObject<_Note> implements _Note {}

class _Note {
  @primaryKey
  int? id;

  @Column(unique: true, indexed: true)
  String? nameNote;

  @Column(nullable: true)
  String? content;

  @Column(unique: true, indexed: true)
  String? category;

  @Column(unique: true, indexed: true)
  DateTime? dateCreation;

  @Column(unique: true, indexed: true)
  DateTime? dateEdit;

  @Column(nullable: true)
  late bool status;

  @Relate(#noteList, isRequired: true, onDelete: DeleteRule.cascade)
  late User? user;
}
