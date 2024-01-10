import 'package:gmail/fruitz.dart';
import 'package:http/http.dart';

class HttpRequest {
  final String baseUrl;
  final Map<String, String> headers;
  final Client http = Client();
  int tries = 0;
  Fruitz? fruitz = null;

  HttpRequest({required this.baseUrl, required this.headers});

  Future<Response> get(String url) async {
    try {
      Response response = await http.get(Uri.parse("$baseUrl$url"), headers: headers);
      tries = 0;
      return response;
    } catch (e) {
      tries++;
      print(e);
      print("Perte de connexion surement, attendre de 1 minute");
      await Future.delayed(Duration(minutes: 1));
      if (tries % 3 == 2) {
        print("Tried 3 times, reset proxy");
        await fruitz!.resetProxy();
      }
      return await get(url);
    }
  }

  Future<Response> post(String url, {required Map<String, String> body}) async {
    try {
      var request = MultipartRequest('POST', Uri.parse("$baseUrl$url"));
      request.fields.addAll(body);
      StreamedResponse response = await request.send();
      tries = 0;
      Response responseT = await Response.fromStream(response);
      return responseT;
    } catch (e) {
      tries++;
      print(e);
      print("Perte de connexion surement, attendre de 1 minute");
      await Future.delayed(Duration(minutes: 1));
      if (tries % 3 == 2) {
        print("Tried 3 times, reset proxy");
        await fruitz!.resetProxy();
      }
      await Future.delayed(Duration(minutes: 1));
      return await post(url, body: body);
    }
  }
}
