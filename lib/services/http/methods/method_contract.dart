import 'package:http/http.dart';

import '../http_request.dart';

abstract class MethodContract {
  final String method;
  final HttpRequest request;

  MethodContract(this.method, this.request);

  Future<Response> process(String url);
}
