import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:gmail/collections/collection.dart';
import 'package:gmail/services/entities/phone.dart';
import 'package:gmail/services/entities/utils.dart';
import 'package:gmail/services/map/coordonates.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';
import 'package:gmail/services/http/http_request.dart';

class Fruitz {
  dynamic mapConfig;
  dynamic config;
  Map<String, Coord> coords = {};
  bool isProxyReset = false;
  HttpRequest request = HttpRequest(baseUrl: "https://api.smspool.net/", headers: {});
  static String authorization = "C9KnRmdVF7duIDNt6a9cceDOTutsZLx9";
  bool error = false;
  bool canStart = true;
  String actualCity = "";
  String modelName = "";
  String proxy = "";
  int year = 1992;
  List<String> cities = [];
  bool probablyBan = false;
  static String webhook = "";

  List<Phone> phones = [];
  Phone activePhone = Phone(number: "", orderId: "", country: "", cost: 0.0, fruitz: null);

  Future<void> startBot() async {
    for (String city in cities) {
      if (phones.length % 2 == 1 && !isProxyReset) {
        await resetProxy();
      }

      actualCity = city;
      await goo(city);
    }

    print("Finished all cities, restarting...");
    await start();
  }

  Future<void> start({bool restart = false, bool nextCity = false}) async {
    if (restart) {
      int index = cities.indexOf(actualCity);
      print("index: $index");

      cities.removeRange(0, nextCity ? index + 1 : index);
      await startBot();
    } else {
      await setup();

      List<dynamic> citiesYAML = config["cities"];
      for (String city in citiesYAML) {
        cities.add(city);
      }

      await startBot();
    }
  }

  Future<void> resetProxy() async {
    try {
      Response response = await get(Uri.parse(proxy));

      if (response.body.toString().contains("IP rotation process has been initiated")) {
        isProxyReset = true;
        Timer(Duration(minutes: 1), () {
          isProxyReset = false;
        });

        print("Reset IP SUCCESS, wait 25s and retry");
        await Future.delayed(Duration(seconds: 25));
      }
    } catch (e) {
      print(e);
      print("Reset IP FAILED, wait 1 minutes and retry");
      await Future.delayed(Duration(minutes: 1));
      await resetProxy();
    }
  }

  Future<void> close() async {
    Coord coord = coords.getOrFail("close");
    await coord.click();

    await Future.delayed(Duration(seconds: 1));

    coord = coords.getOrFail("settings_close_btn");
    await coord.click();

    await Future.delayed(Duration(seconds: 1));

    coord = coords.getOrFail("delete_instance");
    await coord.click();

    await Future.delayed(Duration(seconds: 1));

    coord = coords.getOrFail("delete_confirm");
    await coord.click();
  }

  Future<void> reset(String reason) async {
    error = true;
    canStart = false;

    print("Une erreur est survenue, reset en cours...");
    await Utils.send("Une erreur est survenue sur le compte: ${activePhone.number}, order id: ${activePhone.orderId}, raison: $reason");

    await close();
    error = false;

    while (!canStart) {
      print("Restarting...");
      await start(restart: true, nextCity: true);
    }
  }

