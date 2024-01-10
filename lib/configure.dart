import 'dart:convert';
import 'dart:io';
import 'package:dart_autogui/dart_autogui.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class Configure {
  bool _hasConfirm = false;
  Map<String, dynamic> mapConfigMap = {};
  File mapFile = File(join(Directory.current.path, "config", "map.yml"));

  Future<void> startConfig(List<String> args) async {
    mapFile = File(join(Directory.current.path, "config", "map.yml"));
    YamlMap mapConfig = loadYaml(mapFile.readAsStringSync());
    mapConfigMap = jsonDecode(jsonEncode(mapConfig));

    if (args.length > 1) {
      String key = args[1];

      if (!mapConfig.containsKey(key)) {
        print("La clé $key n'existe pas !");
        exit(0);
      }

      switch (mapConfig[key]["type"]) {
        case "click":
          await configureClick(key);
        case "double_click":
          await configureClick(key);
        case "write":
          await configureClick(key);
        case "continue":
          await configureClick(key);
        case "drag":
          await configureDrag(key);
        case "keyboard":
          await configureClick(key);
      }
      return;
    }

    for (var key in mapConfig.keys) {
      switch (mapConfig[key]["type"]) {
        case "click":
          await configureClick(key);
          break;
        case "double_click":
          await configureClick(key);
          break;
        case "write":
          await configureClick(key);
          break;
        case "continue":
          await configureClick(key);
          break;
        case "drag":
          await configureDrag(key);
          break;
        case "keyboard":
          await configureClick(key);
          break;
        case "verifyColor":
          await configureClick(key);
          break;
      }
    }

    mapFile.writeAsStringSync(mapConfigMap.toString());
    print("Configuration terminée !");
  }

  Future<void> configureDrag(String key) async {
    print("---------------------------");
    print(" ${key.toUpperCase()}  ");
    print("Bouger la souris pour arriver a la position souhaiter, et appuyer sur ENTRER. #1");
    print("---------------------------");

    while (!_hasConfirm) {
      stdin.readLineSync();
      _hasConfirm = true;
    }

    _hasConfirm = false;

    print("Enregistrement de la position dans 3 secondes...");
    await Future.delayed(Duration(seconds: 3));

    MousePosition position = await Mouse.pos();
    mapConfigMap[key]["x"] = position.x;
    mapConfigMap[key]["y"] = position.y;

    if (mapConfigMap[key]["needColor"]) {
      MouseColor color = await Mouse.getColorAt(position.x, position.y);
      mapConfigMap[key]["color"] = color.toHex().replaceAll("#", "");
      print("Couleur enregistrée: ${color.toHex()} !");
    }

    print("Bouger la souris pour arriver a la position souhaiter, et appuyer sur ENTRER. #2");
    print("---------------------------");
    stdin.readLineSync();

    print("Enregistrement de la position dans 3 secondes...");
    await Future.delayed(Duration(seconds: 3));

    MousePosition positionTwo = await Mouse.pos();
    mapConfigMap[key]['to']["x"] = positionTwo.x;
    mapConfigMap[key]['to']["y"] = positionTwo.y;

    print("Position enregistrée: x : ${position.x}, y: ${position.y} !");
    print("Position enregistrée: x : ${positionTwo.x}, y: ${positionTwo.y} !");
    mapFile.writeAsStringSync(mapConfigMap.toString());
  }

  Future<void> configureClick(String key) async {
    print("---------------------------");
    print(" ${key.toUpperCase()}  ");
    print("Bouger la souris pour arriver a la position souhaiter, et appuyer sur ENTRER.");
    print("---------------------------");

    stdin.readLineSync();

    print("Enregistrement de la position dans 3 secondes...");
    await Future.delayed(Duration(seconds: 3));

    MousePosition position = await Mouse.pos();
    mapConfigMap[key]["x"] = position.x;
    mapConfigMap[key]["y"] = position.y;

    if (mapConfigMap[key]["needColor"]) {
      MouseColor color = await Mouse.getColorAt(position.x, position.y);
      mapConfigMap[key]["color"] = color.toHex().replaceAll("#", "");
      print("Couleur enregistrée: ${color.toHex()} !");
    }

    print("Position enregistrée: x : ${position.x}, y: ${position.y} !");
    mapFile.writeAsStringSync(mapConfigMap.toString());
  }
}
