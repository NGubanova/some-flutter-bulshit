import 'package:firebase_auth/firebase_auth.dart';

class Transfer {
  UserCredential? credential;
  String? userID;
  Transfer({this.credential, this.userID});
}