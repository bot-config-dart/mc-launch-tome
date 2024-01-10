import 'package:gmail/configure.dart';
import 'package:gmail/fruitz.dart';
import 'package:gmail/update.dart';

Future<void> main(List<String> arguments) async {
  switch(arguments[0]) {
    case "start": await Fruitz().start();
    case "configure": await Configure().startConfig(arguments);
    case "update": await Update().update(arguments);
  }
}
