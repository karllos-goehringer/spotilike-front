import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'localStorage.dart';

class ApiParams {
  static const String apiBaseUrl = 'http://127.0.0.1:8000';
  final String mediaBaseUrl = '${ApiParams.apiBaseUrl}/media/';

  static const String apiUser = 'karllos';
  static const String apiPassword = '123456';
  static const String loginEndpoint = '$apiBaseUrl/api/login/';
  
  static String? token;
  static final LocalStorage _storage = LocalStorage();

  /// Autentica o usuário e retorna o token
  static Future<String?> autenticarAPI() async {
    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': apiUser,
          'password': apiPassword,
        }),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == 'null') {
          print('❌ Resposta de autenticação vazia');
          return null;
        }

        final dynamic jsonResponse = jsonDecode(response.body);
        
        // Garantindo que o valor extraído seja tratado como String ou null
        final extractedToken = jsonResponse['token'] ?? jsonResponse['access_token'];
        token = extractedToken?.toString();
        
        if (token != null) {
          // Armazenar token no localStorage para persistência
          await _storage.saveToken(token!);
          print('Token autenticado: $token');
          return token;
        } else {
          print('Token não encontrado na resposta');
          return null;
        }
      } else {
        print('Erro na autenticação: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao autenticar: $e');
      return null;
    }
  }

  /// Recupera o token armazenado ou autentica novamente se necessário
  static Future<String?> obterToken() async {
    if (token != null) {
      return token;
    }
    
    // Tentar recuperar do localStorage
    final tokenArmazenado = await _storage.getToken();
    if (tokenArmazenado != null) {
      token = tokenArmazenado;
      return token;
    }
    
    // Se não houver token, fazer login
    return await autenticarAPI();
  }

  /// Autentica com credenciais fornecidas
  static Future<String?> autenticarAPIComCredenciais(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == 'null') {
          print('❌ Resposta de autenticação vazia');
          return null;
        }

        final dynamic jsonResponse = jsonDecode(response.body);
        
        final extractedToken = jsonResponse['token'] ?? jsonResponse['access_token'];
        token = extractedToken?.toString();
        
        if (token != null) {
          await _storage.saveToken(token!);
          print('Token autenticado: $token');
          return token;
        } else {
          print('Token não encontrado na resposta');
          return null;
        }
      } else {
        print('Erro na autenticação: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao autenticar: $e');
      return null;
    }
  }

  /// Retorna headers padrão com autenticação
  static Future<Map<String, String>> obterHeaders() async {
    final tokenAtual = await obterToken();
    return {
      'Content-Type': 'application/json',
      // No Django REST Framework padrão, o prefixo é 'Token'. 
      // Use 'Bearer' apenas se estiver usando JWT.
      if (tokenAtual != null) 'Authorization': 'Token $tokenAtual',
    };
  }

  /// Limpa o token (logout)
  static Future<void> limparToken() async {
    token = null;
    await _storage.removeToken();
  }

  /// Faz upload de imagem e retorna a URL
  static Future<String?> uploadImage(XFile image) async {
    try {
      final headers = await obterHeaders();
      var request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/api/upload/image/'));
      request.headers.addAll(headers);
      
      // Lê os bytes da imagem (funciona em web e mobile)
      final imageBytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: image.name,
        ),
      );
      
      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['url'] ?? json['image_url'];
      } else {
        print('Erro upload: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro upload: $e');
      return null;
    }
  }
}