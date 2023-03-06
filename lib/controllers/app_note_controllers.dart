import 'dart:io';

import 'package:big/model/note.dart';
import 'package:conduit/conduit.dart';

import '../model/model_response.dart';
import '../model/user.dart';
import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppNoteController extends ResourceController {
  AppNoteController(this.managedContext);

  final ManagedContext managedContext;
  @Operation.get()
  Future<Response> getAllNote(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query("search") String name,
    @Bind.query("page") int page,
  ) async {
    if (page.isNaN || page < 1 || page == 1) page = 0;
    if (page > 1) page = (page - 1) * 10;

    if (name.isNotEmpty) {
      try {
        final uid = AppUtils.getIdFromHeader(header);

        final qUserNote = Query<Note>(managedContext)
          ..where((x) => x.nameNote).contains(name, caseSensitive: false)
          ..where((x) => x.user!.id).equalTo(uid)
          ..offset = page
          ..fetchLimit = 10;

        final List<Note> userNote = await qUserNote.fetch();

        if (userNote.isEmpty)
          return AppResponse.ok(message: "Записи не найдены!");

        return Response.ok(userNote);
      } on QueryException catch (e) {
        return AppResponse.serverError(e, message: e.message);
      }
    } else {
      try {
        final id = AppUtils.getIdFromHeader(header);

        final qUserNote = Query<Note>(managedContext)
          ..where((x) => x.user!.id).equalTo(id)
          ..offset = page
          ..fetchLimit = 10;

        final List<Note> userNote = await qUserNote.fetch();

        if (userNote.isEmpty)
          return AppResponse.ok(message: "Записи не найдены!");

        return Response.ok(userNote);
      } on QueryException catch (e) {
        return Response.serverError(body: ModelResponse(message: e.message));
      }
    }
  }

  @Operation.get("id")
  Future<Response> getNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final uid = AppUtils.getIdFromHeader(header);

      final qUserNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..where((x) => x.user!.id).equalTo(uid);

      final Note? userNote = await qUserNote.fetchOne();

      if (userNote == null)
        return AppResponse.ok(message: "Запись не найдена!");

      final Note? userNote_ =
          await managedContext.fetchObjectWithID<Note>(userNote.id);
      userNote_!.removePropertiesFromBackingMap(["user"]);

      return Response.ok(userNote_);
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: e.message);
    }
  }

  @Operation.post()
  Future<Response> createNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Note note) async {
    try {
      final uid = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(uid);
      int newNoteId = -1;

      if (user == null)
        return AppResponse.ok(message: "Пользователь не найден!");

      await managedContext.transaction((transaction) async {
        final qCreateNote = Query<Note>(transaction)
          ..values.nameNote = note.nameNote
          ..values.content = note.content
          ..values.category = note.category
          ..values.dateCreation = DateTime.now()
          ..values.dateEdit = DateTime.now()
          ..values.status = true
          ..values.user = user;

        final createNote = await qCreateNote.insert();
        newNoteId = createNote.id!;
      });

      final Note? createdNote =
          await managedContext.fetchObjectWithID<Note>(newNoteId);
      createdNote!.removePropertiesFromBackingMap(["user"]);

      return Response.ok(ModelResponse(
          data: createdNote.backing.contents,
          message: "Запись успешно создана!"));
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: e.message);
    }
  }

  @Operation.delete("id")
  Future<Response> deleteNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final uid = AppUtils.getIdFromHeader(header);
      final note = await managedContext.fetchObjectWithID<Note>(id);

      if (note == null) return Response.badRequest(body: "Запись не найдена!");

      if (note.user?.id != uid)
        return AppResponse.ok(message: "У вас нет доступа к данной записи!");

      final qNoteDelete = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id);

      qNoteDelete.delete();

      return AppResponse.ok(message: "Запись удалена!");
    } catch (e) {
      return AppResponse.serverError(e, message: "Произошла ошибка!");
    }
  }

  @Operation.put("id")
  Future<Response> updateNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Note note,
      @Bind.path("id") int id) async {
    try {
      final uid = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(uid);

      final currentNote = await managedContext.fetchObjectWithID<Note>(id);

      if (user == null)
        return AppResponse.ok(message: "Пользователь не найден!");

      if (user.id != currentNote?.user?.id)
        return AppResponse.ok(message: "У вас нет доступа к данной записи!");

      final qUpdateNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.nameNote = note.nameNote
        ..values.content = note.content
        ..values.category = note.category
        ..values.dateEdit = DateTime.now();

      qUpdateNote.update();

      return AppResponse.ok(message: "Запись изменена!");
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: e.message);
    }
  }

  @Operation.put()
  Future<Response> deleteLogicNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.query('id') int id) async {
    try {
      final uid = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(uid);

      final currentNote = await managedContext.fetchObjectWithID<Note>(id);

      if (user == null)
        return AppResponse.ok(message: "Пользователь не найден!");

      if (user.id != currentNote?.user?.id)
        return AppResponse.ok(message: "У вас нет доступа к данной записи!");

      final qUpdateNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.status = false;

      qUpdateNote.update();

      return AppResponse.ok(message: "Запись логически удалена!");
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: e.message);
    }
  }
}
