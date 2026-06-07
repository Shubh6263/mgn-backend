import 'dart:convert';
import 'package:crypto/crypto.dart';

String gravatarUrl(String email, {int size = 200}) {
  final normalized = email.trim().toLowerCase();
  final hash = md5.convert(utf8.encode(normalized)).toString();
  return 'https://www.gravatar.com/avatar/$hash?d=identicon&s=$size';
}
