import 'dart:io';
import 'dart:typed_data';

class NetworkAdapter {
  factory NetworkAdapter() => _getInstance();
  static NetworkAdapter get instance => _getInstance();
  static NetworkAdapter? _instance;

  static late RawSocket device;

  NetworkAdapter._internal();

  static NetworkAdapter _getInstance() {
    _instance ??= NetworkAdapter._internal();
    return _instance!;
  }

  static Future<void> connect(String address, {int port = 9100}) async {
    try {
      device = await RawSocket.connect(address, port, timeout: const Duration(seconds: 5));
      // device = await Socket.connect(address, port, timeout: const Duration(seconds: 5));
    } catch (e) {
      print("报错了" + e.toString());
    }
  }

  Future<void> write(List<int> data) async {
    Uint8List bytes = Uint8List.fromList(data);

    final int sliceSize = 1024;
    int bufferLength = bytes.length;

    print("打印内容的长度" + bufferLength.toString());

    if (bufferLength > sliceSize) {
      int round = (bufferLength / sliceSize).ceil();
      for (int i = 0; i < round; i++) {
        int fromIndex = i * sliceSize;
        if ((i + 1) * sliceSize <= bufferLength) {
          device.write(bytes, fromIndex, sliceSize);
        } else {
          device.write(bytes, fromIndex);
        }
      }
    } else {
      device.write(bytes);
    }
  }

  Future<void> read(Function(dynamic) callback) async {
    device.listen((event) {
      callback(event);
    });
  }

  static Future<void> disconnect() async {
    await device.close();
    // device.destroy();
  }
}
