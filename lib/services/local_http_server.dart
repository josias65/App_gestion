import 'dart:convert';
import 'dart:io';

class LocalHttpServer {
  HttpServer? _server;

  bool get isRunning => _server != null;
  int? get port => _server?.port;

  Future<void> start({int port = 8089}) async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.listen(_handleRequest);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  void _handleRequest(HttpRequest request) async {
    final path = request.uri.path;
    if (request.method == 'GET' && path == '/health') {
      return _json(request, 200, {'status': 'ok'});
    }
    if (request.method == 'GET' && path == '/clients') {
      return _json(request, 200, {'clients': []});
    }
    _json(request, 404, {'error': 'Not found'});
  }

  void _json(HttpRequest request, int status, Map<String, dynamic> body) {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    request.response.close();
  }
}


