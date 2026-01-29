import 'package:get_storage/get_storage.dart';

class PlayCounter {
  static final _storage = GetStorage();
  static int playCount = _storage.read('playCount') ?? 0;

  static void increment() {
    playCount++;
    _storage.write('playCount', playCount);
  }
}
