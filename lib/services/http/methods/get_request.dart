import 'package:gmail/services/http/methods/method_contract.dart';
import 'package:http/http.dart';

class GetRequest extends MethodContract {

  GetRequest(super.method, super.request);

  @override
  Future<Response> process(String url) async {
    Response response = await super.request.http.get(Uri(path: super.request.baseUrl + url));
    return response;
  }
}