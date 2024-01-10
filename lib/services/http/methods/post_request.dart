import 'package:gmail/services/http/methods/method_contract.dart';
import 'package:http/http.dart';

class PostRequest extends MethodContract {

  PostRequest(super.method, super.request);

  @override
  Future<Response> process(String url) async {
    Response response = await super.request.http.post(Uri(path: super.request.baseUrl + url));
    return response;
  }
}