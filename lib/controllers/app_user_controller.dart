import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:big/model/user.dart';
import 'package:big/utils/app_response.dart';
import 'package:big/utils/app_utils.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../model/model_response.dart';

class AppUserController extends ResourceController {

  AppUserController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);

      user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
          message: 'Успешное получение профиля', body: user.backing.contents);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения профиля');
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() User user,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final fUser = await managedContext.fetchObjectWithID<User>(id);
      // Запрос для обновления данных пользователя
      final qUpdateUser = Query<User>(managedContext)
        ..where((element) => element.id)
            .equalTo(id) // Поиск пользователя осущетсвляется по id
        ..values.userName = user.userName ?? fUser!.userName
        ..values.email = user.email ?? fUser!.email;
      // Вызов функция для обновления данных пользователя
      await qUpdateUser.updateOne();
      // Получаем обновленного пользователя
      final findUser = await managedContext.fetchObjectWithID<User>(id);
      // Удаляем не нужные параметры для красивого вывода данных пользователя
      findUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
        message: 'Успешное обновление данных',
        body: findUser.backing.contents,
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления данных');
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('newPassword') String newPassword,
    @Bind.query('oldPassword') String oldPassword,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qFindUser = Query<User>(managedContext)
        ..where((element) => element.id).equalTo(id)
        ..returningProperties(
          (element) => [
            element.salt,
            element.hashPassword,
          ],
        );

      final fUser = await qFindUser.fetchOne();

      final oldHashPassword =
          generatePasswordHash(oldPassword, fUser!.salt ?? "");

      if (oldHashPassword != fUser.hashPassword) {
        return AppResponse.badrequest(
          message: 'Неверный старый пароль',
        );
      }

      // Создаем hash нового пароля
      final newHashPassword =
          generatePasswordHash(newPassword, fUser.salt ?? "");

      // Создаем запрос на обнолвения пароля
      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.hashPassword = newHashPassword;

      // Обновляем пароль
      await qUpdateUser.updateOne();

      return AppResponse.ok(body: 'Пароль успешно обновлен');
    }  catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления пароля');
    }
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(@Bind.path('refresh') String refreshToken) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);

      final user = await managedContext.fetchObjectWithID<User>(id);

      if(user!.refreshToken != refreshToken) {
        return Response.unauthorized(body: 'Token не валидный!');
      }

      _updateTokens(id, managedContext);

      return Response.ok(
        ModelResponse(
          data: user.backing.contents,
          message: 'Токен успешно обновлён!')
      );
    } on QueryException catch(e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  void _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, String> tokens = _getTokens(id);

    final qUpdateTokens = Query<User>(transaction)
      ..where((element) => element.id).equalTo(id)
      ..values.accessToken = tokens['access']
      ..values.refreshToken = tokens['refresh'];

    await qUpdateTokens.updateOne();
  }

  Map<String, String> _getTokens(int id) {
    final key = Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';
    final accessClaimSet = JwtClaim(
      maxAge: const Duration(hours: 1),
      otherClaims: {'id': id}
    );

    final refreshClaimSet = JwtClaim(
      otherClaims: {'id': id}
    );

    final tokens = <String, String>{};
    tokens['access'] = issueJwtHS256(accessClaimSet, key);
    tokens['refresh'] = issueJwtHS256(refreshClaimSet, key);

    return tokens;
  }
}