  Future<void> goo(String city) async {
    print("Starting with city: $city");
    await buyPhone();
    for (Coord coord in coords.values) {
      coord.reset();
      if (error) {
        canStart = true;
        break;
      }

      if (coord.type == "click") {
        if (coord.name.startsWith("like")) {
          await Future.delayed(Duration(milliseconds: 500));
          await coord.click();
          continue;
        }
        switch (coord.name) {
          case "meet_genre":
            await Future.delayed(Duration(seconds: 1));
            await coord.click();
            break;
          case "validate_pics":
            for (int i = 0; i < 6; i++) {
              await Future.delayed(Duration(milliseconds: 500));
              await coord.click();
            }
            await Future.delayed(Duration(milliseconds: 500));
            break;
          case "phone_confirm":
            await Future.delayed(Duration(milliseconds: 750));
            await coord.click();
            break;
          case "choose_fruit":
            List<dynamic> fruits = config["fruits"];
            int random = Random().nextInt(fruits.length);

            Coord fruitCoord = Coord(
                name: "fruit",
                x: int.parse(fruits[random]['x'].toString()),
                y: int.parse(fruits[random]['y'].toString()),
                type: "fruit",
                needColor: true,
                color: "#${fruits[random]["color"]}",
                fruitz: this);
            await fruitCoord.click();
            break;
          case "locate_here":
            await coord.click();
            break;
          case "click_geo":
            await Future.delayed(Duration(seconds: 3));
            await coord.click();
            break;
          case "understand_like":
            await coord.click();
            break;
          case "dislike":
            await coord.click();
            break;
          case "continue_code":
            await coord.click();
            probablyBan = true;
            break;
          case "open":
            await Future.delayed(Duration(seconds: 2));
            await coord.click();
            break;
          case "settings_pics":
            await Future.delayed(Duration(seconds: 2));
            await coord.click();
            break;
          case "select_all":
            await Future.delayed(Duration(seconds: 2));
            await coord.click();
            break;
          default:
            await coord.click();
            break;
        }
      } else if (coord.type == "double_click") {
        await coord.doubleClick();
      } else if (coord.type == "write") {
        switch (coord.name) {
          case "phone_number":
            await coord.write(activePhone.number, enterKey: false);
            break;
          case "code_input":
            String code = await activePhone.getCode();
            await coord.write(code, interval: 1, enterKey: false);
            break;
          case "input_geo":
            await coord.write(city);
            break;
          case "loc":
            await coord.write(activePhone.country);
            break;
          case "birth_day":
            int day = Random().nextInt(27) + 1;
            int month = Random().nextInt(9) + 1;
            if (day < 10) {
              day = int.parse("0$day");
            }
            if (month < 10) {
              month = int.parse("0$month");
            }
            print("DATE DE NAISSANCE: $day/$month/$year");
            await coord.write("$day $month $year", interval: 1, enterKey: false);
            break;
          case "name":
            await coord.write(modelName, enterKey: false);
            break;
          case "bio":
            List<dynamic> bios = config["bios"];
            int random = Random().nextInt(bios.length);
            dynamic bio = bios[random];
            final String realBio = Utils.formatBio(bio, 64);
            await coord.click();
            await Future.delayed(Duration(seconds: 2));
            await coord.write(realBio, enterKey: false);
            break;
        }
      } else if (coord.type == "moove") {
        await coord.moove();
      }
      if (coord.type == "keyboard") {
        await coord.keyboard();
      } else if (coord.type == "drag") {
        await coord.drag();
      } else if (coord.type == "waitColor") {
        await coord.waitColor();
      }
    }

    await Utils.send("Finished account with this number: ${activePhone.number}, order id: ${activePhone.orderId}");
    print("Finished account with this number: ${activePhone.number}, order id: ${activePhone.orderId}");
  }

  Future<void> buyPhone() async {
    try {
      Response response = await request.post("purchase/sms", body: {
        "key": authorization,
        "country": "FR", // OR GB
        "service": "1335",
        "max_price": "0.10",
        "pricing_option": "1",
        "quantity": "1",
      });

      Phone phone = Phone.fromJson(jsonDecode(response.body), this);
      phones.add(phone);
      activePhone = phone;
      double cost = phones.map((e) => e.cost).reduce((value, element) => value + element);
      print("Phone bought: ${phone.number}, order id: ${phone.orderId}, total cost at the moment: $cost");
    } catch (e) {
      print(e);
      print("Error while buying phone, retrying in 10s ...");
      await Future.delayed(Duration(seconds: 10));
      await buyPhone();
    }

  }

  Future<void> setup() async {
    print("Welcome to fruitz bot");

    request.fruitz = this;
    File mapFile = File(join(Directory.current.path, "config", "map.yml"));
    mapConfig = loadYaml(mapFile.readAsStringSync());

    File configFile = File(join(Directory.current.path, "config", "config.yml"));
    config = loadYaml(configFile.readAsStringSync());

    modelName = config["model_name"];
    proxy = config["proxy"];
    year = config["year"];
    webhook = config["webhook"];

    for (var key in mapConfig.keys) {
      Coord coord = Coord(
          x: mapConfig[key]["x"],
          y: mapConfig[key]["y"],
          type: mapConfig[key]['type'],
          name: key,
          color: "#${mapConfig[key]["color"]}",
          needColor: mapConfig[key]["needColor"],
          keystroke: mapConfig[key]["key"],
          toX: mapConfig[key]['to']?["x"],
          toY: mapConfig[key]["to"]?["y"],
          fruitz: this);
      coords.putIfAbsent(key, () => coord);
    }
  }
}
