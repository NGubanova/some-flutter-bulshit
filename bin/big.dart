import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:big/big.dart';

void main() async {
  final port = int.parse(Platform.environment["PORT"] ?? '2222');

  final service = Application<AppService>()
    ..options.port = port
    ..options.configurationFilePath = 'config.yaml';
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
