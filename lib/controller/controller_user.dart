import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:spotilike_front/class/api_params.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:spotilike_front/class/user.dart';

class ControllerUser {
  static User? _currentUser;
  static User? get currentUser => _currentUser;
 static  Future<User?> getUser(int userID) async {
    final apiBase = ApiParams.apiBaseUrl;
    final headers = await ApiParams.obterHeaders();
    final response = await http.get(
      Uri.parse('$apiBase/api/users/$userID/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      _currentUser = User.fromJson(jsonResponse);
      return User.fromJson(jsonResponse);
    } else {
      return null;
    }
  }
 static  Future<User?> loginUser(String email, String password) async{
  try {
    final apiBase = ApiParams.apiBaseUrl;
    final headers = await ApiParams.obterHeaders();
    final response = await  http.post(
      Uri.parse('$apiBase/api/users/login/'),
      headers: headers,
      body: jsonEncode({
        'username': email,
        'password': password,
      }),);
             
      if(response.statusCode == 200){
        final jsonResponse = jsonDecode(response.body);
        final iduser = jsonResponse['id'];
        final userReq = getUser(iduser);
        return userReq;
      }else{
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  
    static Future<bool> registerUser(String name, String email, String password) async {
      try{
        final apiBase = ApiParams.apiBaseUrl;
        final response = await http.post(
          Uri.parse('$apiBase/api/users/register/'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
            'senha': password,
          }),
        );
        
        if(response.statusCode == 201){
          return true;
        }else{
          return false;
        }
        }catch(e){
          return false;
        }
    }
   static Future<Uint8List?> getProfileImageUrl() async {
    try{
      final imageURL =  _currentUser?.profileImageUrl;
      final headers = await ApiParams.obterHeaders();
      final url = '$imageURL';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }

  static Future<void> logout() async {
    _currentUser = null;
    await ApiParams.limparToken();
  }

  static Future<bool> updateProfile({
    required int userID,
    String? name,
    String? description,
    XFile? image,
    XFile? backgroundImage,
  }) async {
    try {
      final headers = await ApiParams.obterHeaders();
      headers.remove('Content-Type');

      final apiBase = ApiParams.apiBaseUrl;
      // Alterado para PATCH para permitir atualizações parciais
      var request = http.MultipartRequest('PATCH', Uri.parse('$apiBase/api/users/$userID/'));
      request.headers.addAll(headers);

      if (name != null) request.fields['name'] = name;
      request.fields['description'] = description ?? '';

      if (image != null) {
        final imageBytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'profilepicture',
            imageBytes,
            filename: image.name,
          ),
        );
      }

      if (backgroundImage != null) {
        final backgroundImageBytes = await backgroundImage.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'backgroundimage',
            backgroundImageBytes,
            filename: backgroundImage.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        _currentUser = User.fromJson(jsonResponse);
        dev.log('✅ Perfil atualizado com sucesso');
        return true;
      }
      dev.log('❌ Erro ao atualizar perfil: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      dev.log('❌ Exceção ao atualizar perfil: $e');
      return false;
    }
  }
}