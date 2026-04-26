import 'dart:convert';
import 'package:http/http.dart' as http;
import 'localStorage.dart';

class ApiParams {
  static const String apiBaseUrl = 'http://127.0.0.1:8000';
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
        final jsonResponse = jsonDecode(response.body);
        
        // Ajuste a chave conforme a resposta da sua API
        // Pode ser 'token', 'access_token', 'data.token', etc
        token = jsonResponse['token'] ?? jsonResponse['access_token'];
        
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

  /// Retorna headers padrão com autenticação
  static Future<Map<String, String>> obterHeaders() async {
    final tokenAtual = await obterToken();
    return {
      'Content-Type': 'application/json',
      if (tokenAtual != null) 'Authorization': 'Bearer $tokenAtual',
    };
  }

  /// Limpa o token (logout)
  static Future<void> limparToken() async {
    token = null;
    await _storage.removeToken();
  }
}