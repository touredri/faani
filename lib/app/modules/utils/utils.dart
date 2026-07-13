// function that return random string
import 'dart:math';

String randomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rnd = Random();
  final result =
      List.generate(length, (index) => chars[rnd.nextInt(chars.length)]);
  return result.join();
}

// function that add extension to the file
String addExtension(String path) {
  final ext = path.split('.').last;
  return ext;
}
