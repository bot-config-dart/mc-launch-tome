import 'dart:convert';

import 'package:gmail/fruitz.dart';
import 'package:gmail/services/http/http_request.dart';
import 'package:http/http.dart';

class Phone {
  String number;
  String orderId;
  String country;
  HttpRequest request = HttpRequest(baseUrl: "https://api.smspool.net/", headers: {});
  double cost;
  int tries = 0;
  Fruitz? fruitz;

  Phone({required this.number, required this.orderId, required this.country, required this.cost, required this.fruitz});

  Future<String> getCode() async {
    try {
      Response response = await request.post("sms/check", body: {
        "key": Fruitz.authorization,
        "orderid": orderId,
      });

      final payload = jsonDecode(response.body);

      if (tries > 40) {
        print("Tried 40 times, giving up (number: $number)");
        await fruitz!.reset("Tried 40 times with the code, giving up (number: $number, orderId: $orderId)");
        return "";
      }

      if (payload['message'] == "pending") {
        print("Waiting for code");
        await Future.delayed(Duration(seconds: 2));
        tries++;
        return await getCode();
      } else {
        print(payload);
        print("Code: ${payload['message']}");
        return payload['sms'];
      }
    } catch (e) {
      print(e);
      await Future.delayed(Duration(seconds: 2));
      await fruitz!.reset("Error while getting code (number: $number, orderId: $orderId), erreur:\n ```$e```");
      return "";
    }
  }

  factory Phone.fromJson(Map<String, dynamic> json, Fruitz fruitz) {
    print(json);
    return Phone(
      number: json['phonenumber'],
      orderId: json['order_id'],
      country: json['country'],
      cost: double.parse(json['cost']),
      fruitz: fruitz,
    );
  }
}
